# Customer License Generation - Quick Reference

## 🚀 Quick Start Implementation

This guide provides a quick reference for implementing the customer license generation system.

## 📋 Critical Files to Update

### 1. Core License Generation (PRIORITY 1)

#### File: `CustomerLicenseLine.Table.al`
**Location:** Line ~307
**Action:** Replace `// TODO: Implement license generation logic`
```al
// Replace TODO with actual license generation call
if LicenseGenerator.GenerateLicenseFromCustomerLine(Rec, KeyId) then begin
    "License Generated" := true;
    "License Status" := "License Status"::Active;
    "Last Generated" := CurrentDateTime();
    Modify(true);
    exit(true);
end;
```

#### File: `CustomerLicenseHeader.Table.al`
**Location:** Line ~405
**Action:** Replace `// TODO: Implement license generation logic`
```al
// Replace TODO with bulk generation logic
repeat
    if LicenseGenerator.GenerateLicenseFromCustomerLine(CustomerLicenseLine, KeyId) then begin
        CustomerLicenseLine."License Generated" := true;
        CustomerLicenseLine.Modify();
        SuccessCount += 1;
    end;
until CustomerLicenseLine.Next() = 0;
```

### 2. Generator App Integration (PRIORITY 1)

#### File: `LicenseGenerator.Codeunit.al` (Generator App)
**Action:** Add customer line integration method
```al
procedure GenerateLicenseFromCustomerLine(var CustomerLicenseLine: Record "Customer License Line"; KeyId: Code[20]): Boolean
var
    CustomerLicenseHeader: Record "Customer License Header";
    LicenseId: Guid;
begin
    CustomerLicenseHeader.Get(CustomerLicenseLine."Document No.");
    LicenseId := GenerateLicense(
        CustomerLicenseLine."Application ID",
        CustomerLicenseHeader."Customer Name",
        CustomerLicenseHeader."License Start Date",
        CustomerLicenseHeader."License End Date",
        CustomerLicenseLine."Licensed Features",
        CustomerLicenseLine."Document No.",
        CustomerLicenseLine."Line No.");
    
    if not IsNullGuid(LicenseId) then begin
        CustomerLicenseLine."License ID" := LicenseId;
        CustomerLicenseLine."License Generated" := true;
        CustomerLicenseLine.Modify(true);
        exit(true);
    end;
    exit(false);
end;
```

## 🔧 Quick Compilation Fixes

### 1. Page ToolTip Errors
**Files:** `CustomerLicense.Page.al`, `ApplicationCard.Page.al`
**Fix:** Add ToolTip properties
```al
field("Created Date"; Rec.SystemCreatedAt)
{
    ToolTip = 'Specifies when the record was created.';
}
```

### 2. Duplicate Using Statements
**File:** `CustomerLicenseList.Page.al`
**Fix:** Remove duplicate line 5
```al
// Remove this line:
using ApplicationLicensing.Generator.Tables;
```

### 3. Missing Action Implementation
**File:** `LicenseImport.Page.al`
**Fix:** Add OnAction trigger
```al
action(ImportLicense)
{
    trigger OnAction()
    begin
        ImportLicenseFromFile();
    end;
}
```

## 🎯 Essential Page Actions

### Customer License Header Actions
```al
action(Release)
{
    trigger OnAction()
    begin
        Rec.Release();
        CurrPage.Update(false);
    end;
}

action(GenerateAllLicenses)
{
    trigger OnAction()
    var
        CustomerLicenseManagement: Codeunit "Customer License Management";
    begin
        CustomerLicenseManagement.GenerateAllCustomerLicenses(Rec."No.");
        CurrPage.Update(false);
    end;
}
```

### Customer License Line Actions
```al
action(GenerateLicense)
{
    trigger OnAction()
    begin
        if Rec.GenerateLicense() then
            Message('License generated successfully.')
        else
            Error('License generation failed.');
    end;
}
```

## 📊 Testing Checklist

### Basic Functionality Test
- [ ] Create new Customer License Header
- [ ] Add Application Lines
- [ ] Release document
- [ ] Verify licenses generated
- [ ] Check License Registry entries

### Workflow Test
- [ ] Test Open → Released status change
- [ ] Test Release prevents editing
- [ ] Test Reopen functionality
- [ ] Test bulk generation
- [ ] Test individual line generation

### Integration Test
- [ ] Test Generator → Base app data flow
- [ ] Test crypto key integration
- [ ] Test license validation
- [ ] Test cross-app permissions

## ⚡ Quick Debug Commands

### Check License Generation Status
```al
// In Customer License Line
IF "License Generated" THEN
    MESSAGE('License ID: %1', "License ID")
ELSE
    MESSAGE('License not generated');
```

### Verify License Registry Entry
```al
// Check if license exists in registry
LicenseRegistry.SETRANGE("License ID", "License ID");
IF LicenseRegistry.FINDFIRST THEN
    MESSAGE('License found: %1', LicenseRegistry."Digital Signature")
ELSE
    ERROR('License not found in registry');
```

### Check Crypto Key Availability
```al
// Verify signing key is available
ApplicationLicensingSetup.GetSetup();
IF ApplicationLicensingSetup.GetActiveSigningKey(KeyId) THEN
    MESSAGE('Active key: %1', KeyId)
ELSE
    ERROR('No active signing key');
```

## 🚨 Common Issues & Solutions

### Issue: License Generation Fails
**Cause:** No active signing key
**Solution:** 
1. Go to Crypto Key Management
2. Generate new signing key
3. Set as active
4. Retry license generation

### Issue: Cross-App Permission Error
**Cause:** Missing permissions between apps
**Solution:**
1. Check permission sets include all tables
2. Verify app dependencies
3. Test with SUPER permissions first

### Issue: License Not Found in Registry
**Cause:** Generation succeeded but storage failed
**Solution:**
1. Check License Registry table permissions
2. Verify transaction is committed
3. Check for duplicate License IDs

### Issue: Document Cannot Be Released
**Cause:** Missing required fields or lines
**Solution:**
1. Verify Customer No. is filled
2. Check License Start/End dates
3. Ensure at least one Application line exists
4. Verify active signing key exists

## 📁 File Structure Reference

```
Application Licensing/
├── src/Application Management/
│   ├── CustomerLicenseHeader.Table.al     ← Core header table
│   ├── CustomerLicenseLine.Table.al       ← Core line table
│   ├── CustomerLicense.Page.al             ← Main document page
│   ├── CustomerLicenseList.Page.al         ← Document list
│   └── CustomerLicenseManagement.Codeunit.al ← Business logic
├── src/License Management/
│   ├── LicenseGenerator.Codeunit.al        ← License creation
│   └── LicenseRegistry.Table.al            ← Generated licenses
└── src/Crypto Key Management/
    ├── CryptoKeyManager.Codeunit.al        ← Key management
    └── CryptoKeyStorage.Table.al           ← Key storage

Application Licensing Generator/
└── src/License Generation/
    ├── LicenseGenerator.Codeunit.al        ← Generator integration
    └── LicenseManagement.Codeunit.al       ← Generation management
```

## 🔄 Implementation Order

1. **Fix Compilation Errors** (30 minutes)
   - Add missing ToolTips
   - Remove duplicate using statements
   - Fix missing action implementations

2. **Implement Core Generation** (2 hours)
   - Replace TODO comments
   - Add customer line integration
   - Test basic generation

3. **Add Page Actions** (1 hour)
   - Release/Reopen actions
   - Generate license actions
   - Validation actions

4. **Test Integration** (2 hours)
   - Test Generator → Base flow
   - Test bulk operations
   - Verify license storage

5. **Optimize & Polish** (1 hour)
   - Add progress indicators
   - Improve error messages
   - Performance testing

**Total Estimated Time: 6.5 hours**

---

*Use this quick reference to rapidly implement the customer license generation system. Focus on Priority 1 items first to get basic functionality working.*