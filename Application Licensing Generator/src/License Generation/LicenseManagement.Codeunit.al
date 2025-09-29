namespace ApplicationLicensing.Generator.Codeunit;

using System.Reflection;
using ApplicationLicensing.Base.Codeunit;
using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Generator.Enums;

/// <summary>
/// Codeunit License Management (ID 80503).
/// Main coordinator for all licensing operations and CLI interface.
/// </summary>
codeunit 80528 "License Management"
{
    Permissions = tabledata "Application Registry" = r,
                  tabledata "License Registry" = r,
                  tabledata "Crypto Key Storage" = r;

    var
        ApplicationManager: Codeunit "Application Manager";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
        LicenseGenerator: Codeunit "License Generator";

    /// <summary>
    /// Initializes the licensing system with default setup.
    /// </summary>
    /// <returns>True if initialization was successful.</returns>
    procedure InitializeLicensingSystem(): Boolean
    var
        DefaultKeyId: Code[20];
    begin
        // Check if signing key exists
        if CryptoKeyManager.IsSigningKeyAvailable() then
            exit(true);

        // Generate default signing key
        DefaultKeyId := DefaultKeyIdPrefixLbl + 'KEY';
        if not CryptoKeyManager.GenerateKeyPair(DefaultKeyId, "Crypto Key Type"::"Signing Key", CalcDate('<+5Y>', Today())) then
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

        if ApplicationRegistry.FindSet() then
            repeat
                OutputText += StrSubstNo(ApplicationDetailsFormatLbl,
                                       ApplicationRegistry."App ID",
                                       ApplicationRegistry."App Name",
                                       ApplicationRegistry.Publisher,
                                       ApplicationRegistry.Version,
                                       ApplicationRegistry.Active,
                                       ApplicationRegistry."Created Date");
            until ApplicationRegistry.Next() = 0
        else
            OutputText += NoApplicationsRegisteredLbl;

        Message(OutputText);
    end;

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    /// <returns>Newline character.</returns>
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
    begin
        if not LicenseRegistry.Get(LicenseId) then
            Error(CreateErrorInfo(ErrorType::Client, Verbosity::Normal, StrSubstNo(LicenseNotFoundErr, LicenseId), false));

        TempBlob.FromRecord(LicenseRegistry, LicenseRegistry.FieldNo("License File"));
        TempBlob.CreateInStream(InStream);

        DownloadFromStream(InStream, 'Export License', '', '', FileName);
        // In real implementation, use proper file export functionality
        Message(LicenseFileReadyForExportMsg, FileName);
    end;

    internal procedure CreateErrorInfo(ErrType: ErrorType; ErrVerbosity: Verbosity; ErrorMessage: Text; Collectable: Boolean) ErrInfo: ErrorInfo
    begin
        ErrInfo.ErrorType(ErrType);
        ErrInfo.Verbosity(ErrVerbosity);
        ErrInfo.Message(ErrorMessage);
        ErrInfo.Collectible := Collectable;
    end;

    var
        // Labels for translatable text
        FailedGenerateDefaultSigningKeyErr: Label 'Failed to generate default signing key.';
        LicensingSystemInitializedMsg: Label 'Licensing system initialized successfully with signing key: %1', Comment = '%1 = Key ID';
        InvalidGuidAppIdErr: Label 'Invalid GUID format for App ID: %1', Comment = '%1 = App ID';
        ApplicationRegisteredSuccessMsg: Label 'Application registered successfully: %1', Comment = '%1 = App ID';
        FailedRegisterApplicationErr: Label 'Failed to register application: %1', Comment = '%1 = App ID';
        RegisteredApplicationsLbl: Label 'Registered Applications:';
        NoApplicationsRegisteredLbl: Label 'No applications registered.';
        GeneratedLicensesLbl: Label 'Generated Licenses:';
        NoLicensesGeneratedLbl: Label 'No licenses generated.';
        InvalidGuidLicenseIdErr: Label 'Invalid GUID format for License ID: %1', Comment = '%1 = License ID';
        InvalidDateFormatValidFromErr: Label 'Invalid date format for Valid From: %1 (expected YYYY-MM-DD)', Comment = '%1 = Valid From date';
        InvalidDateFormatValidToErr: Label 'Invalid date format for Valid To: %1 (expected YYYY-MM-DD)', Comment = '%1 = Valid To date';
        FailedGenerateLicenseErr: Label 'Failed to generate license.';
        LicenseNotFoundErr: Label 'License not found: %1', Comment = '%1 = License ID';
        InvalidDateFormatExpirationErr: Label 'Invalid date format for expiration: %1 (expected YYYY-MM-DD)', Comment = '%1 = Expiration date';
        SigningKeyGeneratedSuccessMsg: Label 'Signing key generated successfully: %1', Comment = '%1 = Key ID';
        FailedGenerateSigningKeyErr: Label 'Failed to generate signing key: %1', Comment = '%1 = Key ID';
        LicenseFileReadyForExportMsg: Label 'License file content ready for export to: %1', Comment = '%1 = File Name';
        LicenseIDMsg: Label 'License ID: %1', Comment = '%1 = License ID';
        SystemStatusHeaderLbl: Label 'Licensing System Status:';
        ActiveApplicationsLbl: Label 'Active Applications: %1', Comment = '%1 = Number of active applications';
        ActiveLicensesLbl: Label 'Active Licenses: %1', Comment = '%1 = Number of active licenses';
        ActiveCryptoKeysLbl: Label 'Active Crypto Keys: %1', Comment = '%1 = Number of active crypto keys';
        SigningKeyAvailableLbl: Label 'Signing Key Available: %1', Comment = '%1 = Signing key availability';
        SystemTimeLbl: Label 'System Time: %1', Comment = '%1 = System time';

        // Format labels for complex output (with locked parts)
        ApplicationDetailsFormatLbl: Label 'ID: %1\\Name: %2\\Publisher: %3\\Version: %4\\Active: %5\\Created: %6\\', Comment = '%1 = App ID, %2 = App Name, %3 = Publisher, %4 = Version, %5 = Active Status, %6 = Created Date';
        LicenseDetailsFormatLbl: Label 'License ID: %1\\Application: %2\\Customer: %3\\Valid From: %4\\Valid To: %5\\Status: %6\\Features: %7\\Created: %8\\', Comment = '%1 = License ID, %2 = App ID, %3 = Customer, %4 = Valid From, %5 = Valid To, %6 = Status, %7 = Features, %8 = Created Date';
        LicenseValidationResultDetailsLbl: Label 'License Validation Result:\\License ID: %1\\Status: %2\\Valid: %3\\Last Validation: %4\\Validation Result: %5', Comment = '%1 = License ID, %2 = Status, %3 = Valid, %4 = Last Validation, %5 = Validation Result';

        // Locked labels for technical strings
        DefaultKeyIdPrefixLbl: Label 'DEFAULT-SIGN-', Locked = true;
}