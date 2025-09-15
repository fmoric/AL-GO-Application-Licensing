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
            part(SystemStatus; "License System Status Part")
            {
                ApplicationArea = All;
            }
            part(RecentLicenses; "Recent Licenses Part")
            {
                ApplicationArea = All;
            }
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

                    trigger OnAction()
                    var
                        ApplicationCard: Page "Application Card";
                    begin
                        ApplicationCard.SetNewMode();
                        ApplicationCard.RunModal();
                    end;
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
                    ToolTip = 'Generate a new license.';

                    trigger OnAction()
                    var
                        LicenseGeneration: Page "License Generation";
                    begin
                        LicenseGeneration.RunModal();
                    end;
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

                    trigger OnAction()
                    var
                        CryptoKeyManager: Codeunit "Crypto Key Manager";
                        KeyId: Text;
                        ExpirationDate: Date;
                    begin
                        KeyId := StrSubstNo('SIGN-KEY-%1', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2>'));
                        ExpirationDate := CalcDate('<+5Y>', Today);
                        
                        if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Signing Key", ExpirationDate) then
                            Message('Signing key generated successfully: %1', KeyId)
                        else
                            Error('Failed to generate signing key.');
                    end;
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

                trigger OnAction()
                var
                    LicenseGeneration: Page "License Generation";
                begin
                    LicenseGeneration.RunModal();
                end;
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

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                    LicenseGenerator: Codeunit "License Generator";
                    ValidCount: Integer;
                    InvalidCount: Integer;
                begin
                    LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
                    if LicenseRegistry.FindSet() then begin
                        repeat
                            if LicenseGenerator.ValidateLicense(LicenseRegistry."License ID") then
                                ValidCount += 1
                            else
                                InvalidCount += 1;
                        until LicenseRegistry.Next() = 0;
                    end;

                    Message('License validation completed.' + NewLine() + 
                           'Valid licenses: %1' + NewLine() + 
                           'Invalid licenses: %2', ValidCount, InvalidCount);
                end;
            }
            action(SystemStatus)
            {
                ApplicationArea = All;
                Caption = 'System Status';
                Image = Status;
                ToolTip = 'Show current system status and statistics.';

                trigger OnAction()
                var
                    LicenseManagement: Codeunit "License Management";
                begin
                    LicenseManagement.CLI_ShowSystemStatus();
                end;
            }
        }
        area(Reporting)
        {
            action(LicenseReport)
            {
                ApplicationArea = All;
                Caption = 'License Report';
                Image = Report;
                ToolTip = 'Generate a comprehensive license report.';

                trigger OnAction()
                begin
                    Message('License reporting functionality would be implemented here.');
                end;
            }
        }
    }

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    local procedure NewLine(): Text[1]
    begin
        exit('\n');
    end;
}