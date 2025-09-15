/// <summary>
/// Page Recent Licenses Part (ID 80508).
/// Shows recent license activity for the License Management Center.
/// </summary>
page 80508 "Recent Licenses Part"
{
    PageType = ListPart;
    SourceTable = "License Registry";
    Caption = 'Recent Licenses';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RecentLicenses)
            {
                field("License ID"; Rec."License ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the license identifier.';
                    Visible = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license expires.';
                    Style = Attention;
                    StyleExpr = Rec."Valid To" < CalcDate('<+30D>', Today);
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the license status.';
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewLicense)
            {
                ApplicationArea = All;
                Caption = 'View License';
                Image = ViewDetails;
                ToolTip = 'Open the license registry to view details.';

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                    LicenseRegistryPage: Page "License Registry";
                begin
                    LicenseRegistry.SetRange("License ID", Rec."License ID");
                    LicenseRegistryPage.SetTableView(LicenseRegistry);
                    LicenseRegistryPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Show only recent licenses (last 30 days)
        Rec.SetFilter("Created Date", '>=%1', CalcDate('<-30D>', Today));
        Rec.SetCurrentKey("Created Date");
        Rec.Ascending(false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("App Name");
    end;
}