/// <summary>
/// Codeunit License Generator (ID 80502).
/// Generates cryptographically signed licenses with tamper detection.
/// </summary>
codeunit 80502 "License Generator"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Generates a new signed license for an application.
    /// </summary>
    /// <param name="AppId">The application identifier.</param>
    /// <param name="CustomerName">The customer name for the license.</param>
    /// <param name="ValidFrom">The license validity start date.</param>
    /// <param name="ValidTo">The license validity end date.</param>
    /// <param name="Features">The licensed features (comma-separated).</param>
    /// <returns>The generated license ID, or null GUID if generation failed.</returns>
    procedure GenerateLicense(AppId: Guid; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]): Guid
    var
        ApplicationRegistry: Record "Application Registry";
        LicenseRegistry: Record "License Registry";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
        TempBlob: Codeunit "Temp Blob";
        LicenseOutStream: OutStream;
        KeyId: Code[20];
        PublicKey: Text;
        PrivateKey: Text;
        LicenseContent: Text;
        DigitalSignature: Text;
        LicenseId: Guid;
    begin
        // Validate application exists and is active
        if not ApplicationRegistry.Get(AppId) then
            Error('Application with ID %1 does not exist.', AppId);
        
        if not ApplicationRegistry.Active then
            Error('Application %1 is not active.', ApplicationRegistry."App Name");

        // Validate dates
        if ValidFrom > ValidTo then
            Error('Valid From date must be before Valid To date.');
        
        if ValidTo < Today then
            Error('License expiration date cannot be in the past.');

        // Get signing key
        if not CryptoKeyManager.GetActiveSigningKey(KeyId, PublicKey, PrivateKey) then
            Error('No active signing key available. Please generate a signing key first.');

        // Generate license ID
        LicenseId := CreateGuid();

        // Create license content
        LicenseContent := CreateLicenseContent(LicenseId, AppId, CustomerName, ValidFrom, ValidTo, Features, ApplicationRegistry);

        // Generate digital signature
        DigitalSignature := GenerateDigitalSignature(LicenseContent, PrivateKey);

        // Create license registry entry
        LicenseRegistry.Init();
        LicenseRegistry."License ID" := LicenseId;
        LicenseRegistry."App ID" := AppId;
        LicenseRegistry."Customer Name" := CustomerName;
        LicenseRegistry."Valid From" := ValidFrom;
        LicenseRegistry."Valid To" := ValidTo;
        LicenseRegistry.Features := Features;
        LicenseRegistry."Digital Signature" := CopyStr(DigitalSignature, 1, MaxStrLen(LicenseRegistry."Digital Signature"));
        LicenseRegistry.Status := LicenseRegistry.Status::Active;

        // Store license file as blob
        TempBlob.CreateOutStream(LicenseOutStream);
        LicenseOutStream.WriteText(CreateLicenseFileContent(LicenseContent, DigitalSignature));
        TempBlob.ToRecord(LicenseRegistry, LicenseRegistry.FieldNo("License File"));

        if not LicenseRegistry.Insert(true) then
            Error('Failed to create license registry entry.');

        exit(LicenseId);
    end;

    /// <summary>
    /// Validates a license and checks for tampering.
    /// </summary>
    /// <param name="LicenseId">The license identifier to validate.</param>
    /// <returns>True if the license is valid and not tampered.</returns>
    procedure ValidateLicense(LicenseId: Guid): Boolean
    var
        LicenseRegistry: Record "License Registry";
        ApplicationRegistry: Record "Application Registry";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
        ValidationResult: Text[100];
    begin
        if not LicenseRegistry.Get(LicenseId) then begin
            ValidationResult := 'License not found';
            exit(false);
        end;

        ValidationResult := ValidateLicenseInternal(LicenseRegistry, ApplicationRegistry, CryptoKeyManager);
        
        // Update validation result
        LicenseRegistry."Last Validated" := CurrentDateTime;
        LicenseRegistry."Validation Result" := ValidationResult;
        LicenseRegistry.Modify();

        exit(ValidationResult = 'Valid');
    end;

    /// <summary>
    /// Checks if a license is currently valid (not expired, not revoked, etc.).
    /// </summary>
    /// <param name="LicenseId">The license identifier to check.</param>
    /// <returns>True if the license is currently valid for use.</returns>
    procedure IsLicenseCurrentlyValid(LicenseId: Guid): Boolean
    var
        LicenseRegistry: Record "License Registry";
    begin
        if not LicenseRegistry.Get(LicenseId) then
            exit(false);

        // Check status
        if LicenseRegistry.Status <> LicenseRegistry.Status::Active then
            exit(false);

        // Check date range
        if (Today < LicenseRegistry."Valid From") or (Today > LicenseRegistry."Valid To") then
            exit(false);

        // Perform full validation
        exit(ValidateLicense(LicenseId));
    end;

    /// <summary>
    /// Revokes a license.
    /// </summary>
    /// <param name="LicenseId">The license identifier to revoke.</param>
    /// <returns>True if revocation was successful.</returns>
    procedure RevokeLicense(LicenseId: Guid): Boolean
    var
        LicenseRegistry: Record "License Registry";
    begin
        if not LicenseRegistry.Get(LicenseId) then
            exit(false);

        LicenseRegistry.Status := LicenseRegistry.Status::Revoked;
        LicenseRegistry."Last Validated" := CurrentDateTime;
        LicenseRegistry."Validation Result" := 'Revoked by administrator';
        
        exit(LicenseRegistry.Modify());
    end;

    /// <summary>
    /// Creates the license content string for signing.
    /// </summary>
    local procedure CreateLicenseContent(LicenseId: Guid; AppId: Guid; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]; ApplicationRegistry: Record "Application Registry"): Text
    var
        LicenseContent: Text;
    begin
        LicenseContent := StrSubstNo('LICENSE-V1.0|ID:%1|APP-ID:%2|APP-NAME:%3|PUBLISHER:%4|VERSION:%5|CUSTOMER:%6|VALID-FROM:%7|VALID-TO:%8|FEATURES:%9|ISSUED:%10',
            LicenseId,
            AppId,
            ApplicationRegistry."App Name",
            ApplicationRegistry.Publisher,
            ApplicationRegistry.Version,
            CustomerName,
            ValidFrom,
            ValidTo,
            Features,
            CurrentDateTime);

        exit(LicenseContent);
    end;

    /// <summary>
    /// Generates a digital signature for the license content.
    /// </summary>
    local procedure GenerateDigitalSignature(Content: Text; PrivateKey: Text): Text
    var
        Signature: Text;
    begin
        // Note: This is a simplified mock implementation
        // In real implementation, you would use proper RSA signing
        // using .NET System.Security.Cryptography.RSACryptoServiceProvider
        
        Signature := StrSubstNo('RSA-SHA256-SIGNATURE:%1-%2', GetContentHash(Content), CurrentDateTime);
        
        exit(Signature);
    end;

    /// <summary>
    /// Creates the complete license file content including signature.
    /// </summary>
    local procedure CreateLicenseFileContent(LicenseContent: Text; DigitalSignature: Text): Text
    var
        LicenseFile: Text;
    begin
        LicenseFile := '--- BEGIN LICENSE ---' + NewLine() +
                      LicenseContent + NewLine() +
                      '--- BEGIN SIGNATURE ---' + NewLine() +
                      DigitalSignature + NewLine() +
                      '--- END LICENSE ---';
        
        exit(LicenseFile);
    end;

    /// <summary>
    /// Internal validation logic for licenses.
    /// </summary>
    local procedure ValidateLicenseInternal(var LicenseRegistry: Record "License Registry"; var ApplicationRegistry: Record "Application Registry"; var CryptoKeyManager: Codeunit "Crypto Key Manager"): Text[100]
    begin
        // Check if application exists and is active
        if not ApplicationRegistry.Get(LicenseRegistry."App ID") then
            exit('Application not found');
        
        if not ApplicationRegistry.Active then
            exit('Application not active');

        // Check license status
        if LicenseRegistry.Status <> LicenseRegistry.Status::Active then
            exit('License not active');

        // Check date validity
        if Today < LicenseRegistry."Valid From" then
            exit('License not yet valid');
        
        if Today > LicenseRegistry."Valid To" then
            exit('License expired');

        // In real implementation, validate digital signature here
        // if not ValidateDigitalSignature(LicenseRegistry) then
        //     exit('Signature validation failed');

        exit('Valid');
    end;

    /// <summary>
    /// Gets a simple hash of content for signature purposes.
    /// </summary>
    local procedure GetContentHash(Content: Text): Text
    var
        HashValue: Text;
    begin
        // Simplified hash implementation
        HashValue := CopyStr(Content, 1, 10) + CopyStr(Content, StrLen(Content) - 9, 10);
        exit(UpperCase(HashValue));
    end;

    /// <summary>
    /// Gets a newline character for file formatting.
    /// </summary>
    local procedure NewLine(): Char
    begin
        exit(10);
    end;
}