namespace ApplicationLicensing.Base.Pages;

using ApplicationLicensing.Base.Codeunit;
using ApplicationLicensing.Base.Tables;

/// <summary>
/// Page License Registry (ID 80501).
/// List page for viewing and managing imported licenses.
/// </summary>
page 80501 "License Registry"
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
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = ValidToStyle;
                }
                field(Features; Rec.Features)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
                field("Last Validated"; Rec."Last Validated")
                {
                    ApplicationArea = All;
                }
                field("Validation Result"; Rec."Validation Result")
                {
                    ApplicationArea = All;
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
                ToolTip = 'Validate the selected license.';

                trigger OnAction()
                var
                    LicenseValidator: Codeunit "License Validator";
                begin
                    if LicenseValidator.ValidateCompleteLicense(Rec) then
                        Message('License validation successful.')
                    else
                        Message('License validation failed: %1', Rec."Validation Result");
                    CurrPage.Update(false);
                end;
            }
            action(ValidateAllLicenses)
            {
                ApplicationArea = All;
                Caption = 'Validate All Licenses';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate all licenses in the registry.';

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                    LicenseValidator: Codeunit "License Validator";
                    ValidCount: Integer;
                    InvalidCount: Integer;
                begin
                    LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
                    if LicenseRegistry.FindSet() then
                        repeat
                            if LicenseValidator.ValidateCompleteLicense(LicenseRegistry) then
                                ValidCount += 1
                            else
                                InvalidCount += 1;
                        until LicenseRegistry.Next() = 0;

                    Message('Validation complete.\\Valid: %1\\Invalid: %2', ValidCount, InvalidCount);
                    CurrPage.Update(false);
                end;
            }
            action(ImportLicense)
            {
                ApplicationArea = All;
                Caption = 'Import License';
                Image = Import;
                ToolTip = 'Import a new license file into the system.';

                trigger OnAction()
                var
                    LicenseImport: Page "License Import";
                begin
                    LicenseImport.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ExportLicense)
            {
                ApplicationArea = All;
                Caption = 'Export License File';
                Image = Export;
                ToolTip = 'Export the selected license file.';

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                begin
                    Rec."License File".CreateInStream(InStream);
                    FileName := StrSubstNo('%1_%2.lic', Rec."Customer Name", Format(Rec."Valid To", 0, '<Year4><Month,2><Day,2>'));
                    DownloadFromStream(InStream, 'Export License', '', '', FileName);
                end;
            }
        }
        area(Navigation)
        {
            action(ApplicationRegistry)
            {
                ApplicationArea = All;
                Caption = 'Application Registry';
                Image = ApplicationWorksheet;
                ToolTip = 'Open the Application Registry to manage registered applications.';
                RunObject = page "Application Registry";
            }
        }
    }

    var
        ValidToStyle: Boolean;

    trigger OnAfterGetRecord()
    begin
        ValidToStyle := Rec."Valid To" < Today();
    end;
}