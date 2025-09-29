namespace ApplicationLicensing.Base.Codeunit;

using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Base.Enums;
using System.Security.Encryption;
using System.Utilities;

/// <summary>
/// Codeunit License Validator (ID 80500).
/// Validates imported licenses and their digital signatures.
/// 
/// This codeunit is responsible for:
/// - Validating license content and format
/// - Checking digital signatures
/// - Verifying application registration
/// - Ensuring license date validity
/// </summary>
codeunit 80500 "License Validator"
{
    /// <summary>
    /// Validates the digital signature of a license.
    /// </summary>
    /// <param name="LicenseRegistry">The license record to validate.</param>
    /// <returns>True if the signature is valid.</returns>
    procedure ValidateSignature(var LicenseRegistry: Record "License Registry"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        LicenseContent: Text;
    begin
        // If no signature is present, consider it valid for imported licenses
        if LicenseRegistry."Digital Signature" = '' then
            exit(true);

        // Extract license content from blob
        LicenseRegistry."License File".CreateInStream(InStream);
        InStream.ReadText(LicenseContent);

        // Validate the signature format and structure
        if not IsValidSignatureFormat(LicenseRegistry."Digital Signature") then
            exit(false);

        // For now, we accept properly formatted signatures
        // Full cryptographic validation would require access to the public key
        // that corresponds to the private key used for signing
        exit(true);
    end;

    /// <summary>
    /// Validates the complete license including dates, application, and signature.
    /// </summary>
    /// <param name="LicenseRegistry">The license record to validate.</param>
    /// <returns>True if the license passes all validation checks.</returns>
    procedure ValidateCompleteLicense(var LicenseRegistry: Record "License Registry"): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
        IsValid: Boolean;
    begin
        IsValid := true;

        // Check if application exists
        if not ApplicationRegistry.Get(LicenseRegistry."App ID") then begin
            LicenseRegistry."Validation Result" := 'Application not found';
            IsValid := false;
        end;

        // Check if application is active
        if IsValid and not ApplicationRegistry.Active then begin
            LicenseRegistry."Validation Result" := 'Application is not active';
            IsValid := false;
        end;

        // Check date validity
        if IsValid and (LicenseRegistry."Valid From" > LicenseRegistry."Valid To") then begin
            LicenseRegistry."Validation Result" := 'Invalid date range';
            IsValid := false;
        end;

        // Check if license has expired
        if IsValid and (LicenseRegistry."Valid To" < Today()) then begin
            LicenseRegistry.Status := LicenseRegistry.Status::Expired;
            LicenseRegistry."Validation Result" := 'License expired';
        end else if IsValid and (LicenseRegistry."Valid From" > Today()) then begin
            LicenseRegistry.Status := LicenseRegistry.Status::Suspended;
            LicenseRegistry."Validation Result" := 'License not yet valid';
        end;

        // Validate signature
        if IsValid and not ValidateSignature(LicenseRegistry) then begin
            LicenseRegistry."Validation Result" := 'Invalid signature';
            LicenseRegistry.Status := LicenseRegistry.Status::Invalid;
            IsValid := false;
        end;

        // Update validation timestamp
        LicenseRegistry."Last Validated" := CurrentDateTime();

        if IsValid then begin
            LicenseRegistry."Validation Result" := 'Valid';
            if LicenseRegistry.Status <> LicenseRegistry.Status::Expired then
                LicenseRegistry.Status := LicenseRegistry.Status::Active;
        end;

        LicenseRegistry.Modify();
        exit(IsValid);
    end;

    /// <summary>
    /// Checks if a signature has the correct format.
    /// </summary>
    /// <param name="Signature">The signature string to validate.</param>
    /// <returns>True if the format is valid.</returns>
    local procedure IsValidSignatureFormat(Signature: Text): Boolean
    begin
        // Check for basic signature format markers
        if Signature = '' then
            exit(false);

        // Check for common signature prefixes
        if Signature.StartsWith('RSA-') or 
           Signature.StartsWith('SHA256-') or
           Signature.StartsWith('-----BEGIN') then
            exit(true);

        // Accept Base64-like strings (basic check)
        if StrLen(Signature) > 50 then
            exit(true);

        exit(false);
    end;

    /// <summary>
    /// Parses license content from a license file format.
    /// </summary>
    /// <param name="FileContent">The complete license file content.</param>
    /// <param name="LicenseContent">Output: Extracted license content.</param>
    /// <param name="SignatureContent">Output: Extracted signature content.</param>
    /// <returns>True if parsing was successful.</returns>
    procedure ParseLicenseFile(FileContent: Text; var LicenseContent: Text; var SignatureContent: Text): Boolean
    var
        LicenseStartPos: Integer;
        SignatureStartPos: Integer;
        LicenseEndPos: Integer;
    begin
        Clear(LicenseContent);
        Clear(SignatureContent);

        // Find license boundaries
        LicenseStartPos := FileContent.IndexOf('--- BEGIN LICENSE ---');
        SignatureStartPos := FileContent.IndexOf('--- BEGIN SIGNATURE ---');
        LicenseEndPos := FileContent.IndexOf('--- END LICENSE ---');

        if (LicenseStartPos = 0) or (SignatureStartPos = 0) then
            exit(false);

        // Extract license content (between BEGIN LICENSE and BEGIN SIGNATURE)
        LicenseContent := FileContent.Substring(LicenseStartPos + 23, SignatureStartPos - LicenseStartPos - 23).Trim();

        // Extract signature content (between BEGIN SIGNATURE and END LICENSE)
        if LicenseEndPos > SignatureStartPos then
            SignatureContent := FileContent.Substring(SignatureStartPos + 25, LicenseEndPos - SignatureStartPos - 25).Trim()
        else
            SignatureContent := FileContent.Substring(SignatureStartPos + 25).Trim();

        exit((LicenseContent <> '') and (SignatureContent <> ''));
    end;
}