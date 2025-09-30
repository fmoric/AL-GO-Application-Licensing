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
    Permissions = tabledata "License Registry" = r,
                tabledata "Application Registry" = r,
                tabledata "Crypto Key Storage" = r;
    layout
    {
        area(Content)
        {
            repeater(Licenses)
            {
                field("License ID"; Rec."License ID")
                {
                }
                field("App Name"; Rec."App Name")
                {
                }
                field("Customer Name"; Rec."Customer Name")
                {
                }
                field("Valid From"; Rec."Valid From")
                {
                }
                field("Valid To"; Rec."Valid To")
                {
                    Style = Attention;
                    StyleExpr = ValidToExpr;
                }
                field(Features; Rec.Features)
                {
                }
                field(Status; Rec.Status)
                {

                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("Last Validated"; Rec."Last Validated")
                {
                }
                field("Validation Result"; Rec."Validation Result")
                {
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
            action(RevokeLicense)
            {

                Caption = 'Revoke License';
                Image = Cancel;
                ToolTip = 'Revoke the selected license.';
                Enabled = Rec.Status = Rec.Status::Active;

                trigger OnAction()
                var
                    LicenseGenerator: Codeunit "License Generator";
                begin
                    if Confirm(ConfirmRevokeLicenseQst, false, Rec."License ID", Rec."Customer Name") then
                        if LicenseGenerator.RevokeLicense(Rec."License ID") then begin
                            Message(LicenseRevokedSuccessMsg);
                            CurrPage.Update(false);
                        end else
                            Error(FailedRevokeLicenseErr);

                end;
            }
            action(ExportLicense)
            {

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
            action(ImportLicense)
            {

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
        if Rec."Valid To" < Today() then
            ValidToExpr := Format(PageStyle::Unfavorable)
        else
            ValidToExpr := Format(PageStyle::None);
    end;

    var
        ValidToExpr: Text;

        // Labels for translatable text
        LicenseValidationSuccessMsg: Label 'License validation successful.';
        LicenseValidationFailedMsg: Label 'License validation failed: %1', Comment = '%1=Validation Result';
        LicenseRevokedSuccessMsg: Label 'License revoked successfully.';
        ConfirmRevokeLicenseQst: Label 'Are you sure you want to revoke license %1 for customer %2?', Comment = '%1=License ID, %2=Customer Name';
        FailedRevokeLicenseErr: Label 'Failed to revoke license.';

        // Locked labels for technical strings
        LicenseFileNameFormatLbl: Label '%1_%2_License.txt', Locked = true;
        DateFormatLbl: Label '<Year4><Month,2><Day,2>', Locked = true;
}