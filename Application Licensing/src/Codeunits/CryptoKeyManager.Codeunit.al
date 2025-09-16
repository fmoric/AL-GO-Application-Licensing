/// <summary>
/// Codeunit Crypto Key Manager (ID 80501).
/// Manages RSA key pair generation, storage, and retrieval for license signing.
/// </summary>
codeunit 80501 "Crypto Key Manager"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Generates a new RSA key pair for license signing.
    /// </summary>
    /// <param name="KeyId">The identifier for the new key pair.</param>
    /// <param name="KeyType">The type of key (Signing, Validation, Master).</param>
    /// <param name="ExpiresDate">Optional expiration date for the key.</param>
    /// <returns>True if key generation was successful.</returns>
    procedure GenerateKeyPair(KeyId: Code[20]; KeyType: Enum "Crypto Key Type"; ExpiresDate: Date): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
        TempBlob: Codeunit System.Utilities."Temp Blob";
        PublicKeyOutStream: OutStream;
        PrivateKeyOutStream: OutStream;
        PublicKey: Text;
        PrivateKey: Text;
    begin
        if CryptoKeyStorage.Get(KeyId) then
            Error('Key with ID %1 already exists.', KeyId);

        // Generate RSA key pair using .NET cryptographic services
        if not GenerateRSAKeyPair(PublicKey, PrivateKey) then
            Error('Failed to generate RSA key pair.');

        // Store the keys
        CryptoKeyStorage.Init();
        CryptoKeyStorage."Key ID" := KeyId;
        CryptoKeyStorage."Key Type" := KeyType;
        CryptoKeyStorage.Algorithm := 'RSA-2048';
        CryptoKeyStorage."Expires Date" := ExpiresDate;
        CryptoKeyStorage.Active := true;

        // Store public key
        CryptoKeyStorage."Public Key".CreateOutStream(PublicKeyOutStream);
        PublicKeyOutStream.WriteText(PublicKey);

        // Store private key
        Clear(TempBlob);
        TempBlob.CreateOutStream(PrivateKeyOutStream);
        PrivateKeyOutStream.WriteText(PrivateKey);

        exit(CryptoKeyStorage.Insert(true));
    end;

    /// <summary>
    /// Gets the active signing key for license generation.
    /// </summary>
    /// <param name="KeyId">Output parameter with the key identifier.</param>
    /// <param name="PublicKey">Output parameter with the public key.</param>
    /// <param name="PrivateKey">Output parameter with the private key.</param>
    /// <returns>True if an active signing key was found.</returns>
    procedure GetActiveSigningKey(var KeyId: Code[20]; var PublicKey: Text; var PrivateKey: Text): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
        TempBlob: Codeunit System.Utilities."Temp Blob";
        InStream: InStream;
    begin
        CryptoKeyStorage.SetRange("Key Type", CryptoKeyStorage."Key Type"::"Signing Key");
        CryptoKeyStorage.SetRange(Active, true);
        CryptoKeyStorage.SetFilter("Expires Date", '>%1|%2', Today, 0D);

        if not CryptoKeyStorage.FindFirst() then
            exit(false);

        KeyId := CryptoKeyStorage."Key ID";

        // Get public key
        TempBlob.FromRecord(CryptoKeyStorage, CryptoKeyStorage.FieldNo("Public Key"));
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(PublicKey);

        // Get private key
        Clear(TempBlob);
        TempBlob.FromRecord(CryptoKeyStorage, CryptoKeyStorage.FieldNo("Private Key"));
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(PrivateKey);

        // Increment usage count
        CryptoKeyStorage."Usage Count" += 1;
        CryptoKeyStorage.Modify();

        exit(true);
    end;

    /// <summary>
    /// Gets the public key for license validation.
    /// </summary>
    /// <param name="KeyId">The key identifier.</param>
    /// <param name="PublicKey">Output parameter with the public key.</param>
    /// <returns>True if the key was found.</returns>
    procedure GetPublicKey(KeyId: Code[20]; var PublicKey: Text): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
        TempBlob: Codeunit System.Utilities."Temp Blob";
        InStream: InStream;
    begin
        if not CryptoKeyStorage.Get(KeyId) then
            exit(false);

        TempBlob.FromRecord(CryptoKeyStorage, CryptoKeyStorage.FieldNo("Public Key"));
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(PublicKey);

        exit(true);
    end;

    /// <summary>
    /// Deactivates a key pair.
    /// </summary>
    /// <param name="KeyId">The key identifier to deactivate.</param>
    /// <returns>True if deactivation was successful.</returns>
    procedure DeactivateKey(KeyId: Code[20]): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
    begin
        if not CryptoKeyStorage.Get(KeyId) then
            exit(false);

        CryptoKeyStorage.Active := false;
        exit(CryptoKeyStorage.Modify());
    end;

    /// <summary>
    /// Checks if a signing key is available and not expired.
    /// </summary>
    /// <returns>True if an active signing key is available.</returns>
    procedure IsSigningKeyAvailable(): Boolean
    var
        CryptoKeyStorage: Record "Crypto Key Storage";
    begin
        CryptoKeyStorage.SetRange("Key Type", CryptoKeyStorage."Key Type"::"Signing Key");
        CryptoKeyStorage.SetRange(Active, true);
        CryptoKeyStorage.SetFilter("Expires Date", '>%1|%2', Today, 0D);

        exit(not CryptoKeyStorage.IsEmpty);
    end;

    /// <summary>
    /// Internal procedure to generate RSA key pair using .NET cryptographic services.
    /// This is a simplified implementation - in real scenarios, you would use proper .NET interop.
    /// </summary>
    /// <param name="PublicKey">Output parameter with the generated public key.</param>
    /// <param name="PrivateKey">Output parameter with the generated private key.</param>
    /// <returns>True if generation was successful.</returns>
    local procedure GenerateRSAKeyPair(var PublicKey: Text; var PrivateKey: Text): Boolean
    var
        RandomGuid: Guid;
    begin
        // Note: This is a simplified mock implementation for demonstration
        // In a real implementation, you would use proper RSA key generation
        // using .NET System.Security.Cryptography.RSACryptoServiceProvider

        RandomGuid := CreateGuid();
        PublicKey := StrSubstNo('RSA-2048-PUBLIC-KEY-%1-%2', RandomGuid, CurrentDateTime);
        PrivateKey := StrSubstNo('RSA-2048-PRIVATE-KEY-%1-%2', RandomGuid, CurrentDateTime);

        // In real implementation, generate actual RSA keys here
        exit(true);
    end;
}