# Copilot Instructions for Application Licensing (AL-Go)

## Project Overview
- **Purpose:** Provides flexible licensing and activation for Microsoft Dynamics 365 Business Central applications.
- **Architecture:**
  - **Application Management:** Handles registration, updates, and lifecycle of applications (`ApplicationManager.Codeunit.al`, `ApplicationRegistry.Table.al`).
  - **License Management:** Central logic for license generation, import, validation, and registry (`LicenseManagement.Codeunit.al`, `LicenseRegistry.Table.al`).
  - **Crypto Key Management:** Manages cryptographic keys for license signing/validation with certificate import support (`CryptoKeyManager.Codeunit.al`, `CryptoKeyStorage.Table.al`, `CertificateImport.Page.al`).
- **Data Flow:**
  - Applications are registered and tracked in `Application Registry`.
  - Cryptographic keys can be generated OR imported from .p12 certificates.
  - Licenses are generated, signed with imported/generated keys, and stored in `License Registry`.

## Certificate Import Features
- **Primary Method:** Use `.p12` certificate import instead of key generation for production scenarios.
- **User Interface:** `CertificateImport.Page.al` (ID 80508) provides file upload and validation.
- **Key Procedures:**
  - `ImportCertificateFromFile()`: Main entry point for certificate import with file dialog.
  - `ImportCertificate()`: Core import logic for .p12 certificates with password support.
  - `ValidateCertificate()`: Validates certificate without importing.
  - `GetCertificateInfo()`: Extracts certificate information for display.
- **Backward Compatibility:** Legacy `GenerateKeyPair()` method still available but certificate import is preferred.

## Key Conventions & Patterns
- **Namespace:** All objects use `ApplicationLicensing` as the root namespace.
- **ID Ranges:** All custom objects use IDs 80500–80549 (see `app.json`).
- **Field Naming:** Table fields use PascalCase with spaces (e.g., `App ID`, `License ID`).
- **Enums:** Use for status and type fields (e.g., `LicenseStatus.Enum.al`, `CryptoKeyType.Enum.al`).
- **Error Handling:** Use `Error()` with localized messages; see codeunit comments for error patterns.
- **Documentation:** All public procedures and tables are documented with XML comments.
- **Security:** Private keys stored securely using `StorePrivateKeySecurely()` method.

## Developer Workflows
- **Local Development:**
  - Use `.AL-Go/localDevEnv.ps1` to set up a Docker-based BC environment.
  - Requires Docker installed and configured.
- **Cloud Development:**
  - Use `.AL-Go/cloudDevEnv.ps1` for a SaaS sandbox environment.
- **Certificate Management:**
  - Import .p12 certificates via `CertificateImport.Page.al` or programmatically via `ImportCertificateFromFile()`.
  - Test certificate validation with `ValidateCertificate()` before importing.
- **Build/Test:**
  - No explicit test folders; add tests in future under `testFolders` in `.AL-Go/settings.json`.
- **Translation:**
  - XLF files in `Translations/` (e.g., `Application Licensing.g.xlf`).
  - Enable `TranslationFile` feature in `app.json`.

## Integration Points
- **Business Central System:** Integrates with standard BC objects (e.g., `NAV App Installed App`).
- **Certificate Management:** Supports .p12 certificate files with password protection.
- **Application Insights:** Telemetry via `applicationInsightsConnectionString` in `app.json`.
- **External Docs:** Links in `app.json` for privacy, EULA, and help.

## Examples
- **Import Certificate:** Use `CertificateImport.Page.al` or call `ImportCertificateFromFile()` programmatically.
- **Register Application:** See `RegisterApplication` in `ApplicationManager.Codeunit.al`.
- **Generate License:** See `LicenseGenerator.Codeunit.al` and `LicenseManagement.Codeunit.al`.
- **Legacy Key Generation:** See `GenerateKeyPair()` in `CryptoKeyManager.Codeunit.al` (deprecated).

## File/Directory Guide
- `src/Application Management/` — Application registration and management
- `src/License Management/` — License generation, import, registry
- `src/Crypto Key Management/` — Key management, certificate import, and storage
  - `CertificateImport.Page.al` — User interface for certificate import
  - `CryptoKeyManager.Codeunit.al` — Core certificate and key management logic
- `Translations/` — XLF translation files
- `.AL-Go/` — Dev environment scripts and settings

---
If any section is unclear or missing, please provide feedback for further refinement.
