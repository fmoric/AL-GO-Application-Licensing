namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Tables;
using ApplicationLicensing.Codeunit;

/// <summary>
/// Page Customer Application List (ID 80513).
/// List page for managing applications assigned to a specific customer.
/// Provides full CRUD operations for customer license lines.
/// </summary>
page 80513 "Customer Application List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Customer License Line";
    Caption = 'Customer Applications';
    Editable = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(ApplicationLines)
            {
                field("Application ID"; Rec."Application ID")
                {
                    ToolTip = 'Specifies the application ID.';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ApplicationRegistry: Record "Application Registry";
                        ApplicationList: Page "Application Registry";
                    begin
                        ApplicationList.LookupMode(true);
                        if ApplicationList.RunModal() = Action::LookupOK then begin
                            ApplicationList.GetRecord(ApplicationRegistry);
                            Rec.Validate("Application ID", ApplicationRegistry."App ID");
                            CurrPage.Update(false);
                            exit(true);
                        end;
                        exit(false);
                    end;
                }
                field("Application Name"; Rec."Application Name")
                {
                    ToolTip = 'Specifies the application name.';
                    Editable = false;
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
                field("License Start Date"; Rec."License Start Date")
                {
                    ToolTip = 'Specifies the license start date.';
                    ShowMandatory = true;
                }
                field("License End Date"; Rec."License End Date")
                {
                    ToolTip = 'Specifies the license end date.';
                    ShowMandatory = true;
                    Style = Attention;
                    StyleExpr = IsExpiredOrExpiring;
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
        area(FactBoxes)
        {
            part(ApplicationDetails; "Application License FactBox")
            {
                SubPageLink = "App ID" = field("Application ID");
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
            action(GenerateAllLicenses)
            {
                Caption = 'Generate All Licenses';
                Image = CreateDocuments;
                ToolTip = 'Generate license files for all applications.';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.GenerateAllCustomerLicenses(DocumentNo);
                    CurrPage.Update(false);
                end;
            }
            action(ValidateAllLicenses)
            {
                Caption = 'Validate All Licenses';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate all licenses for this document.';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.ValidateAllCustomerLicenses(DocumentNo);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ShowApplication)
            {
                Caption = 'Show Application';
                Image = ShowList;
                ToolTip = 'Show details of the selected application.';

                trigger OnAction()
                var
                    ApplicationRegistry: Record "Application Registry";
                    ApplicationCard: Page "Application Card";
                begin
                    if ApplicationRegistry.Get(Rec."Application ID") then begin
                        ApplicationCard.SetRecord(ApplicationRegistry);
                        ApplicationCard.Run();
                    end;
                end;
            }
            action(ShowLicenseDetails)
            {
                Caption = 'Show License Details';
                Image = Certificate;
                ToolTip = 'Show detailed information about the generated license.';
                Enabled = Rec."License Generated";

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                    LicenseRegistryPage: Page "License Registry";
                begin
                    if LicenseRegistry.Get(Rec."License ID") then begin
                        LicenseRegistryPage.SetRecord(LicenseRegistry);
                        LicenseRegistryPage.Run();
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
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        Rec."Document No." := DocumentNo;

        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        if CustomerLicenseLine.FindLast() then
            Rec."Line No." := CustomerLicenseLine."Line No." + 10000
        else
            Rec."Line No." := 10000;

        Rec."License Start Date" := Today();
        Rec."License End Date" := CalcDate('<+1Y>', Today());
    end;

    /// <summary>
    /// Sets the document context for this page.
    /// </summary>
    /// <param name="NewDocumentNo">The document number.</param>
    /// <param name="NewCustomerName">The customer name.</param>
    procedure SetDocument(NewDocumentNo: Code[20]; NewCustomerName: Text[100])
    begin
        DocumentNo := NewDocumentNo;
        CustomerName := NewCustomerName;

        Rec.SetRange("Document No.", DocumentNo);
        CurrPage.Caption := StrSubstNo(PageCaptionLbl, CustomerName);
    end;

    /// <summary>
    /// Sets the customer context for this page (legacy method).
    /// </summary>
    /// <param name="NewCustomerNo">The customer number.</param>
    /// <param name="NewCustomerName">The customer name.</param>
    procedure SetCustomer(NewCustomerNo: Code[20]; NewCustomerName: Text[100])
    var
        CustomerLicenseHeader: Record "Customer License Header";
    begin
        CustomerName := NewCustomerName;

        // Find the document for this customer - for backward compatibility
        CustomerLicenseHeader.SetRange("Customer No.", NewCustomerNo);
        if CustomerLicenseHeader.FindFirst() then begin
            DocumentNo := CustomerLicenseHeader."No.";
            Rec.SetRange("Document No.", DocumentNo);
        end;

        CurrPage.Caption := StrSubstNo(PageCaptionLbl, CustomerName);
    end;

    /// <summary>
    /// Updates visual cues based on record state.
    /// </summary>
    local procedure UpdateVisualCues()
    begin
        IsExpiredOrExpiring := (Rec."License End Date" < Today()) or
                              (Rec."License End Date" < CalcDate('<+30D>', Today()));

        IsValidationFailed := (Rec."Validation Result" <> '') and (Rec."Validation Result" <> ValidResultLbl);
    end;

    var
        DocumentNo: Code[20];
        CustomerName: Text[100];
        IsExpiredOrExpiring: Boolean;
        IsValidationFailed: Boolean;
        ValidResultLbl: Label 'Valid';

        // Messages
        LicenseGeneratedMsg: Label 'License generated successfully for %1.', Comment = '%1 = Application name';
        LicenseValidMsg: Label 'License for %1 is valid.', Comment = '%1 = Application name';
        LicenseInvalidMsg: Label 'License for %1 is invalid.', Comment = '%1 = Application name';

        // Errors
        LicenseGenerationFailedErr: Label 'Failed to generate license for %1.', Comment = '%1 = Application name';

        // Captions
        PageCaptionLbl: Label 'Applications for %1', Comment = '%1 = Customer name';
}