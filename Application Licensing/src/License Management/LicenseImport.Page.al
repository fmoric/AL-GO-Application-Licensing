namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;

/// <summary>
/// Page License Import (ID 80506).
/// Card page for importing license files.
/// </summary>
page 80507 "License Import"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Import License';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(ImportFile)
            {
                Caption = 'License File Import';
                field(LicenseFileContent; LicenseFileContent)
                {
                    ApplicationArea = All;
                    Caption = 'License File Content';
                    ToolTip = 'Paste the complete license file content here, including headers and signature.';
                    MultiLine = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if LicenseFileContent <> '' then begin
                            ParseLicenseFile();
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(ImportFromFile; ImportFromFileVisible)
                {
                    ApplicationArea = All;
                    Caption = 'Import from File';
                    ToolTip = 'Click to import license from a file.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        ImportLicenseFromFile();
                    end;
                }
            }
            group(ParsedData)
            {
                Caption = 'Parsed License Information';
                Visible = ShowParsedData;

                field(ParsedLicenseId; ParsedLicenseId)
                {
                    ApplicationArea = All;
                    Caption = 'License ID';
                    ToolTip = 'The unique license identifier extracted from the file.';
                    Editable = false;
                }
                field(ParsedAppId; ParsedAppId)
                {
                    ApplicationArea = All;
                    Caption = 'Application ID';
                    ToolTip = 'The application identifier for this license.';
                    Editable = false;
                }
                field(ParsedAppName; ParsedAppName)
                {
                    ApplicationArea = All;
                    Caption = 'Application Name';
                    ToolTip = 'The application name from the license.';
                    Editable = false;
                }
                field(ParsedCustomerName; ParsedCustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'The customer name from the license.';
                    Editable = false;
                }
                field(ParsedValidFrom; ParsedValidFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Valid From';
                    ToolTip = 'The license validity start date.';
                    Editable = false;
                }
                field(ParsedValidTo; ParsedValidTo)
                {
                    ApplicationArea = All;
                    Caption = 'Valid To';
                    ToolTip = 'The license validity end date.';
                    Editable = false;
                }
                field(ParsedFeatures; ParsedFeatures)
                {
                    ApplicationArea = All;
                    Caption = 'Licensed Features';
                    ToolTip = 'The features included in this license.';
                    Editable = false;
                    MultiLine = true;
                }
                field(ParsedSignature; ParsedSignature)
                {
                    ApplicationArea = All;
                    Caption = 'Digital Signature';
                    ToolTip = 'The digital signature of the license.';
                    Editable = false;
                }
                field(ValidationStatus; ValidationStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Validation Status';
                    ToolTip = 'The result of license validation.';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = ValidationSuccess;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportLicense)
            {
                ApplicationArea = All;
                Caption = 'Import License';
                Image = Import;
                ToolTip = 'Import the license into the system.';
                Enabled = CanImport;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ImportParsedLicense();
                end;
            }
            action(ValidateLicense)
            {
                ApplicationArea = All;
                Caption = 'Validate License';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate the license signature and content.';
                Enabled = ShowParsedData;

                trigger OnAction()
                begin
                    ValidateParsedLicense();
                end;
            }
            action(ClearData)
            {
                ApplicationArea = All;
                Caption = 'Clear';
                Image = ClearLog;
                ToolTip = 'Clear all imported data and start over.';

                trigger OnAction()
                begin
                    ClearImportData();
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Cancel the import operation.';
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        LicenseFileContent: Text;
        ParsedLicenseId: Guid;
        ParsedAppId: Guid;
        ParsedAppName: Text[100];
        ParsedCustomerName: Text[100];
        ParsedValidFrom: Date;
        ParsedValidTo: Date;
        ParsedFeatures: Text[250];
        ParsedSignature: Text[1024];
        ValidationStatus: Text[100];
        ShowParsedData: Boolean;
        CanImport: Boolean;
        ValidationSuccess: Boolean;
        ImportFromFileVisible: Text[20];

        // Labels for translatable text
        LicenseImportedSuccessMsg: Label 'License imported successfully.\\License ID: %1';
        LicenseAlreadyExistsErr: Label 'A license with ID %1 already exists in the system.';
        InvalidLicenseFormatErr: Label 'Invalid license file format. Please check the file content.';
        LicenseValidationFailedErr: Label 'License validation failed: %1';
        ApplicationNotFoundWarning: Label 'Warning: Application %1 (%2) is not registered in the system.';
        ConfirmImportInvalidLicenseQst: Label 'The license validation failed. Do you want to import it anyway?';

        // Locked labels for technical strings
        LicenseHeaderLbl: Label '--- BEGIN LICENSE ---', Locked = true;
        SignatureHeaderLbl: Label '--- BEGIN SIGNATURE ---', Locked = true;
        LicenseFooterLbl: Label '--- END LICENSE ---', Locked = true;
        ImportFromFileLbl: Label 'Browse...', Locked = true;

    trigger OnOpenPage()
    begin
        ImportFromFileVisible := ImportFromFileLbl;
        ShowParsedData := false;
        CanImport := false;
        ValidationSuccess := false;
    end;

    /// <summary>
    /// Imports license content from a file.
    /// </summary>
    local procedure ImportLicenseFromFile()
    var
        InStream: InStream;
        FileName: Text;
        FileContent: Text;
        TempText: Text;
    begin
        if UploadIntoStream(ImportLicenseDialogLbl, '', ImportLicenseFileFilterLbl, FileName, InStream) then begin
            // Read the entire file content
            FileContent := '';
            while not InStream.EOS do begin
                InStream.ReadText(TempText);
                if FileContent <> '' then
                    FileContent += '\' + TempText
                else
                    FileContent := TempText;
            end;

            if FileContent <> '' then begin
                LicenseFileContent := FileContent;
                ParseLicenseFile();
                CurrPage.Update(false);
            end;
        end;
    end;

    /// <summary>
    /// Parses the license file content and extracts license information.
    /// </summary>
    local procedure ParseLicenseFile()
    var
        LicenseContent: Text;
        SignatureContent: Text;
        LicenseData: Text;
    begin
        ClearImportData();

        if not ExtractLicenseComponents(LicenseFileContent, LicenseContent, SignatureContent) then begin
            Error(InvalidLicenseFormatErr);
            exit;
        end;

        if not ParseLicenseContent(LicenseContent) then begin
            Error(InvalidLicenseFormatErr);
            exit;
        end;

        ParsedSignature := CopyStr(SignatureContent, 1, MaxStrLen(ParsedSignature));
        ShowParsedData := true;
        CanImport := true;

        // Automatically validate the license
        ValidateParsedLicense();
    end;

    /// <summary>
    /// Extracts license content and signature from the license file.
    /// </summary>
    local procedure ExtractLicenseComponents(FileContent: Text; var LicenseContent: Text; var SignatureContent: Text): Boolean
    var
        LicenseStartPos: Integer;
        LicenseEndPos: Integer;
        SignatureStartPos: Integer;
        SignatureEndPos: Integer;
    begin
        // Find license content
        LicenseStartPos := FileContent.IndexOf(LicenseHeaderLbl);
        SignatureStartPos := FileContent.IndexOf(SignatureHeaderLbl);
        SignatureEndPos := FileContent.IndexOf(LicenseFooterLbl);

        if (LicenseStartPos = 0) or (SignatureStartPos = 0) or (SignatureEndPos = 0) then
            exit(false);

        // Extract license content (between BEGIN LICENSE and BEGIN SIGNATURE)
        LicenseStartPos := LicenseStartPos + StrLen(LicenseHeaderLbl);
        LicenseContent := FileContent.Substring(LicenseStartPos, SignatureStartPos - LicenseStartPos).Trim();

        // Extract signature content (between BEGIN SIGNATURE and END LICENSE)
        SignatureStartPos := SignatureStartPos + StrLen(SignatureHeaderLbl);
        SignatureContent := FileContent.Substring(SignatureStartPos, SignatureEndPos - SignatureStartPos).Trim();

        exit((LicenseContent <> '') and (SignatureContent <> ''));
    end;

    /// <summary>
    /// Parses the license content string and extracts individual fields.
    /// </summary>
    local procedure ParseLicenseContent(LicenseContent: Text): Boolean
    var
        LicenseFields: List of [Text];
        FieldPair: Text;
        FieldName: Text;
        FieldValue: Text;
        ColonPos: Integer;
    begin
        // Split license content by pipe characters
        LicenseFields := LicenseContent.Split('|');

        foreach FieldPair in LicenseFields do begin
            ColonPos := FieldPair.IndexOf(':');
            if ColonPos > 0 then begin
                FieldName := FieldPair.Substring(1, ColonPos - 1);
                FieldValue := FieldPair.Substring(ColonPos + 1);

                case FieldName of
                    'ID':
                        if not Evaluate(ParsedLicenseId, FieldValue) then
                            exit(false);
                    'APP-ID':
                        if not Evaluate(ParsedAppId, FieldValue) then
                            exit(false);
                    'APP-NAME':
                        ParsedAppName := CopyStr(FieldValue, 1, MaxStrLen(ParsedAppName));
                    'CUSTOMER':
                        ParsedCustomerName := CopyStr(FieldValue, 1, MaxStrLen(ParsedCustomerName));
                    'VALID-FROM':
                        if not Evaluate(ParsedValidFrom, FieldValue) then
                            exit(false);
                    'VALID-TO':
                        if not Evaluate(ParsedValidTo, FieldValue) then
                            exit(false);
                    'FEATURES':
                        ParsedFeatures := CopyStr(FieldValue, 1, MaxStrLen(ParsedFeatures));
                end;
            end;
        end;

        exit(not IsNullGuid(ParsedLicenseId) and not IsNullGuid(ParsedAppId));
    end;

    /// <summary>
    /// Validates the parsed license using the license validation system.
    /// </summary>
    local procedure ValidateParsedLicense()
    var
        LicenseGenerator: Codeunit "License Generator";
        ApplicationRegistry: Record "Application Registry";
    begin
        ValidationSuccess := false;
        ValidationStatus := '';

        // Check if application exists
        if not ApplicationRegistry.Get(ParsedAppId) then begin
            ValidationStatus := StrSubstNo(ApplicationNotFoundWarning, ParsedAppName, ParsedAppId);
            exit;
        end;

        // Create a temporary license record for validation
        if ValidateTemporaryLicense() then begin
            ValidationStatus := ValidLicenseLbl;
            ValidationSuccess := true;
        end else begin
            ValidationStatus := InvalidLicenseLbl;
            ValidationSuccess := false;
        end;
    end;

    /// <summary>
    /// Creates a temporary license record and validates it.
    /// </summary>
    local procedure ValidateTemporaryLicense(): Boolean
    var
        TempLicenseRegistry: Record "License Registry" temporary;
        LicenseGenerator: Codeunit "License Generator";
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(ParsedAppId) then
            exit(false);

        // Create temporary license record
        TempLicenseRegistry.Init();
        TempLicenseRegistry."License ID" := ParsedLicenseId;
        TempLicenseRegistry."App ID" := ParsedAppId;
        TempLicenseRegistry."Customer Name" := ParsedCustomerName;
        TempLicenseRegistry."Valid From" := ParsedValidFrom;
        TempLicenseRegistry."Valid To" := ParsedValidTo;
        TempLicenseRegistry.Features := ParsedFeatures;
        TempLicenseRegistry."Digital Signature" := ParsedSignature;
        TempLicenseRegistry.Status := TempLicenseRegistry.Status::Active;
        TempLicenseRegistry.Insert();

        // Validate the license
        exit(LicenseGenerator.ValidateLicense(ParsedLicenseId));
    end;

    /// <summary>
    /// Imports the parsed license into the license registry.
    /// </summary>
    local procedure ImportParsedLicense()
    var
        LicenseRegistry: Record "License Registry";
        ApplicationRegistry: Record "Application Registry";
        TempBlob: Codeunit System.Utilities."Temp Blob";
        LicenseOutStream: OutStream;
    begin
        // Check if license already exists
        if LicenseRegistry.Get(ParsedLicenseId) then
            Error(LicenseAlreadyExistsErr, ParsedLicenseId);

        // Warn if validation failed but allow import
        if not ValidationSuccess then begin
            if not Confirm(StrSubstNo(ConfirmImportInvalidLicenseQst), false) then
                exit;
        end;

        // Create license registry entry
        LicenseRegistry.Init();
        LicenseRegistry."License ID" := ParsedLicenseId;
        LicenseRegistry."App ID" := ParsedAppId;
        LicenseRegistry."Customer Name" := ParsedCustomerName;
        LicenseRegistry."Valid From" := ParsedValidFrom;
        LicenseRegistry."Valid To" := ParsedValidTo;
        LicenseRegistry.Features := ParsedFeatures;
        LicenseRegistry."Digital Signature" := ParsedSignature;
        LicenseRegistry.Status := LicenseRegistry.Status::Active;

        // Store original license file as blob
        LicenseRegistry."License File".CreateOutStream(LicenseOutStream);
        LicenseOutStream.WriteText(LicenseFileContent);

        if LicenseRegistry.Insert(true) then begin
            Message(LicenseImportedSuccessMsg, ParsedLicenseId);
            CurrPage.Close();
        end;
    end;

    /// <summary>
    /// Clears all imported data and resets the form.
    /// </summary>
    local procedure ClearImportData()
    begin
        Clear(ParsedLicenseId);
        Clear(ParsedAppId);
        Clear(ParsedAppName);
        Clear(ParsedCustomerName);
        Clear(ParsedValidFrom);
        Clear(ParsedValidTo);
        Clear(ParsedFeatures);
        Clear(ParsedSignature);
        Clear(ValidationStatus);
        ShowParsedData := false;
        CanImport := false;
        ValidationSuccess := false;
        CurrPage.Update(false);
    end;

    var
        // Additional labels
        ValidLicenseLbl: Label 'Valid License';
        InvalidLicenseLbl: Label 'Invalid License';
        ImportLicenseDialogLbl: Label 'Import License File';
        ImportLicenseFileFilterLbl: Label 'License Files (*.lic)|*.lic|Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
}