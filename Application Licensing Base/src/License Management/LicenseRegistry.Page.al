namespace ApplicationLicensing.Base.Pages;

using ApplicationLicensing.Base.Codeunit;
using ApplicationLicensing.Base.Tables;

/// <summary>
/// Page License Registry (ID 80501).
/// List page for viewing and managing imported licenses.
/// </summary>
page 80500 "License Registry"
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
        //TODO Move this to generator as page extension
        // area(Navigation)
        // {
        //     action(ApplicationRegistry)
        //     {
        //         ApplicationArea = All;
        //         Caption = 'Application Registry';
        //         Image = ApplicationWorksheet;
        //         ToolTip = 'Open the Application Registry to manage registered applications.';
        //         RunObject = page "Application Registry";
        //     }
        // }
    }

    var
        ValidToStyle: Boolean;

    trigger OnAfterGetRecord()
    begin
        ValidToStyle := Rec."Valid To" < Today();
    end;
}