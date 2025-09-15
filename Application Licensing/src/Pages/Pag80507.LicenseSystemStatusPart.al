/// <summary>
/// Page License System Status Part (ID 80507).
/// Status overview part for the License Management Center.
/// </summary>
page 80507 "License System Status Part"
{
    PageType = CardPart;
    Caption = 'System Status';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(SystemHealth)
            {
                Caption = 'System Health';
                field(SigningKeyStatus; SigningKeyStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Signing Key Status';
                    ToolTip = 'Shows whether a signing key is available.';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = SigningKeyAvailable;
                }
                field(TotalApplications; TotalApplications)
                {
                    ApplicationArea = All;
                    Caption = 'Total Applications';
                    ToolTip = 'Shows the total number of registered applications.';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        ApplicationRegistryPage: Page "Application Registry";
                    begin
                        ApplicationRegistryPage.Run();
                    end;
                }
                field(ActiveLicenses; ActiveLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Active Licenses';
                    ToolTip = 'Shows the number of currently active licenses.';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        LicenseRegistry: Record "License Registry";
                        LicenseRegistryPage: Page "License Registry";
                    begin
                        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
                        LicenseRegistryPage.SetTableView(LicenseRegistry);
                        LicenseRegistryPage.Run();
                    end;
                }
                field(ExpiringLicenses; ExpiringLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'Expiring Soon (30 days)';
                    ToolTip = 'Shows licenses expiring in the next 30 days.';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = ExpiringLicenses > 0;
                }
            }
        }
    }

    var
        SigningKeyStatus: Text[50];
        SigningKeyAvailable: Boolean;
        TotalApplications: Integer;
        ActiveLicenses: Integer;
        ExpiringLicenses: Integer;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateStatistics();
    end;

    trigger OnOpenPage()
    begin
        UpdateStatistics();
    end;

    /// <summary>
    /// Updates the system statistics.
    /// </summary>
    local procedure UpdateStatistics()
    var
        ApplicationRegistry: Record "Application Registry";
        LicenseRegistry: Record "License Registry";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
    begin
        // Check signing key availability
        SigningKeyAvailable := CryptoKeyManager.IsSigningKeyAvailable();
        if SigningKeyAvailable then
            SigningKeyStatus := 'Available'
        else
            SigningKeyStatus := 'Not Available';

        // Count applications
        TotalApplications := ApplicationRegistry.Count;

        // Count active licenses
        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
        LicenseRegistry.SetFilter("Valid To", '>=%1', Today);
        ActiveLicenses := LicenseRegistry.Count;

        // Count expiring licenses
        LicenseRegistry.SetFilter("Valid To", '%1..%2', Today, CalcDate('<+30D>', Today));
        ExpiringLicenses := LicenseRegistry.Count;
    end;
}