namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Tables;
using ApplicationLicensing.Codeunit;

/// <summary>
/// Page Customer Application Lines (ID 80512).
/// Subpage for managing application lines within a customer license.
/// Used in the Customer License Card to display and edit licensed applications.
/// </summary>
page 80512 "Customer Application Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Customer License Line";
    Caption = 'Licensed Applications';
    Permissions = tabledata "Customer License Header" = rimd,
                  tabledata "Application Registry" = rimd;
    layout
    {
        area(Content)
        {
            repeater(ApplicationLines)
            {
                field("Application Name"; Rec."Application Name")
                {
                    ToolTip = 'Specifies the application name.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ShowApplicationDetails();
                    end;
                }
                field(Publisher; Rec.Publisher)
                {
                    ToolTip = 'Specifies the application publisher.';
                    Editable = false;
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the application version.';
                    Editable = false;
                }
                field("License Status"; Rec."License Status")
                {
                    ToolTip = 'Specifies the license status.';
                    Style = Favorable;
                    StyleExpr = Rec."License Status" = Rec."License Status"::Active;
                }
                field("Licensed Features"; Rec."Licensed Features")
                {
                    ToolTip = 'Specifies the licensed features.';
                }
                field("License Generated"; Rec."License Generated")
                {
                    ToolTip = 'Specifies whether a license file has been generated.';
                    Editable = false;
                }
                field("Last Validated"; Rec."Last Validated")
                {
                    ToolTip = 'Specifies when the license was last validated.';
                    Editable = false;
                }
                field("Validation Result"; Rec."Validation Result")
                {
                    ToolTip = 'Specifies the last validation result.';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = IsValidationFailed;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateLicense)
            {
                Caption = 'Generate License';
                Image = CreateDocument;
                ToolTip = 'Generate a license file for this application.';
                Enabled = not Rec."License Generated";

                trigger OnAction()
                begin
                    if Rec.GenerateLicense() then begin
                        Message(LicenseGeneratedMsg, Rec."Application Name");
                        CurrPage.Update(false);
                    end else
                        Error(LicenseGenerationFailedErr, Rec."Application Name");
                end;
            }
            action(ValidateLicense)
            {
                Caption = 'Validate License';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate this license.';
                Enabled = Rec."License Generated";

                trigger OnAction()
                begin
                    if Rec.ValidateLicense() then
                        Message(LicenseValidMsg, Rec."Application Name")
                    else
                        Message(LicenseInvalidMsg, Rec."Application Name");
                    CurrPage.Update(false);
                end;
            }
            action(ExportLicense)
            {
                Caption = 'Export License';
                Image = Export;
                ToolTip = 'Export the license file for this application.';
                Enabled = Rec."License Generated";

                trigger OnAction()
                var
                    CustomerLicenseHeader: Record "Customer License Header";
                    LicenseManagement: Codeunit "License Management";
                    FileName: Text;
                begin
                    if not CustomerLicenseHeader.Get(Rec."Document No.") then
                        exit;

                    FileName := StrSubstNo(LicenseFileNameLbl,
                        CustomerLicenseHeader."Customer Name",
                        Rec."Application Name",
                        Format(CustomerLicenseHeader."License End Date", 0, '<Year4><Month,2><Day,2>'));

                    LicenseManagement.ExportLicenseFile(Rec."License ID", FileName);
                end;
            }
            action(RemoveLine)
            {
                Caption = 'Remove Application';
                Image = Delete;
                ToolTip = 'Remove this application from the customer license.';

                trigger OnAction()
                begin
                    if Confirm(ConfirmRemoveApplicationQst, false, Rec."Application Name", Rec."Document No.") then begin
                        Rec.Delete(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateVisualCues();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // License dates are managed at the header level
        // Document No. should be set by filter or by calling SetDocumentNo()
    end;

    /// <summary>
    /// Shows detailed information about the selected application.
    /// </summary>
    local procedure ShowApplicationDetails()
    var
        ApplicationRegistry: Record "Application Registry";
        ApplicationCard: Page "Application Card";
    begin
        if ApplicationRegistry.Get(Rec."Application ID") then begin
            ApplicationCard.SetRecord(ApplicationRegistry);
            ApplicationCard.Run();
        end;
    end;

    /// <summary>
    /// Updates visual cues based on record state.
    /// </summary>
    local procedure UpdateVisualCues()
    begin
        // License expiration is checked at header level
        IsValidationFailed := (Rec."Validation Result" <> '') and (Rec."Validation Result" <> 'Valid');
    end;

    var
        IsValidationFailed: Boolean;

        // Messages
        LicenseGeneratedMsg: Label 'License generated successfully for %1.', Comment = '%1 = Application name';
        LicenseValidMsg: Label 'License for %1 is valid.', Comment = '%1 = Application name';
        LicenseInvalidMsg: Label 'License for %1 is invalid.', Comment = '%1 = Application name';

        // Errors
        LicenseGenerationFailedErr: Label 'Failed to generate license for %1.', Comment = '%1 = Application name';

        // Questions
        ConfirmRemoveApplicationQst: Label 'Are you sure you want to remove application %1 from document %2?', Comment = '%1 = Application name, %2 = Document number';

        // File names
        LicenseFileNameLbl: Label '%1_%2_%3_License.txt', Comment = '%1 = Customer name, %2 = Application name, %3 = Date', Locked = true;
}