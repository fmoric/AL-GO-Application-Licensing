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
                action(NewApplication)
                {
                    ApplicationArea = All;
                    Caption = 'Register New Application';
                    Image = New;
                    ToolTip = 'Register a new application in the system.';

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
                action(GenerateLicense)
                {
                    ApplicationArea = All;
                    Caption = 'Generate License';
                    Image = Certificate;
                    RunObject = page "License Generation";
                    ToolTip = 'Generate a new license.';
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
                action(GenerateSigningKey)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Signing Key';
                    Image = EncryptionKeys;
                    ToolTip = 'Generate a new RSA signing key.';

                }
            }
        }
        area(Creation)
        {
            action(QuickLicense)
            {
                ApplicationArea = All;
                Caption = 'Quick License Generation';
                Image = Certificate;
                ToolTip = 'Quickly generate a license for an existing application.';

            }
        }
        area(Processing)
        {
            action(ValidateAllLicenses)
            {
                ApplicationArea = All;
                Caption = 'Validate All Licenses';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate all active licenses in the system.';

            }
            action(SystemStatus)
            {
                ApplicationArea = All;
                Caption = 'System Status';
                Image = Status;
                ToolTip = 'Show current system status and statistics.';
            }
        }
        area(Reporting)
        {
        }
    }

}