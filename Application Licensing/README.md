# Application Licensing Management System for Business Central

A comprehensive licensing management solution for Business Central applications featuring secure license generation, centralized application management, and date-based access control.

## Features

### 🏢 Centralized Application Registry
- Maintain applications with version control and activation status
- Track publishers, versions, and application lifecycle
- Full application management capabilities

### 🔐 Secure License Generation
- RSA-2048 signed licenses to prevent tampering
- Cryptographically secure digital signatures
- Automated key pair generation and management

### ⏰ Date-Based Access Control
- Configurable validity periods with automatic enforcement
- Automatic license expiration detection
- License status tracking (Active, Expired, Suspended, Revoked)

### 💻 Command-Line Interface
- Streamlined CLI for licensing operations
- Automation-friendly procedures
- Batch operations support

## Architecture

### Core Components

#### Tables
- **Application Registry (80500)**: Stores registered applications with metadata
- **License Registry (80501)**: Stores generated licenses with validation information
- **Crypto Key Storage (80502)**: Stores RSA key pairs for license signing

#### Business Logic
- **Application Manager (80500)**: Application lifecycle management
- **Crypto Key Manager (80501)**: RSA-2048 key generation and management
- **License Generator (80502)**: License creation and validation
- **License Management (80503)**: Main coordinator with CLI interface

#### User Interface
- **License Management Center (80504)**: Main dashboard and role center
- **Application Registry (80500)**: Application management interface
- **License Registry (80502)**: License viewing and management
- **CLI Demo Page (80509)**: Interactive CLI demonstration

## Getting Started

### Installation
1. Install the Application Licensing extension in your Business Central environment
2. The system will automatically initialize with default cryptographic keys
3. Access the License Management Center from the main menu

### Quick Start Guide

#### 1. Register an Application
```al
// Using CLI interface
LicenseManagement.CLI_RegisterApplication(
    AppId: '12345678-1234-1234-1234-123456789012',
    AppName: 'My Business Central App',
    Publisher: 'Your Company',
    Version: '1.0.0.0',
    Description: 'Description of your application'
);
```

#### 2. Generate a License
```al
// Using CLI interface
LicenseManagement.CLI_GenerateLicense(
    AppId: '12345678-1234-1234-1234-123456789012',
    CustomerName: 'Customer Company Ltd.',
    ValidFromDate: '2024-01-01',
    ValidToDate: '2024-12-31',
    Features: 'Full Access,Premium Features'
);
```

#### 3. Validate a License
```al
// Using CLI interface
LicenseManagement.CLI_ValidateLicense(
    LicenseId: '87654321-4321-4321-4321-210987654321'
);
```

## Security Features

### RSA Digital Signatures
- RSA-2048 encryption for maximum security
- Automatic key pair generation
- Separate public/private key storage
- Tamper-proof license verification

### Access Control
- Date-based validity enforcement
- Automatic expiration detection
- License status management
- Revocation capabilities

### Key Management
- Secure key storage
- Key rotation support
- Usage tracking
- Expiration management

## User Interface

### License Management Center
The main dashboard provides:
- System status overview
- Recent license activity
- Quick access to all functions
- Statistics and monitoring

### Application Registry
- List all registered applications
- Create and edit applications
- View license statistics per application
- Application lifecycle management

### License Registry
- View all generated licenses
- Validate licenses
- Export license files
- Revoke licenses

## Command-Line Interface

The system provides comprehensive CLI functionality for automation:

### Application Management
- `CLI_RegisterApplication`: Register new applications
- `CLI_ListApplications`: List all applications
- `CLI_UpdateApplication`: Update application details

### License Operations
- `CLI_GenerateLicense`: Generate new licenses
- `CLI_ValidateLicense`: Validate existing licenses
- `CLI_ListLicenses`: List all licenses
- `CLI_ExportLicense`: Export license files

### System Management
- `CLI_ShowSystemStatus`: Display system status
- `CLI_GenerateSigningKey`: Create new signing keys
- `CLI_InitializeSystem`: Initialize the licensing system

## Technical Specifications

### ID Ranges
- Tables: 80500-80502
- Codeunits: 80500-80504
- Pages: 80500-80509
- Enums: 80500-80501

### Cryptographic Standards
- **Algorithm**: RSA-2048
- **Signature**: RSA-SHA256
- **Key Storage**: Encrypted blob fields
- **License Format**: Structured text with digital signature

### Performance
- Optimized for high-volume license generation
- Efficient validation algorithms
- Minimal database overhead
- Scalable architecture

## Extensibility

The system is designed for extensibility:

### Integration Events
- `OnLicenseDeleted`: Triggered when licenses are deleted
- Custom validation hooks
- Application lifecycle events

### Customization Points
- License content format
- Validation rules
- Feature definitions
- UI customizations

## Best Practices

### Security
1. Regularly rotate signing keys
2. Monitor license usage
3. Implement proper backup procedures
4. Use strong expiration policies

### Operations
1. Regular license validation
2. Monitor system status
3. Maintain application registry
4. Archive expired licenses

### Development
1. Use CLI for automation
2. Implement proper error handling
3. Follow naming conventions
4. Document customizations

## Support and Maintenance

### Monitoring
- System status dashboard
- License expiration alerts
- Key expiration warnings
- Usage statistics

### Troubleshooting
- Validation error logs
- System health checks
- Key availability verification
- License status tracking

## License File Format

Generated license files use a structured format:
```
--- BEGIN LICENSE ---
LICENSE-V1.0|ID:{guid}|APP-ID:{guid}|APP-NAME:Name|PUBLISHER:Publisher|VERSION:1.0|CUSTOMER:Customer|VALID-FROM:2024-01-01|VALID-TO:2024-12-31|FEATURES:Features|ISSUED:2024-01-01T10:00:00
--- BEGIN SIGNATURE ---
RSA-SHA256-SIGNATURE:{signature}
--- END LICENSE ---
```

## Version History

### Version 26.0.0.0
- Initial implementation
- Core licensing functionality
- RSA-2048 digital signatures
- CLI interface
- Management UI
- Application registry
- License validation system

---

For technical support or feature requests, please contact the development team.