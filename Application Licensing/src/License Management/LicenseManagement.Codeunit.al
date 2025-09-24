namespace ApplicationLicensing.Codeunit;

using ApplicationLicensing.Enums;
using ApplicationLicensing.Tables;
using System.Reflection;

/// <summary>
/// Codeunit License Management (ID 80503).
/// Main coordinator for all licensing operations and CLI interface.
/// </summary>
codeunit 80503 "License Management"
{
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
        DefaultKeyId := DefaultKeyIdPrefixLbl + 'KEY';
        if not CryptoKeyManager.GenerateKeyPair(DefaultKeyId, "Crypto Key Type"::"Signing Key", CalcDate('<+5Y>', Today)) then
            Error(FailedGenerateDefaultSigningKeyErr);

        Message(LicensingSystemInitializedMsg, DefaultKeyId);
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
            Error(InvalidGuidAppIdErr, AppId);

        if ApplicationManager.RegisterApplication(AppGuid, CopyStr(AppName, 1, 100), CopyStr(Publisher, 1, 100), CopyStr(Version, 1, 20), CopyStr(Description, 1, 250)) then
            Message(ApplicationRegisteredSuccessMsg, AppName)
        else
            Error(FailedRegisterApplicationErr, AppName);
    end;

    /// <summary>
    /// Command-line interface: List all applications.
    /// </summary>
    procedure CLI_ListApplications()
    var
        ApplicationRegistry: Record "Application Registry";
        OutputText: Text;
    begin
        OutputText := RegisteredApplicationsLbl + NewLine() + NewLine();

        if ApplicationRegistry.FindSet() then begin
            repeat
                OutputText += StrSubstNo(ApplicationDetailsFormatLbl,
                                       ApplicationRegistry."App ID",
                                       ApplicationRegistry."App Name",
                                       ApplicationRegistry.Publisher,
                                       ApplicationRegistry.Version,
                                       ApplicationRegistry.Active,
                                       ApplicationRegistry."Created Date");
            until ApplicationRegistry.Next() = 0;
        end else begin
            OutputText += NoApplicationsRegisteredLbl;
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
        SuccesfullMsg: Label 'License generated successfully.';
        AppGuid: Guid;
        ValidFrom: Date;
        ValidTo: Date;
        LicenseId: Guid;
    begin
        if not Evaluate(AppGuid, AppId) then
            Error(InvalidGuidAppIdErr, AppId);

        if not Evaluate(ValidFrom, ValidFromDate) then
            Error(InvalidDateFormatValidFromErr, ValidFromDate);

        if not Evaluate(ValidTo, ValidToDate) then
            Error(InvalidDateFormatValidToErr, ValidToDate);

        LicenseId := LicenseGenerator.GenerateLicense(AppGuid, CopyStr(CustomerName, 1, 100), ValidFrom, ValidTo, CopyStr(Features, 1, 250));

        if not IsNullGuid(LicenseId) then
            Message(SuccesfullMsg + NewLine() + LicenseIDMsg, LicenseId)
        else
            Error(FailedGenerateLicenseErr);
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
            Error(InvalidGuidLicenseIdErr, LicenseId);

        IsValid := LicenseGenerator.ValidateLicense(LicenseGuid);

        if LicenseRegistry.Get(LicenseGuid) then
            Message(LicenseValidationResultDetailsLbl,
                   LicenseId,
                   LicenseRegistry.Status,
                   IsValid,
                   LicenseRegistry."Last Validated",
                   LicenseRegistry."Validation Result")
        else
            Error(LicenseNotFoundErr, LicenseId);
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
        OutputText := GeneratedLicensesLbl + NewLine() + NewLine();

        if LicenseRegistry.FindSet() then begin
            repeat
                ApplicationRegistry.Get(LicenseRegistry."App ID");
                OutputText += StrSubstNo(LicenseDetailsFormatLbl,
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
            OutputText += NoLicensesGeneratedLbl;
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
            Error(InvalidDateFormatExpirationErr, ExpirationDate);

        if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Signing Key", ExpiresDate) then
            Message(SigningKeyGeneratedSuccessMsg, KeyId)
        else
            Error(FailedGenerateSigningKeyErr, KeyId);
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

        StatusText := SystemStatusHeaderLbl + NewLine() + NewLine() +
                     StrSubstNo(ActiveApplicationsLbl, ActiveApps) + NewLine() +
                     StrSubstNo(ActiveLicensesLbl, TotalLicenses) + NewLine() +
                     StrSubstNo(ActiveCryptoKeysLbl, ActiveKeys) + NewLine() +
                     StrSubstNo(SigningKeyAvailableLbl, CryptoKeyManager.IsSigningKeyAvailable()) + NewLine() +
                     StrSubstNo(SystemTimeLbl, CurrentDateTime);

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
    local procedure NewLine(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.NewLine());
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
        ToFolder: Text;
        DialogTitle: Text;
        ResultFilePath: Text;
    begin
        if not LicenseRegistry.Get(LicenseId) then
            Error('License not found: %1', LicenseId);

        TempBlob.FromRecord(LicenseRegistry, LicenseRegistry.FieldNo("License File"));
        TempBlob.CreateInStream(InStream);

        DownloadFromStream(InStream, 'Export License', '', '', FileName);
        // In real implementation, use proper file export functionality
        Message(LicenseFileReadyForExportMsg, FileName);
    end;

    var
        // Labels for translatable text
        FailedGenerateDefaultSigningKeyErr: Label 'Failed to generate default signing key.';
        LicensingSystemInitializedMsg: Label 'Licensing system initialized successfully with signing key: %1';
        InvalidGuidAppIdErr: Label 'Invalid GUID format for App ID: %1';
        ApplicationRegisteredSuccessMsg: Label 'Application registered successfully: %1';
        FailedRegisterApplicationErr: Label 'Failed to register application: %1';
        RegisteredApplicationsLbl: Label 'Registered Applications:';
        NoApplicationsRegisteredLbl: Label 'No applications registered.';
        GeneratedLicensesLbl: Label 'Generated Licenses:';
        NoLicensesGeneratedLbl: Label 'No licenses generated.';
        InvalidGuidLicenseIdErr: Label 'Invalid GUID format for License ID: %1';
        InvalidDateFormatValidFromErr: Label 'Invalid date format for Valid From: %1 (expected YYYY-MM-DD)';
        InvalidDateFormatValidToErr: Label 'Invalid date format for Valid To: %1 (expected YYYY-MM-DD)';
        LicenseGeneratedSuccessMsg: Label 'License generated successfully.\\License ID: %1';
        FailedGenerateLicenseErr: Label 'Failed to generate license.';
        LicenseNotFoundErr: Label 'License not found: %1';
        InvalidDateFormatExpirationErr: Label 'Invalid date format for expiration: %1 (expected YYYY-MM-DD)';
        SigningKeyGeneratedSuccessMsg: Label 'Signing key generated successfully: %1';
        FailedGenerateSigningKeyErr: Label 'Failed to generate signing key: %1';
        LicenseFileReadyForExportMsg: Label 'License file content ready for export to: %1';
        LicenseIDMsg: Label 'License ID: %1';
        LicenseValidationResultMsg: Label 'License Validation Result:';
        SystemStatusHeaderLbl: Label 'Licensing System Status:';
        ActiveApplicationsLbl: Label 'Active Applications: %1';
        ActiveLicensesLbl: Label 'Active Licenses: %1';
        ActiveCryptoKeysLbl: Label 'Active Crypto Keys: %1';
        SigningKeyAvailableLbl: Label 'Signing Key Available: %1';
        SystemTimeLbl: Label 'System Time: %1';

        // Format labels for complex output (with locked parts)
        ApplicationDetailsFormatLbl: Label 'ID: %1\\Name: %2\\Publisher: %3\\Version: %4\\Active: %5\\Created: %6\\';
        LicenseDetailsFormatLbl: Label 'License ID: %1\\Application: %2\\Customer: %3\\Valid From: %4\\Valid To: %5\\Status: %6\\Features: %7\\Created: %8\\';
        LicenseValidationResultDetailsLbl: Label 'License Validation Result:\\License ID: %1\\Status: %2\\Valid: %3\\Last Validation: %4\\Validation Result: %5';

        // Locked labels for technical strings
        DefaultKeyIdPrefixLbl: Label 'DEFAULT-SIGN-', Locked = true;
        DateTimeFormatLbl: Label '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>', Locked = true;
}