namespace ApplicationLicensing.Codeunit;

using ApplicationLicensing.Enums;
using ApplicationLicensing.Tables;

/// <summary>
/// Codeunit License Management (ID 80503).
/// Main coordinator for all licensing operations and CLI interface.
/// </summary>
codeunit 80503 "License Management"
{
    trigger OnRun()
    begin
    end;

    var
        ApplicationManager: Codeunit "Application Manager";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
        LicenseGenerator: Codeunit "License Generator";

    /// <summary>
    /// Initializes the licensing system with default setup.
    /// </summary>
    procedure InitializeLicensingSystem(): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
        DefaultKeyId: Code[20];
    begin
        // Check if signing key exists
        if CryptoKeyManager.IsSigningKeyAvailable() then
            exit(true);

        // Generate default signing key
        DefaultKeyId := 'DEFAULT-SIGN-KEY';
        if not CryptoKeyManager.GenerateKeyPair(DefaultKeyId, "Crypto Key Type"::"Signing Key", CalcDate('<+5Y>', Today)) then
            Error('Failed to generate default signing key.');

        Message('Licensing system initialized successfully with signing key: %1', DefaultKeyId);
        exit(true);
    end;

    /// <summary>
    /// Command-line interface: Register a new application.
    /// </summary>
    /// <param name="AppId">Application identifier (GUID format).</param>
    /// <param name="AppName">Application name.</param>
    /// <param name="Publisher">Publisher name.</param>
    /// <param name="Version">Version string.</param>
    /// <param name="Description">Optional description.</param>
    procedure CLI_RegisterApplication(AppId: Text; AppName: Text; Publisher: Text; Version: Text; Description: Text)
    var
        AppGuid: Guid;
    begin
        if not Evaluate(AppGuid, AppId) then
            Error('Invalid GUID format for App ID: %1', AppId);

        if ApplicationManager.RegisterApplication(AppGuid, CopyStr(AppName, 1, 100), CopyStr(Publisher, 1, 100), CopyStr(Version, 1, 20), CopyStr(Description, 1, 250)) then
            Message('Application registered successfully: %1', AppName)
        else
            Error('Failed to register application: %1', AppName);
    end;

    /// <summary>
    /// Command-line interface: List all applications.
    /// </summary>
    procedure CLI_ListApplications()
    var
        ApplicationRegistry: Record "Application Registry";
        OutputText: Text;
    begin
        OutputText := 'Registered Applications:' + NewLine() + NewLine();

        if ApplicationRegistry.FindSet() then begin
            repeat
                OutputText += StrSubstNo('ID: %1' + NewLine() +
                                       'Name: %2' + NewLine() +
                                       'Publisher: %3' + NewLine() +
                                       'Version: %4' + NewLine() +
                                       'Active: %5' + NewLine() +
                                       'Created: %6' + NewLine() + NewLine(),
                                       ApplicationRegistry."App ID",
                                       ApplicationRegistry."App Name",
                                       ApplicationRegistry.Publisher,
                                       ApplicationRegistry.Version,
                                       ApplicationRegistry.Active,
                                       ApplicationRegistry."Created Date");
            until ApplicationRegistry.Next() = 0;
        end else begin
            OutputText += 'No applications registered.';
        end;

        Message(OutputText);
    end;

    /// <summary>
    /// Command-line interface: Generate a new license.
    /// </summary>
    /// <param name="AppId">Application identifier.</param>
    /// <param name="CustomerName">Customer name.</param>
    /// <param name="ValidFromDate">Start date (YYYY-MM-DD format).</param>
    /// <param name="ValidToDate">End date (YYYY-MM-DD format).</param>
    /// <param name="Features">Comma-separated feature list.</param>
    procedure CLI_GenerateLicense(AppId: Text; CustomerName: Text; ValidFromDate: Text; ValidToDate: Text; Features: Text)
    var
        AppGuid: Guid;
        ValidFrom: Date;
        ValidTo: Date;
        LicenseId: Guid;
    begin
        if not Evaluate(AppGuid, AppId) then
            Error('Invalid GUID format for App ID: %1', AppId);

        if not Evaluate(ValidFrom, ValidFromDate) then
            Error('Invalid date format for Valid From: %1 (expected YYYY-MM-DD)', ValidFromDate);

        if not Evaluate(ValidTo, ValidToDate) then
            Error('Invalid date format for Valid To: %1 (expected YYYY-MM-DD)', ValidToDate);

        LicenseId := LicenseGenerator.GenerateLicense(AppGuid, CopyStr(CustomerName, 1, 100), ValidFrom, ValidTo, CopyStr(Features, 1, 250));

        if not IsNullGuid(LicenseId) then
            Message('License generated successfully.' + NewLine() + 'License ID: %1', LicenseId)
        else
            Error('Failed to generate license.');
    end;

    /// <summary>
    /// Command-line interface: Validate a license.
    /// </summary>
    /// <param name="LicenseId">License identifier to validate.</param>
    procedure CLI_ValidateLicense(LicenseId: Text)
    var
        LicenseGuid: Guid;
        IsValid: Boolean;
        LicenseRegistry: Record "License Registry";
    begin
        if not Evaluate(LicenseGuid, LicenseId) then
            Error('Invalid GUID format for License ID: %1', LicenseId);

        IsValid := LicenseGenerator.ValidateLicense(LicenseGuid);

        if LicenseRegistry.Get(LicenseGuid) then
            Message('License Validation Result:' + NewLine() +
                   'License ID: %1' + NewLine() +
                   'Status: %2' + NewLine() +
                   'Valid: %3' + NewLine() +
                   'Last Validation: %4' + NewLine() +
                   'Validation Result: %5',
                   LicenseId,
                   LicenseRegistry.Status,
                   IsValid,
                   LicenseRegistry."Last Validated",
                   LicenseRegistry."Validation Result")
        else
            Error('License not found: %1', LicenseId);
    end;

    /// <summary>
    /// Command-line interface: List all licenses.
    /// </summary>
    procedure CLI_ListLicenses()
    var
        LicenseRegistry: Record "License Registry";
        ApplicationRegistry: Record "Application Registry";
        OutputText: Text;
    begin
        OutputText := 'Generated Licenses:' + NewLine() + NewLine();

        if LicenseRegistry.FindSet() then begin
            repeat
                ApplicationRegistry.Get(LicenseRegistry."App ID");
                OutputText += StrSubstNo('License ID: %1' + NewLine() +
                                       'Application: %2' + NewLine() +
                                       'Customer: %3' + NewLine() +
                                       'Valid From: %4' + NewLine() +
                                       'Valid To: %5' + NewLine() +
                                       'Status: %6' + NewLine() +
                                       'Features: %7' + NewLine() +
                                       'Created: %8' + NewLine() + NewLine(),
                                       LicenseRegistry."License ID",
                                       ApplicationRegistry."App Name",
                                       LicenseRegistry."Customer Name",
                                       LicenseRegistry."Valid From",
                                       LicenseRegistry."Valid To",
                                       LicenseRegistry.Status,
                                       LicenseRegistry.Features,
                                       LicenseRegistry."Created Date");
            until LicenseRegistry.Next() = 0;
        end else begin
            OutputText += 'No licenses generated.';
        end;

        Message(OutputText);
    end;

    /// <summary>
    /// Command-line interface: Generate a new signing key.
    /// </summary>
    /// <param name="KeyId">Identifier for the new key.</param>
    /// <param name="ExpirationDate">Key expiration date (YYYY-MM-DD format).</param>
    procedure CLI_GenerateSigningKey(KeyId: Text; ExpirationDate: Text)
    var
        ExpiresDate: Date;
    begin
        if not Evaluate(ExpiresDate, ExpirationDate) then
            Error('Invalid date format for expiration: %1 (expected YYYY-MM-DD)', ExpirationDate);

        if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Signing Key", ExpiresDate) then
            Message('Signing key generated successfully: %1', KeyId)
        else
            Error('Failed to generate signing key: %1', KeyId);
    end;

    /// <summary>
    /// Command-line interface: Show system status.
    /// </summary>
    procedure CLI_ShowSystemStatus()
    var
        ApplicationRegistry: Record "Application Registry";
        LicenseRegistry: Record "License Registry";
        CryptoKeyStorage: Record "Crypto Key Storage";
        ActiveApps: Integer;
        TotalLicenses: Integer;
        ActiveKeys: Integer;
        StatusText: Text;
    begin
        ApplicationRegistry.SetRange(Active, true);
        ActiveApps := ApplicationRegistry.Count;

        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
        TotalLicenses := LicenseRegistry.Count;

        CryptoKeyStorage.SetRange(Active, true);
        ActiveKeys := CryptoKeyStorage.Count;

        StatusText := 'Licensing System Status:' + NewLine() + NewLine() +
                     StrSubstNo('Active Applications: %1', ActiveApps) + NewLine() +
                     StrSubstNo('Active Licenses: %1', TotalLicenses) + NewLine() +
                     StrSubstNo('Active Crypto Keys: %1', ActiveKeys) + NewLine() +
                     StrSubstNo('Signing Key Available: %1', CryptoKeyManager.IsSigningKeyAvailable()) + NewLine() +
                     StrSubstNo('System Time: %1', CurrentDateTime);

        Message(StatusText);
    end;

    /// <summary>
    /// Event handler for license deletion to clean up related data.
    /// </summary>
    /// <param name="LicenseId">The deleted license identifier.</param>
    [IntegrationEvent(false, false)]
    procedure OnLicenseDeleted(LicenseId: Guid)
    begin
        // Event for extensions to handle license deletion
    end;

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    local procedure NewLine(): Char
    begin
        exit(10);
    end;

    /// <summary>
    /// Exports a license file for a customer.
    /// </summary>
    /// <param name="LicenseId">The license identifier to export.</param>
    /// <param name="FileName">The filename for the export.</param>
    procedure ExportLicenseFile(LicenseId: Guid; FileName: Text)
    var
        LicenseRegistry: Record "License Registry";
        TempBlob: Codeunit System.Utilities."Temp Blob";
        InStream: InStream;
    begin
        if not LicenseRegistry.Get(LicenseId) then
            Error('License not found: %1', LicenseId);

        TempBlob.FromRecord(LicenseRegistry, LicenseRegistry.FieldNo("License File"));
        TempBlob.CreateInStream(InStream);

        // In real implementation, use proper file export functionality
        Message('License file content ready for export to: %1', FileName);
    end;
}