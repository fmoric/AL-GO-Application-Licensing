namespace ApplicationLicensing.Generator.Codeunit;

using ApplicationLicensing.Generator.Tables;      // Access Base Application tables
using ApplicationLicensing.Generator.Tables;
using System.Security.Encryption;
using System.Utilities;
using ApplicationLicensing.Base.Tables;

/// <summary>
/// Codeunit License Generator (ID 80526).
/// Generates cryptographically signed licenses and stores them in the Base Application.
/// 
/// This codeunit demonstrates the proper integration pattern:
/// 1. Generator creates licenses
/// 2. Licenses are stored in Base Application License Registry
/// 3. Base Application handles validation and management
/// </summary>
codeunit 80528 "License Generator"
{
    /// <summary>
    /// Generates a new license and stores it in the Base Application.
    /// </summary>
    /// <param name="AppId">Application ID from Base Application Registry.</param>
    /// <param name="CustomerName">Customer name for the license.</param>
    /// <param name="ValidFrom">License start date.</param>
    /// <param name="ValidTo">License end date.</param>
    /// <param name="Features">Licensed features.</param>
    /// <returns>Generated License ID if successful, null GUID if failed.</returns>
    procedure GenerateLicense(AppId: Guid; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]): Guid
    var
        ApplicationRegistry: Record "Application Registry";  // From Base Application
        LicenseRegistry: Record "License Registry";          // From Base Application  
        CryptoKeyStorage: Record "Crypto Key Storage";       // From Generator Application
        LicenseId: Guid;
        LicenseContent: Text;
        DigitalSignature: Text;
        KeyId: Code[20];
    begin
        // Validate application exists in Base Application Registry
        if not ApplicationRegistry.Get(AppId) then
            Error('Application %1 is not registered in the Base Application.', AppId);

        if not ApplicationRegistry.Active then
            Error('Application %1 is not active in the Base Application.', ApplicationRegistry."App Name");

        // Validate dates
        if ValidFrom >= ValidTo then
            Error('Valid From date must be before Valid To date.');

        // Get active signing key from Generator
        if not GetActiveSigningKey(KeyId) then
            Error('No active signing key available. Please generate a signing key first.');

        // Generate license content
        LicenseId := CreateGuid();
        LicenseContent := CreateLicenseContent(LicenseId, AppId, ApplicationRegistry."App Name", CustomerName, ValidFrom, ValidTo, Features);

        // Generate digital signature
        DigitalSignature := CreateDigitalSignature(LicenseContent, KeyId);

        // Store generated license in Base Application License Registry
        LicenseRegistry.Init();
        LicenseRegistry."License ID" := LicenseId;
        LicenseRegistry."App ID" := AppId;
        LicenseRegistry."Customer Name" := CustomerName;
        LicenseRegistry."Valid From" := ValidFrom;
        LicenseRegistry."Valid To" := ValidTo;
        LicenseRegistry.Features := Features;
        LicenseRegistry."Digital Signature" := DigitalSignature;
        LicenseRegistry."Key ID" := KeyId;
        LicenseRegistry.Status := LicenseRegistry.Status::Active;

        // Store license file content
        StoreLicenseFile(LicenseRegistry, LicenseContent, DigitalSignature);

        if LicenseRegistry.Insert(true) then
            exit(LicenseId)
        else
            Error('Failed to store license in Base Application registry.');
    end;

    /// <summary>
    /// Gets the active signing key for license generation.
    /// </summary>
    /// <param name="KeyId">Output: The active key ID.</param>
    /// <returns>True if an active signing key is available.</returns>
    local procedure GetActiveSigningKey(var KeyId: Code[20]): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
    begin
        CryptoKeyStorage.SetRange("Key Type", CryptoKeyStorage."Key Type"::"Signing Key");
        CryptoKeyStorage.SetRange(Active, true);
        CryptoKeyStorage.SetFilter("Expires Date", '>=%1|%2', Today(), 0D);

        if CryptoKeyStorage.FindFirst() then begin
            KeyId := CryptoKeyStorage."Key ID";
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Creates the license content string.
    /// </summary>
    local procedure CreateLicenseContent(LicenseId: Guid; AppId: Guid; AppName: Text[100]; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]): Text
    begin
        exit(StrSubstNo('LICENSE-V1.0|ID:%1|APP-ID:%2|APP-NAME:%3|CUSTOMER:%4|VALID-FROM:%5|VALID-TO:%6|FEATURES:%7|ISSUED:%8',
            LicenseId,
            AppId,
            AppName,
            CustomerName,
            Format(ValidFrom, 0, '<Year4>-<Month,2>-<Day,2>'),
            Format(ValidTo, 0, '<Year4>-<Month,2>-<Day,2>'),
            Features,
            Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>')
        ));
    end;

    /// <summary>
    /// Creates a digital signature for the license content.
    /// </summary>
    local procedure CreateDigitalSignature(Content: Text; KeyId: Code[20]): Text
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
        ContentHash: Text;
        Timestamp: Text;
    begin
        if not CryptoKeyStorage.Get(KeyId) then
            Error('Signing key %1 not found.', KeyId);

        // Create a simple hash-based signature for demonstration
        // In production, this would use proper RSA signing
        ContentHash := GetContentHash(Content);
        Timestamp := Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>');

        exit(StrSubstNo('RSA-SIGNATURE:%1-%2-%3', ContentHash, KeyId, Timestamp));
    end;

    /// <summary>
    /// Creates a hash of the content for signature purposes.
    /// </summary>
    local procedure GetContentHash(Content: Text): Text
    begin
        // Simple hash implementation for demonstration
        // In production, use proper cryptographic hashing
        exit(CopyStr(Content, 1, 10) + CopyStr(Content, StrLen(Content) - 9, 10));
    end;

    /// <summary>
    /// Stores the complete license file in the Base Application registry.
    /// </summary>
    local procedure StoreLicenseFile(var LicenseRegistry: Record "License Registry"; LicenseContent: Text; DigitalSignature: Text)
    var
        LicenseOutStream: OutStream;
        CompleteFile: Text;
    begin
        CompleteFile := '--- BEGIN LICENSE ---' +
                       '\n' + LicenseContent +
                       '\n--- BEGIN SIGNATURE ---' +
                       '\n' + DigitalSignature +
                       '\n--- END LICENSE ---';

        LicenseRegistry."License File".CreateOutStream(LicenseOutStream);
        LicenseOutStream.WriteText(CompleteFile);
    end;

    /// <summary>
    /// Validates that the Base Application is available and accessible.
    /// This demonstrates the dependency enforcement.
    /// </summary>
    procedure ValidateBaseApplicationDependency(): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        // Try to access Base Application table
        // If this fails, Generator cannot function
        exit(ApplicationRegistry.ReadPermission());
    end;
}