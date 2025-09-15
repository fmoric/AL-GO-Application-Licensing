/// <summary>
/// Page Application License FactBox (ID 80505).
/// FactBox showing license information for an application.
/// </summary>
page 80505 "Application License FactBox"
{
    PageType = CardPart;
    SourceTable = "Application Registry";
    Caption = 'License Information';

    layout
    {
        area(Content)
        {
            group(Statistics)
            {
                Caption = 'License Statistics';
                field(TotalLicenses; TotalLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Total Licenses';
                    ToolTip = 'Shows the total number of licenses for this application.';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        LicenseRegistry: Record "License Registry";
                        LicenseRegistryPage: Page "License Registry";
                    begin
                        LicenseRegistry.SetRange("App ID", Rec."App ID");
                        LicenseRegistryPage.SetTableView(LicenseRegistry);
                        LicenseRegistryPage.Run();
                    end;
                }
                field(ActiveLicenses; ActiveLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Active Licenses';
                    ToolTip = 'Shows the number of active licenses for this application.';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = ActiveLicenses > 0;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        LicenseRegistry: Record "License Registry";
                        LicenseRegistryPage: Page "License Registry";
                    begin
                        LicenseRegistry.SetRange("App ID", Rec."App ID");
                        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
                        LicenseRegistryPage.SetTableView(LicenseRegistry);
                        LicenseRegistryPage.Run();
                    end;
                }
                field(ExpiredLicenses; ExpiredLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Expired Licenses';
                    ToolTip = 'Shows the number of expired licenses for this application.';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = ExpiredLicenses > 0;
                }
                field(RevokedLicenses; RevokedLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Revoked Licenses';
                    ToolTip = 'Shows the number of revoked licenses for this application.';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = RevokedLicenses > 0;
                }
            }
            group(RecentActivity)
            {
                Caption = 'Recent Activity';
                field(LastLicenseGenerated; LastLicenseGenerated)
                {
                    ApplicationArea = All;
                    Caption = 'Last License Generated';
                    ToolTip = 'Shows when the last license was generated for this application.';
                    Editable = false;
                }
                field(LastCustomer; LastCustomer)
                {
                    ApplicationArea = All;
                    Caption = 'Last Customer';
                    ToolTip = 'Shows the last customer for whom a license was generated.';
                    Editable = false;
                }
            }
        }
    }

    var
        TotalLicenses: Integer;
        ActiveLicenses: Integer;
        ExpiredLicenses: Integer;
        RevokedLicenses: Integer;
        LastLicenseGenerated: DateTime;
        LastCustomer: Text[100];

    trigger OnAfterGetCurrRecord()
    begin
        CalculateStatistics();
    end;

    /// <summary>
    /// Calculates license statistics for the current application.
    /// </summary>
    local procedure CalculateStatistics()
    var
        LicenseRegistry: Record "License Registry";
    begin
        Clear(TotalLicenses);
        Clear(ActiveLicenses);
        Clear(ExpiredLicenses);
        Clear(RevokedLicenses);
        Clear(LastLicenseGenerated);
        Clear(LastCustomer);

        if IsNullGuid(Rec."App ID") then
            exit;

        LicenseRegistry.SetRange("App ID", Rec."App ID");
        TotalLicenses := LicenseRegistry.Count;

        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
        LicenseRegistry.SetFilter("Valid To", '>=%1', Today);
        ActiveLicenses := LicenseRegistry.Count;

        LicenseRegistry.SetRange(Status);
        LicenseRegistry.SetFilter("Valid To", '<%1', Today);
        ExpiredLicenses := LicenseRegistry.Count;

        LicenseRegistry.SetRange("Valid To");
        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Revoked);
        RevokedLicenses := LicenseRegistry.Count;

        // Get last license information
        LicenseRegistry.SetRange(Status);
        LicenseRegistry.SetCurrentKey("Created Date");
        LicenseRegistry.Ascending(false);
        if LicenseRegistry.FindFirst() then begin
            LastLicenseGenerated := LicenseRegistry."Created Date";
            LastCustomer := LicenseRegistry."Customer Name";
        end;
    end;
}