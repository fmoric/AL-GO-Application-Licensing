# Copilot Instructions for Application Licensing (AL-Go)

## Project Overview
- **Purpose:** Provides flexible licensing and activation for Microsoft Dynamics 365 Business Central applications.
- **New Architecture (Split Structure):**
  - **Application Licensing Base:** Core foundation with license validation, import, and registry functionality
  - **Application Licensing Generator:** Advanced features for license generation, application management, and crypto key management
- **Legacy Note:** The "Application Licensing (Original)" folder contains the old monolithic structure and will be removed once all functionality is migrated to the new split architecture.

## Application Structure

### Application Licensing Base (`Application Licensing Base/`)
- **Purpose:** Essential licensing foundation that can be deployed independently
- **Core Components:**
  - **License Management:** Basic license validation, import, and registry (`LicenseValidator.Codeunit.al`, `LicenseRegistry.Table.al`)
  - **License Import:** User interface for importing licenses (`LicenseImport.Page.al`)
  - **License Status:** Enumeration for license states (`LicenseStatus.Enum.al`)
- **Data Flow:**
  - Provides core license validation and storage capabilities
  - Can operate independently for license consumption scenarios

### Application Licensing Generator (`Application Licensing Generator/`)
- **Purpose:** Advanced licensing capabilities for license generation and management
- **Extended Components:**
  - **Application Management:** Handles registration, updates, and lifecycle of applications (`ApplicationCard.Page.al`)
  - **License Generation:** Advanced license creation and signing capabilities
  - **Crypto Key Management:** Manages cryptographic keys for license signing/validation with certificate import support
  - **Customer Management:** Customer data handling for license generation
- **Dependencies:** Builds upon Application Licensing Base
- **Data Flow:**
  - Applications are registered and tracked
  - Cryptographic keys can be generated OR imported from .p12 certificates
  - Licenses are generated, signed with imported/generated keys, and stored in License Registry

## Certificate Import Features (Generator App)
- **Location:** Available in Application Licensing Generator application
- **Primary Method:** Use `.p12` certificate import instead of key generation for production scenarios.
- **User Interface:** Certificate import pages provide file upload and validation.
- **Key Procedures:**
  - `ImportCertificateFromFile()`: Main entry point for certificate import with file dialog.
  - `ImportCertificate()`: Core import logic for .p12 certificates with password support.
  - `ValidateCertificate()`: Validates certificate without importing.
  - `GetCertificateInfo()`: Extracts certificate information for display.
- **Backward Compatibility:** Legacy `GenerateKeyPair()` method still available but certificate import is preferred.

## Key Conventions & Patterns
- **Namespace:** All objects use `ApplicationLicensing` as the root namespace across both applications.
- **ID Ranges:** 
  - Application Licensing Base: Uses specific ID range (see `app.json` in Base folder)
  - Application Licensing Generator: Uses specific ID range (see `app.json` in Generator folder)
- **Field Naming:** Table fields use PascalCase with spaces (e.g., `App ID`, `License ID`).
- **Enums:** Use for status and type fields (e.g., `LicenseStatus.Enum.al` in Base app).
- **Error Handling:** Use `Error()` with localized messages; see codeunit comments for error patterns.
- **Documentation:** All public procedures and tables are documented with XML comments.
- **Security:** Private keys stored securely using secure storage methods in Generator app.
- **Dependency Management:** Generator app depends on Base app for core functionality.

## Developer Workflows
- **Local Development:**
  - Use `.AL-Go/localDevEnv.ps1` to set up a Docker-based BC environment.
  - Requires Docker installed and configured.
  - Both Base and Generator applications can be developed and deployed separately.
- **Cloud Development:**
  - Use `.AL-Go/cloudDevEnv.ps1` for a SaaS sandbox environment.
- **Application Dependencies:**
  - Deploy Base application first, then Generator application.
  - Generator app automatically references Base app functionality.
- **Certificate Management (Generator App):**
  - Import .p12 certificates via certificate import pages or programmatically.
  - Test certificate validation before importing.
- **Build/Test:**
  - Each application has its own build process and dependencies.
  - No explicit test folders; add tests in future under `testFolders` in respective `.AL-Go/settings.json`.
- **Translation:**
  - Each application has its own XLF files in respective `Translations/` folders:
    - `Application Licensing Base/Translations/Application Licensing Base.g.xlf`
    - `Application Licensing Generator/Translations/Application Licensing Generator.g.xlf`
  - Enable `TranslationFile` feature in respective `app.json` files.

## Integration Points
- **Business Central System:** Both applications integrate with standard BC objects.
- **Inter-App Dependencies:** Generator app extends Base app functionality seamlessly.
- **Certificate Management (Generator):** Supports .p12 certificate files with password protection.
- **Application Insights:** Telemetry via `applicationInsightsConnectionString` in respective `app.json` files.
- **External Docs:** Links in respective `app.json` files for privacy, EULA, and help.

## Examples
- **Base App Usage:**
  - **Import License:** Use license import functionality in Base app
  - **Validate License:** See `LicenseValidator.Codeunit.al` in Base app
- **Generator App Usage:**
  - **Import Certificate:** Use certificate import pages or call import methods programmatically
  - **Register Application:** See application management functionality in Generator app
  - **Generate License:** See license generation capabilities in Generator app
- **Deployment Order:** Always deploy Base app before Generator app due to dependencies

## File/Directory Guide

### Application Licensing Base (`Application Licensing Base/`)
- `src/License Management/` — Core license validation, import, and registry functionality
  - `LicenseImport.Page.al` — User interface for importing licenses
  - `LicenseRegistry.Page.al` — License registry management
  - `LicenseRegistry.Table.al` — License storage table
  - `LicenseStatus.Enum.al` — License status enumeration
  - `LicenseValidator.Codeunit.al` — Core license validation logic
- `Translations/` — XLF translation files (`Application Licensing Base.g.xlf`)

### Application Licensing Generator (`Application Licensing Generator/`)
- `src/Application Management/` — Application registration and management
- `src/License Generation/` — Advanced license generation capabilities
- `src/Crypto Key Management/` — Key management, certificate import, and storage
- `src/Customer Management/` — Customer data handling for license generation
- `Translations/` — XLF translation files (`Application Licensing Generator.g.xlf`)

### Legacy Structure (To be removed)
- `Application Licensing (Original)/` — **OBSOLETE:** Old monolithic structure, will be deleted after migration

### Configuration
- `.AL-Go/` — Dev environment scripts and settings
- `.github/` — AL-Go workflows and CI/CD configuration

---
If any section is unclear or missing, please provide feedback for further refinement.
