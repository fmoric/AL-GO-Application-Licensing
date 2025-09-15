/// <summary>
/// Page License CLI Demo (ID 80509).
/// Demonstrates command-line interface functionality.
/// </summary>
page 80509 "License CLI Demo"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'License CLI Demonstration';

    layout
    {
        area(Content)
        {
            group(ApplicationManagement)
            {
                Caption = 'Application Management Commands';
                field(NewAppId; NewAppId)
                {
                    ApplicationArea = All;
                    Caption = 'Application ID (GUID)';
                    ToolTip = 'Enter a GUID for the new application.';
                }
                field(NewAppName; NewAppName)
                {
                    ApplicationArea = All;
                    Caption = 'Application Name';
                    ToolTip = 'Enter the application name.';
                }
                field(NewPublisher; NewPublisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Enter the publisher name.';
                }
                field(NewVersion; NewVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    ToolTip = 'Enter the version string.';
                }
                field(NewDescription; NewDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Enter an optional description.';
                    MultiLine = true;
                }
            }
            group(LicenseGeneration)
            {
                Caption = 'License Generation Commands';
                field(LicenseAppId; LicenseAppId)
                {
                    ApplicationArea = All;
                    Caption = 'Application ID for License';
                    ToolTip = 'Enter the application GUID for license generation.';
                }
                field(LicenseCustomer; LicenseCustomer)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Enter the customer name for the license.';
                }
                field(LicenseValidFrom; LicenseValidFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Valid From (YYYY-MM-DD)';
                    ToolTip = 'Enter the license start date.';
                }
                field(LicenseValidTo; LicenseValidTo)
                {
                    ApplicationArea = All;
                    Caption = 'Valid To (YYYY-MM-DD)';
                    ToolTip = 'Enter the license end date.';
                }
                field(LicenseFeatures; LicenseFeatures)
                {
                    ApplicationArea = All;
                    Caption = 'Licensed Features';
                    ToolTip = 'Enter comma-separated feature list.';
                }
            }
            group(Validation)
            {
                Caption = 'License Validation Commands';
                field(ValidateLicenseId; ValidateLicenseId)
                {
                    ApplicationArea = All;
                    Caption = 'License ID to Validate';
                    ToolTip = 'Enter the license GUID to validate.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ApplicationCLI)
            {
                Caption = 'Application CLI Commands';
                action(CLI_RegisterApp)
                {
                    ApplicationArea = All;
                    Caption = 'Register Application';
                    Image = New;
                    ToolTip = 'Register a new application using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        ValidateAppInput();
                        LicenseManagement.CLI_RegisterApplication(NewAppId, NewAppName, NewPublisher, NewVersion, NewDescription);
                    end;
                }
                action(CLI_ListApps)
                {
                    ApplicationArea = All;
                    Caption = 'List Applications';
                    Image = ShowList;
                    ToolTip = 'List all applications using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        LicenseManagement.CLI_ListApplications();
                    end;
                }
            }
            group(LicenseCLI)
            {
                Caption = 'License CLI Commands';
                action(CLI_GenerateLicense)
                {
                    ApplicationArea = All;
                    Caption = 'Generate License';
                    Image = Certificate;
                    ToolTip = 'Generate a license using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        ValidateLicenseInput();
                        LicenseManagement.CLI_GenerateLicense(LicenseAppId, LicenseCustomer, LicenseValidFrom, LicenseValidTo, LicenseFeatures);
                    end;
                }
                action(CLI_ListLicenses)
                {
                    ApplicationArea = All;
                    Caption = 'List Licenses';
                    Image = ShowList;
                    ToolTip = 'List all licenses using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        LicenseManagement.CLI_ListLicenses();
                    end;
                }
                action(CLI_ValidateLicense)
                {
                    ApplicationArea = All;
                    Caption = 'Validate License';
                    Image = ValidateEmailLoggingSetup;
                    ToolTip = 'Validate a license using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        if ValidateLicenseId = '' then
                            Error('Please enter a License ID to validate.');
                        LicenseManagement.CLI_ValidateLicense(ValidateLicenseId);
                    end;
                }
            }
            group(SystemCLI)
            {
                Caption = 'System CLI Commands';
                action(CLI_SystemStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Show System Status';
                    Image = Status;
                    ToolTip = 'Show system status using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                    begin
                        LicenseManagement.CLI_ShowSystemStatus();
                    end;
                }
                action(CLI_GenerateKey)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Signing Key';
                    Image = EncryptionKeys;
                    ToolTip = 'Generate a new signing key using CLI interface.';

                    trigger OnAction()
                    var
                        LicenseManagement: Codeunit "License Management";
                        KeyId: Text;
                        ExpirationDate: Text;
                    begin
                        KeyId := StrSubstNo('CLI-KEY-%1', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2>'));
                        ExpirationDate := Format(CalcDate('<+5Y>', Today), 0, '<Year4>-<Month,2>-<Day,2>');
                        LicenseManagement.CLI_GenerateSigningKey(KeyId, ExpirationDate);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(OpenLicenseCenter)
            {
                ApplicationArea = All;
                Caption = 'Open License Management Center';
                Image = Setup;
                ToolTip = 'Open the main license management interface.';

                trigger OnAction()
                var
                    LicenseManagementCenter: Page "License Management Center";
                begin
                    LicenseManagementCenter.Run();
                end;
            }
        }
    }

    var
        NewAppId: Text;
        NewAppName: Text;
        NewPublisher: Text;
        NewVersion: Text;
        NewDescription: Text;
        LicenseAppId: Text;
        LicenseCustomer: Text;
        LicenseValidFrom: Text;
        LicenseValidTo: Text;
        LicenseFeatures: Text;
        ValidateLicenseId: Text;

    trigger OnOpenPage()
    begin
        // Set default values for demonstration
        NewAppId := Format(CreateGuid());
        NewAppName := 'Sample BC Extension';
        NewPublisher := 'Your Company';
        NewVersion := '1.0.0.0';
        NewDescription := 'Sample Business Central extension for licensing demo';
        
        LicenseCustomer := 'Demo Customer Ltd.';
        LicenseValidFrom := Format(Today, 0, '<Year4>-<Month,2>-<Day,2>');
        LicenseValidTo := Format(CalcDate('<+1Y>', Today), 0, '<Year4>-<Month,2>-<Day,2>');
        LicenseFeatures := 'Full Access,Premium Features,Advanced Reports';
    end;

    /// <summary>
    /// Validates application input fields.
    /// </summary>
    local procedure ValidateAppInput()
    begin
        if NewAppId = '' then
            Error('Please enter an Application ID.');
        if NewAppName = '' then
            Error('Please enter an Application Name.');
        if NewPublisher = '' then
            Error('Please enter a Publisher.');
        if NewVersion = '' then
            Error('Please enter a Version.');
    end;

    /// <summary>
    /// Validates license input fields.
    /// </summary>
    local procedure ValidateLicenseInput()
    begin
        if LicenseAppId = '' then
            Error('Please enter an Application ID for the license.');
        if LicenseCustomer = '' then
            Error('Please enter a Customer Name.');
        if LicenseValidFrom = '' then
            Error('Please enter a Valid From date.');
        if LicenseValidTo = '' then
            Error('Please enter a Valid To date.');
    end;
}