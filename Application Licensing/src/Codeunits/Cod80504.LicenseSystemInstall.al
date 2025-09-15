/// <summary>
/// Codeunit License System Install (ID 80504).
/// Handles system installation and initialization.
/// </summary>
codeunit 80504 "License System Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeLicensingSystem();
    end;

    /// <summary>
    /// Initializes the licensing system with default data.
    /// </summary>
    local procedure InitializeLicensingSystem()
    var
        LicenseManagement: Codeunit "License Management";
        ApplicationManager: Codeunit "Application Manager";
        CryptoKeyManager: Codeunit "Crypto Key Manager";
        DemoAppId: Guid;
    begin
        // Generate default signing key if none exists
        if not CryptoKeyManager.IsSigningKeyAvailable() then begin
            CryptoKeyManager.GenerateKeyPair('DEFAULT-SIGN-KEY', "Crypto Key Type"::"Signing Key", CalcDate('<+5Y>', Today));
        end;

        // Create a demo application for testing
        DemoAppId := CreateGuid();
        if not ApplicationManager.ApplicationExists(DemoAppId) then begin
            ApplicationManager.RegisterApplication(
                DemoAppId,
                'Demo Business Central App',
                'BE-terna',
                '1.0.0.0',
                'Demo application for testing the licensing system');
        end;

        Message('Licensing system initialized successfully!');
    end;
}