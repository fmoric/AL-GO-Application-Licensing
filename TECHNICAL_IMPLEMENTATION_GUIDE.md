# Customer License Generation - Technical Implementation Guide

## 🔧 Core Implementation Details

This document provides detailed technical specifications for implementing the customer license header/lines generation system.

## 📋 1. License Generation Integration

### 1.1 CustomerLicenseLine.GenerateLicense() Implementation

**File:** `Application Licensing\src\Application Management\CustomerLicenseLine.Table.al`
**Location:** Line ~307 (replace TODO comment)

```al
/// <summary>
/// Generates a license file for this application line.
/// </summary>
procedure GenerateLicense(): Boolean
var
    CustomerLicenseHeader: Record "Customer License Header";
    LicenseGenerator: Codeunit "License Generator";
    ApplicationLicensingSetup: Record "Application Licensing Setup";
    LicenseId: Guid;
    LicenseContent: Text;
    DigitalSignature: Text;
    KeyId: Code[20];
begin
    TestField(Type, Type::Application);
    TestField("Application ID");

    if not CustomerLicenseHeader.Get("Document No.") then
        Error(CustomerHeaderNotFoundErr, "Document No.");

    // License dates come from header
    CustomerLicenseHeader.TestField("License Start Date");
    CustomerLicenseHeader.TestField("License End Date");

    // Get active signing key
    ApplicationLicensingSetup.GetSetup();
    if not ApplicationLicensingSetup.GetActiveSigningKey(KeyId) then
        Error('No active signing key available for license generation.');

    // Generate the license using the Base Application generator
    if LicenseGenerator.GenerateLicenseFromCustomerLine(Rec, KeyId) then begin
        "License Generated" := true;
        "License Status" := "License Status"::Active;
        "Last Generated" := CurrentDateTime();
        Modify(true);
        exit(true);
    end;

    exit(false);
end;
```

### 1.2 CustomerLicenseHeader.GenerateAllLicenseFiles() Implementation

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Location:** Line ~405 (replace TODO comment)

```al
/// <summary>
/// Generates license files for all application lines in the document.
/// </summary>
local procedure GenerateAllLicenseFiles()
var
    CustomerLicenseLine: Record "Customer License Line";
    LicenseGenerator: Codeunit "License Generator";
    ApplicationLicensingSetup: Record "Application Licensing Setup";
    SuccessCount: Integer;
    TotalCount: Integer;
    FailedApplications: Text;
    KeyId: Code[20];
begin
    CustomerLicenseLine.SetRange("Document No.", "No.");
    CustomerLicenseLine.SetRange(Type, CustomerLicenseLine.Type::Application);

    if CustomerLicenseLine.IsEmpty() then
        Error(NoApplicationLinesErr);

    // Get active signing key
    ApplicationLicensingSetup.GetSetup();
    if not ApplicationLicensingSetup.GetActiveSigningKey(KeyId) then
        Error('No active signing key available for license generation.');

    TotalCount := CustomerLicenseLine.Count();
    
    if CustomerLicenseLine.FindSet(true) then
        repeat
            if LicenseGenerator.GenerateLicenseFromCustomerLine(CustomerLicenseLine, KeyId) then begin
                CustomerLicenseLine."License Generated" := true;
                CustomerLicenseLine."License Status" := CustomerLicenseLine."License Status"::Active;
                CustomerLicenseLine."Last Generated" := CurrentDateTime();
                CustomerLicenseLine.Modify();
                SuccessCount += 1;
            end else begin
                if FailedApplications <> '' then
                    FailedApplications += ', ';
                FailedApplications += CustomerLicenseLine."Application Name";
            end;
        until CustomerLicenseLine.Next() = 0;

    // Update header statistics
    "Total Applications" := TotalCount;
    "Generated Licenses" := SuccessCount;
    "Last Generation Date" := CurrentDateTime();

    // Provide user feedback
    if SuccessCount = TotalCount then
        Message('All %1 licenses generated successfully.', TotalCount)
    else if SuccessCount > 0 then
        Message('%1 of %2 licenses generated successfully.\\Failed applications: %3', SuccessCount, TotalCount, FailedApplications)
    else
        Error('License generation failed for all applications.\\Failed applications: %1', FailedApplications);
end;
```

## 📋 2. Generator Application Integration

### 2.1 Enhanced LicenseGenerator.GenerateLicense() Implementation

**File:** `Application Licensing Generator\src\License Generation\LicenseGenerator.Codeunit.al`
**Location:** Replace existing GenerateLicense method

```al
/// <summary>
/// Generates a new license and stores it in the Base Application.
/// Enhanced version with better error handling and customer line integration.
/// </summary>
/// <param name="AppId">Application ID from Base Application Registry.</param>
/// <param name="CustomerName">Customer name for the license.</param>
/// <param name="ValidFrom">License start date.</param>
/// <param name="ValidTo">License end date.</param>
/// <param name="Features">Licensed features.</param>
/// <param name="CustomerDocumentNo">Customer License Document Number.</param>
/// <param name="CustomerLineNo">Customer License Line Number.</param>
/// <returns>Generated License ID if successful, null GUID if failed.</returns>
procedure GenerateLicense(AppId: Guid; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]; CustomerDocumentNo: Code[20]; CustomerLineNo: Integer): Guid
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

    if ValidTo < Today() then
        Error('License expiration date cannot be in the past.');

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
    LicenseRegistry."Document No." := CustomerDocumentNo;
    LicenseRegistry."Document Line No." := CustomerLineNo;
    LicenseRegistry."App ID" := AppId;
    LicenseRegistry."Valid From" := ValidFrom;
    LicenseRegistry."Valid To" := ValidTo;
    LicenseRegistry.Features := Features;
    LicenseRegistry."Digital Signature" := CopyStr(DigitalSignature, 1, MaxStrLen(LicenseRegistry."Digital Signature"));
    LicenseRegistry."Key ID" := KeyId;
    LicenseRegistry.Status := LicenseRegistry.Status::Active;
    LicenseRegistry."Last Validated" := CurrentDateTime();
    LicenseRegistry."Validation Result" := 'Valid';

    // Store license file content
    StoreLicenseFile(LicenseRegistry, LicenseContent, DigitalSignature);

    if LicenseRegistry.Insert(true) then begin
        // Trigger integration event for extensibility
        OnAfterLicenseGenerated(LicenseRegistry, LicenseContent);
        exit(LicenseId);
    end else
        Error('Failed to store license in Base Application registry.');
end;
```

### 2.2 Customer Line Integration Method

**File:** `Application Licensing Generator\src\License Generation\LicenseGenerator.Codeunit.al`
**Add new method:**

```al
/// <summary>
/// Generates a license directly from a Customer License Line.
/// This method bridges the Generator and Base Application.
/// </summary>
/// <param name="CustomerLicenseLine">The Customer License Line to generate a license for.</param>
/// <param name="KeyId">The signing key ID to use.</param>
/// <returns>True if the license was generated successfully.</returns>
procedure GenerateLicenseFromCustomerLine(var CustomerLicenseLine: Record "Customer License Line"; KeyId: Code[20]): Boolean
var
    CustomerLicenseHeader: Record "Customer License Header";
    LicenseId: Guid;
begin
    // Get the Customer License Header for license dates
    if not CustomerLicenseHeader.Get(CustomerLicenseLine."Document No.") then
        Error('Customer License Header %1 not found.', CustomerLicenseLine."Document No.");

    // Generate the license using enhanced method
    LicenseId := GenerateLicense(
        CustomerLicenseLine."Application ID",
        CustomerLicenseHeader."Customer Name",
        CustomerLicenseHeader."License Start Date",
        CustomerLicenseHeader."License End Date",
        CustomerLicenseLine."Licensed Features",
        CustomerLicenseLine."Document No.",
        CustomerLicenseLine."Line No.");

    if not IsNullGuid(LicenseId) then begin
        // Update the Customer License Line with the generated license information
        CustomerLicenseLine."License ID" := LicenseId;
        CustomerLicenseLine."License Generated" := true;
        CustomerLicenseLine."Last Generated" := CurrentDateTime();
        CustomerLicenseLine.Modify(true);
        exit(true);
    end;

    exit(false);
end;
```

## 📋 3. Document Status Implementation

### 3.1 Enhanced Release Procedure

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Location:** Enhance existing Release procedure

```al
/// <summary>
/// Releases the license document and generates license files.
/// Enhanced with validation and audit trail.
/// </summary>
procedure Release()
var
    CustomerLicenseLine: Record "Customer License Line";
    ApplicationLicensingSetup: Record "Application Licensing Setup";
begin
    // Validate required fields
    TestField("Customer No.");
    TestField("Customer Name");
    TestField("License Start Date");
    TestField("License End Date");

    if "License Start Date" >= "License End Date" then
        Error('License Start Date must be before License End Date.');

    // Validate at least one application line exists
    CustomerLicenseLine.SetRange("Document No.", "No.");
    CustomerLicenseLine.SetRange(Type, CustomerLicenseLine.Type::Application);
    if CustomerLicenseLine.IsEmpty() then
        Error(NoApplicationLinesErr);

    // Validate crypto setup is available
    ApplicationLicensingSetup.GetSetup();
    ApplicationLicensingSetup.TestField("Default Signing Key ID");

    // Update status and audit fields
    Status := Status::Released;
    "Released Date" := CurrentDateTime();
    "Released By" := CopyStr(UserId(), 1, MaxStrLen("Released By"));

    // Generate all license files
    GenerateAllLicenseFiles();

    Modify(true);

    // Trigger release event for extensibility
    OnAfterRelease();
end;
```

### 3.2 Reopen Functionality

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Add new procedure:**

```al
/// <summary>
/// Reopens a released license document for editing.
/// </summary>
procedure Reopen()
begin
    TestField(Status, Status::Released);
    
    if not Confirm('Are you sure you want to reopen this license document? This will allow modifications but may require license regeneration.') then
        exit;

    Status := Status::Open;
    "Released Date" := 0DT;
    Clear("Released By");
    Modify(true);

    OnAfterReopen();
end;
```

### 3.3 Status-Based Field Validation

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Add to OnModify trigger:**

```al
trigger OnModify()
begin
    // Prevent modifications when document is released
    if (Status = Status::Released) and (xRec.Status = Status::Released) then begin
        // Allow only specific fields to be modified when released
        if ("Customer No." <> xRec."Customer No.") or
           ("Customer Name" <> xRec."Customer Name") or
           ("License Start Date" <> xRec."License Start Date") or
           ("License End Date" <> xRec."License End Date") then
            Error(DocumentNotEditableErr, "No.", Status);
    end;
end;
```

## 📋 4. Page Action Implementation

### 4.1 Customer License Header Page Actions

**File:** `Application Licensing\src\Application Management\CustomerLicense.Page.al`
**Add to actions section:**

```al
actions
{
    area(Processing)
    {
        group(Release)
        {
            Caption = 'Release';
            Image = ReleaseDoc;
            
            action(Release)
            {
                ApplicationArea = All;
                Caption = 'Release';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = (Rec.Status = Rec.Status::Open);
                ToolTip = 'Release the license document and generate all license files.';

                trigger OnAction()
                begin
                    Rec.Release();
                    CurrPage.Update(false);
                end;
            }
            
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = (Rec.Status = Rec.Status::Released);
                ToolTip = 'Reopen the license document for editing.';

                trigger OnAction()
                begin
                    Rec.Reopen();
                    CurrPage.Update(false);
                end;
            }
        }
        
        group(Generate)
        {
            Caption = 'Generate';
            Image = CreateDocument;
            
            action(GenerateAllLicenses)
            {
                ApplicationArea = All;
                Caption = 'Generate All Licenses';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = (Rec.Status = Rec.Status::Released);
                ToolTip = 'Generate license files for all applications in this document.';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.GenerateAllCustomerLicenses(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            
            action(ValidateAllLicenses)
            {
                ApplicationArea = All;
                Caption = 'Validate All Licenses';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Validate all generated licenses in this document.';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.ValidateAllCustomerLicenses(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
        }
    }
    
    area(Navigation)
    {
        action(LicenseRegistry)
        {
            ApplicationArea = All;
            Caption = 'Generated Licenses';
            Image = RegisteredDocs;
            RunObject = page "License Registry";
            RunPageLink = "Document No." = field("No.");
            ToolTip = 'View all licenses generated for this customer.';
        }
    }
}
```

### 4.2 Customer License Line Page Actions

**File:** `Application Licensing\src\Application Management\CustomerApplicationLines.Page.al`
**Add to actions section:**

```al
actions
{
    area(Processing)
    {
        action(GenerateLicense)
        {
            ApplicationArea = All;
            Caption = 'Generate License';
            Image = CreateDocument;
            Promoted = true;
            PromotedCategory = Process;
            Enabled = (Rec.Type = Rec.Type::Application) and not Rec."License Generated";
            ToolTip = 'Generate a license file for this application.';

            trigger OnAction()
            begin
                if Rec.GenerateLicense() then
                    Message('License generated successfully for %1.', Rec."Application Name")
                else
                    Error('Failed to generate license for %1.', Rec."Application Name");
                
                CurrPage.Update(false);
            end;
        }
        
        action(RegenerateLicense)
        {
            ApplicationArea = All;
            Caption = 'Regenerate License';
            Image = Refresh;
            Promoted = true;
            PromotedCategory = Process;
            Enabled = (Rec.Type = Rec.Type::Application) and Rec."License Generated";
            ToolTip = 'Regenerate the license file for this application.';

            trigger OnAction()
            begin
                if Confirm('Are you sure you want to regenerate the license for %1?', false, Rec."Application Name") then begin
                    Rec."License Generated" := false;
                    Rec.Modify();
                    
                    if Rec.GenerateLicense() then
                        Message('License regenerated successfully for %1.', Rec."Application Name")
                    else
                        Error('Failed to regenerate license for %1.', Rec."Application Name");
                    
                    CurrPage.Update(false);
                end;
            end;
        }
        
        action(ValidateLicense)
        {
            ApplicationArea = All;
            Caption = 'Validate License';
            Image = ValidateEmailLoggingSetup;
            Enabled = (Rec.Type = Rec.Type::Application) and Rec."License Generated";
            ToolTip = 'Validate the generated license for this application.';

            trigger OnAction()
            var
                LicenseRegistry: Record "License Registry";
                LicenseValidator: Codeunit "License Validator";
            begin
                if LicenseRegistry.Get(Rec."License ID") then begin
                    if LicenseValidator.ValidateLicense(LicenseRegistry) then
                        Message('License validation successful for %1.', Rec."Application Name")
                    else
                        Message('License validation failed for %1.', Rec."Application Name");
                end else
                    Error('License not found for %1.', Rec."Application Name");
            end;
        }
    }
}
```

## 📋 5. Error Handling and Events

### 5.1 Integration Events

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Add integration events:**

```al
[IntegrationEvent(false, false)]
local procedure OnAfterRelease()
begin
end;

[IntegrationEvent(false, false)]
local procedure OnAfterReopen()
begin
end;

[IntegrationEvent(false, false)]
local procedure OnBeforeGenerateAllLicenseFiles(var CustomerLicenseHeader: Record "Customer License Header")
begin
end;

[IntegrationEvent(false, false)]
local procedure OnAfterGenerateAllLicenseFiles(var CustomerLicenseHeader: Record "Customer License Header"; SuccessCount: Integer; TotalCount: Integer)
begin
end;
```

### 5.2 Error Labels and Constants

**File:** `Application Licensing\src\Application Management\CustomerLicenseHeader.Table.al`
**Add to var section:**

```al
var
    StartDateAfterEndDateErr: Label 'License Start Date cannot be after License End Date.';
    DocumentNotEditableErr: Label 'License document %1 cannot be modified when status is %2.', Comment = '%1 = Document No., %2 = Status';
    NoApplicationLinesErr: Label 'You must add at least one application line before releasing the document.';
    NoActiveSigningKeyErr: Label 'No active signing key is available. Please configure signing keys in Application Licensing Setup.';
    BulkGenerationSuccessMsg: Label 'All %1 licenses generated successfully.', Comment = '%1 = Number of licenses';
    BulkGenerationPartialMsg: Label '%1 of %2 licenses generated successfully.\\Failed applications: %3', Comment = '%1 = Success count, %2 = Total count, %3 = Failed applications';
    BulkGenerationFailedErr: Label 'License generation failed for all applications.\\Failed applications: %1', Comment = '%1 = Failed applications';
```

## 📋 6. Performance Optimization

### 6.1 Batch Processing Implementation

**File:** `Application Licensing\src\Application Management\CustomerLicenseManagement.Codeunit.al`
**Add new procedure:**

```al
/// <summary>
/// Generates licenses for multiple customers in batch mode.
/// </summary>
/// <param name="CustomerLicenseHeaders">Record set of customer license headers to process.</param>
procedure GenerateLicensesBatch(var CustomerLicenseHeaders: Record "Customer License Header")
var
    TotalDocuments: Integer;
    ProcessedDocuments: Integer;
    ProgressWindow: Dialog;
    StartTime: DateTime;
    ProcessingTimeMsg: Label 'Processing license generation...\\Document: #1####\\Progress: #2### of #3###\\Elapsed time: #4######';
begin
    if CustomerLicenseHeaders.IsEmpty() then
        exit;

    TotalDocuments := CustomerLicenseHeaders.Count();
    StartTime := CurrentDateTime();
    
    ProgressWindow.Open(ProcessingTimeMsg);
    
    if CustomerLicenseHeaders.FindSet() then
        repeat
            ProcessedDocuments += 1;
            ProgressWindow.Update(1, CustomerLicenseHeaders."No.");
            ProgressWindow.Update(2, ProcessedDocuments);
            ProgressWindow.Update(3, TotalDocuments);
            ProgressWindow.Update(4, CurrentDateTime() - StartTime);
            
            if CustomerLicenseHeaders.Status = CustomerLicenseHeaders.Status::Released then
                CustomerLicenseHeaders.GenerateAllLicenseFiles();
                
        until CustomerLicenseHeaders.Next() = 0;
    
    ProgressWindow.Close();
    
    Message('Batch processing completed. %1 documents processed in %2.', 
            ProcessedDocuments, 
            CurrentDateTime() - StartTime);
end;
```

### 6.2 Memory Management

**File:** `Application Licensing Generator\src\License Generation\LicenseGenerator.Codeunit.al`
**Add memory-efficient content creation:**

```al
/// <summary>
/// Creates license content with memory optimization for large batches.
/// </summary>
local procedure CreateLicenseContentOptimized(LicenseId: Guid; AppId: Guid; AppName: Text[100]; CustomerName: Text[100]; ValidFrom: Date; ValidTo: Date; Features: Text[250]): Text
var
    StringBuilder: TextBuilder;
    IssuedDateTime: DateTime;
begin
    IssuedDateTime := CurrentDateTime();
    
    // Use StringBuilder for efficient string concatenation
    StringBuilder.Append('LICENSE_ID=');
    StringBuilder.AppendLine(Format(LicenseId));
    StringBuilder.Append('APP_ID=');
    StringBuilder.AppendLine(Format(AppId));
    StringBuilder.Append('APP_NAME=');
    StringBuilder.AppendLine(AppName);
    StringBuilder.Append('CUSTOMER=');
    StringBuilder.AppendLine(CustomerName);
    StringBuilder.Append('VALID_FROM=');
    StringBuilder.AppendLine(Format(ValidFrom, 0, '<Year4>-<Month,2>-<Day,2>'));
    StringBuilder.Append('VALID_TO=');
    StringBuilder.AppendLine(Format(ValidTo, 0, '<Year4>-<Month,2>-<Day,2>'));
    StringBuilder.Append('FEATURES=');
    StringBuilder.AppendLine(Features);
    StringBuilder.Append('ISSUED=');
    StringBuilder.AppendLine(Format(IssuedDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24>:<Minutes,2>:<Seconds,2>Z'));
    
    exit(StringBuilder.ToText());
end;
```

---

## 📝 Implementation Checklist

### Phase 1: Core Functionality
- [ ] ✅ Replace TODO comments with actual implementation
- [ ] ✅ Implement CustomerLicenseLine.GenerateLicense()
- [ ] ✅ Implement CustomerLicenseHeader.GenerateAllLicenseFiles()
- [ ] ✅ Enhance Generator app integration
- [ ] ✅ Test individual license generation
- [ ] ✅ Test bulk license generation

### Phase 2: Document Workflow
- [ ] ✅ Implement enhanced Release procedure
- [ ] ✅ Add Reopen functionality
- [ ] ✅ Implement status-based validations
- [ ] ✅ Add page actions for release/reopen
- [ ] ✅ Test document workflow

### Phase 3: User Interface
- [ ] ✅ Add license generation actions to pages
- [ ] ✅ Implement validation actions
- [ ] ✅ Add progress indicators
- [ ] ✅ Test user interface
- [ ] ✅ Fix compilation errors

### Phase 4: Optimization
- [ ] ✅ Implement batch processing
- [ ] ✅ Add memory optimization
- [ ] ✅ Implement progress tracking
- [ ] ✅ Add performance monitoring
- [ ] ✅ Test with large datasets

---

*This technical guide provides the detailed code implementations needed to complete the customer license generation system. Follow the checklist to ensure all components are implemented correctly.*