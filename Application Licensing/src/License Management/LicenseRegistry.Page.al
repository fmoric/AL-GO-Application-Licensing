namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;
/// <summary>
/// Page License Registry (ID 80502).
/// List page for viewing and managing generated licenses.
/// </summary>
page 80502 "License Registry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "License Registry";
    Caption = 'License Registry';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Licenses)
            {
                field("License ID"; Rec."License ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique license identifier.';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name for this license.';
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license becomes valid.';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license expires.';
                    Style = Attention;
                    StyleExpr = ValidToExpr;
                }
                field(Features; Rec.Features)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the licensed features.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current license status.';
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license was created.';
                }
                field("Last Validated"; Rec."Last Validated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license was last validated.';
                }
                field("Validation Result"; Rec."Validation Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the result of the last validation.';
                    Style = Attention;
                    StyleExpr = Rec."Validation Result" <> 'Valid';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateLicense)
            {
                ApplicationArea = All;
                Caption = 'Validate License';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate the selected license and check for tampering.';

                trigger OnAction()
                var
                    LicenseGenerator: Codeunit "License Generator";
                    IsValid: Boolean;
                begin
                    IsValid := LicenseGenerator.ValidateLicense(Rec."License ID");
                    if IsValid then
                        Message(LicenseValidationSuccessMsg)
                    else
                        Message(LicenseValidationFailedMsg, Rec."Validation Result");

                    CurrPage.Update(false);
                end;
            }
            action(RevokeLicense)
            {
                ApplicationArea = All;
                Caption = 'Revoke License';
                Image = Cancel;
                ToolTip = 'Revoke the selected license.';
                Enabled = Rec.Status = Rec.Status::Active;

                trigger OnAction()
                var
                    LicenseGenerator: Codeunit "License Generator";
                begin
                    if Confirm(ConfirmRevokeLicenseQst, false, Rec."License ID", Rec."Customer Name") then begin
                        if LicenseGenerator.RevokeLicense(Rec."License ID") then begin
                            Message(LicenseRevokedSuccessMsg);
                            CurrPage.Update(false);
                        end else
                            Error(FailedRevokeLicenseErr);
                    end;
                end;
            }
            action(ExportLicense)
            {
                ApplicationArea = All;
                Caption = 'Export License File';
                Image = Export;
                ToolTip = 'Export the license file for distribution to the customer.';

                trigger OnAction()
                var
                    LicenseManagement: Codeunit "License Management";
                    FileName: Text;
                begin
                    FileName := StrSubstNo(LicenseFileNameFormatLbl, Rec."Customer Name", Format(Rec."Valid To", 0, DateFormatLbl));
                    LicenseManagement.ExportLicenseFile(Rec."License ID", FileName);
                end;
            }
            action(GenerateNewLicense)
            {
                ApplicationArea = All;
                Caption = 'Generate New License';
                Image = Certificate;
                ToolTip = 'Generate a new license.';

                trigger OnAction()
                var
                    LicenseGeneration: Page "License Generation";
                begin
                    LicenseGeneration.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ImportLicense)
            {
                ApplicationArea = All;
                Caption = 'Import License';
                Image = Import;
                ToolTip = 'Import an existing license file into the system.';

                trigger OnAction()
                var
                    LicenseImport: Page "License Import";
                begin
                    LicenseImport.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ShowApplication)
            {
                ApplicationArea = All;
                Caption = 'Show Application';
                Image = ShowList;
                ToolTip = 'Show the application details for this license.';

                trigger OnAction()
                var
                    ApplicationRegistry: Record "Application Registry";
                    ApplicationCard: Page "Application Card";
                begin
                    if ApplicationRegistry.Get(Rec."App ID") then begin
                        ApplicationCard.SetRecord(ApplicationRegistry);
                        ApplicationCard.RunModal();
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("App Name");
        if Rec."Valid To" < Today then
            ValidToExpr := Format(PageStyle::Unfavorable)
        else
            ValidToExpr := Format(PageStyle::None);
    end;

    var
        ValidToExpr: Text;

        // Labels for translatable text
        LicenseValidationSuccessMsg: Label 'License validation successful.';
        LicenseValidationFailedMsg: Label 'License validation failed: %1';
        LicenseRevokedSuccessMsg: Label 'License revoked successfully.';
        ConfirmRevokeLicenseQst: Label 'Are you sure you want to revoke license %1 for customer %2?';
        FailedRevokeLicenseErr: Label 'Failed to revoke license.';

        // Locked labels for technical strings
        LicenseFileNameFormatLbl: Label '%1_%2_License.txt', Locked = true;
        DateFormatLbl: Label '<Year4><Month,2><Day,2>', Locked = true;
}