namespace ApplicationLicensing.Pages;

/// <summary>
/// Page License Management Center (ID 80504).
/// Main dashboard for license management operations.
/// </summary>
page 80504 "License Management Center"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    Caption = 'License Management Center';

    layout
    {
        area(RoleCenter)
        {
            // part(SystemStatus; "License System Status Part")
            // {
            //     ApplicationArea = All;
            // }
            // part(RecentLicenses; "Recent Licenses Part")
            // {
            //     ApplicationArea = All;
            // }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Applications)
            {
                Caption = 'Applications';
                action(ApplicationRegistry)
                {
                    ApplicationArea = All;
                    Caption = 'Application Registry';
                    Image = Setup;
                    RunObject = page "Application Registry";
                    ToolTip = 'Manage registered applications.';
                }
            }
            group(Licenses)
            {
                Caption = 'Licenses';
                action(LicenseRegistry)
                {
                    ApplicationArea = All;
                    Caption = 'License Registry';
                    Image = Certificate;
                    RunObject = page "License Registry";
                    ToolTip = 'View and manage generated licenses.';
                }

                action(ImportLicense)
                {
                    ApplicationArea = All;
                    Caption = 'Import License';
                    Image = Import;
                    RunObject = page "License Import";
                    ToolTip = 'Import an existing license file into the system.';
                }
            }
            group(Security)
            {
                Caption = 'Security';
                action(CryptoKeys)
                {
                    ApplicationArea = All;
                    Caption = 'Cryptographic Keys';
                    Image = EncryptionKeys;
                    RunObject = page "Crypto Key Management";
                    ToolTip = 'Manage cryptographic keys for license signing.';
                }

            }
        }

    }

}