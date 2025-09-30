# Application Licensing System

A modular Business Central application system for managing software licenses with import/validation and generation capabilities.

## Architecture

This repository contains a modern, modular application architecture split into two complementary applications:

###  Base Application
**License import, validation, and core infrastructure**
- **Purpose**: Standalone license management and validation
- **ID**: 2a8ef067-5337-4f39-b645-93afa31c5995
- **ID Range**: 80500-80524
- **Dependencies**: None (fully independent)

###  Generator Application  
**License generation and crypto key management**
- **Purpose**: Extends Base with license generation capabilities
- **ID**: 3b9f1067-5337-4f39-b645-93afa31c5995
- **ID Range**: 80525-80549
- **Dependencies**: Base Application (required)

## Key Features

### Base Application Features
-  **License Import**: Import license files from external sources
-  **License Validation**: Comprehensive signature and content validation
-  **Application Registry**: Manage registered applications
-  **License Management**: View, validate, and export licenses
-  **Role Center**: Integrated management interface

### Generator Application Features  
-  **Crypto Key Management**: RSA key generation and certificate handling
-  **License Generation**: Create cryptographically signed licenses
-  **Customer Workflows**: Document-based license generation process
-  **Base Integration**: Generated licenses stored in Base registry

## Repository Structure

```
 Application Licensing/              # Original monolithic application (legacy)
 Application Licensing Base/         # Base Application (import/validation)
    src/
       Application Management/     # Application registry and management
       License Management/         # License import, validation, storage
    prm/                           # Permission sets
 Application Licensing Generator/    # Generator Application (extends Base)
    src/
       Crypto Key Management/      # Key generation and management
       License Generation/         # License creation logic
       Customer Management/        # Customer license workflows
    prm/                           # Permission sets
 Documentation/
     ARCHITECTURE_DOCUMENTATION.md  # Complete system architecture
     DEPLOYMENT_GUIDE.md           # Installation and testing guide
     GENERATOR_IMPLEMENTATION_GUIDE.md  # Implementation details
```

## Quick Start

### For Import/Validation Only (Base Application)
1. Deploy **Base Application** only
2. Import license files through License Import page
3. Validate and manage licenses through License Registry

### For Full License Generation (Base + Generator)
1. Deploy **Base Application** first
2. Deploy **Generator Application** (requires Base)
3. Generate crypto keys for signing
4. Create customer license documents
5. Generate license files (stored in Base registry)

## Documentation

- **[Architecture Documentation](ARCHITECTURE_DOCUMENTATION.md)**: Complete system design and component distribution
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)**: Step-by-step installation and testing procedures  
- **[Implementation Guide](GENERATOR_IMPLEMENTATION_GUIDE.md)**: Detailed implementation steps for Generator components

## Benefits

###  **Modular Design**
- Clear separation of import/validation vs generation functionality
- Independent deployment options based on customer needs
- Reduced complexity for import-only scenarios

###  **Dependency Enforcement**
- Generator cannot operate without Base (enforced at compile/runtime)
- Proper architectural boundaries maintained
- Clear upgrade path from Base-only to full-stack

###  **Enhanced Maintainability**
- Independent development cycles for each application
- Simplified testing and debugging
- Better resource utilization

## Contributing

This is a modular AL-Go template implementation demonstrating modern Business Central application architecture patterns.

For contributions to the AL-Go framework itself, please visit: https://aka.ms/AL-Go

## License

This project demonstrates application licensing functionality and modular architecture patterns for Business Central development.
