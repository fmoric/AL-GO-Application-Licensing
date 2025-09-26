namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;
using System.Reflection;

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
    Permissions = tabledata "Application Registry" = r,
                    tabledata "License Registry" = ir;

    layout
    {
        area(Content)
        {
            group(ParsedData)
            {
                Caption = 'Parsed License Information';
                Visible = ShowParsedData;

                field(ParsedLicenseId; ParsedLicenseId)
                {

                    Caption = 'License ID';
                    ToolTip = 'Specifies the unique identifier for this license.';
                    Editable = false;
                }
                field(ParsedAppId; ParsedAppId)
                {

                    Caption = 'Application ID';
                    ToolTip = 'Specifies the unique identifier of the application this license is for.';
                    Editable = false;
                }
                field(ParsedAppName; ParsedAppName)
                {

                    Caption = 'Application Name';
                    ToolTip = 'Specifies the name of the application this license is for.';
                    Editable = false;
                }
                field(ParsedCustomerName; ParsedCustomerName)
                {

                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer to whom this license is issued.';
                    Editable = false;
                }
                field(ParsedValidFrom; ParsedValidFrom)
                {

                    Caption = 'Valid From';
                    ToolTip = 'Specifies the license validity start date.';
                    Editable = false;
                }
                field(ParsedValidTo; ParsedValidTo)
                {

                    Caption = 'Valid To';
                    ToolTip = 'Specifies the license validity end date.';
                    Editable = false;
                }
                field(ParsedFeatures; ParsedFeatures)
                {

                    Caption = 'Licensed Features';
                    ToolTip = 'Specifies the features enabled by this license.';
                    Editable = false;
                    MultiLine = true;
                }
                field(ParsedSignature; ParsedSignature)
                {

                    Caption = 'Digital Signature';
                    ToolTip = 'Specifies the digital signature of the license.';
                    Editable = false;
                }
                field(ValidationStatus; ValidationStatus)
                {

                    Caption = 'Validation Status';
                    ToolTip = 'Specifies the result of the license validation.';
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
            action(ClearData)
            {

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
        LicenseImportedSuccessMsg: Label 'License imported successfully.\\License ID: %1', Comment = '%1 = License ID';
        LicenseAlreadyExistsErr: Label 'A license with ID %1 already exists in the system.', Comment = '%1 = License ID';
        InvalidLicenseFormatErr: Label 'Invalid license file format. Please check the file content.';
        ApplicationNotFoundWarningMsg: Label 'Warning: Application %1 (%2) is not registered in the system.', Comment = '%1 = Application Name, %2 = Application ID';
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
    /// Extracts license content and signature from the license file.
    /// </summary>
    /// <param name="FileContent">The full content of the license file.</param>
    /// <param name="LicenseContent">Output parameter for the main license content.</param>
    /// <param name="SignatureContent">Output parameter for the signature content.</param>
    /// <returns>True if extraction was successful, false otherwise.</returns>
    local procedure ExtractLicenseComponents(FileContent: Text; var LicenseContent: Text; var SignatureContent: Text): Boolean
    var
        LicenseStartPos: Integer;
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
    /// <param name="LicenseContent">The main license content string.</param>
    /// <returns>True if parsing was successful, false otherwise.</returns>
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

                ParseLicenseContentCase(FieldName, FieldValue);
            end;
        end;

        exit(not IsNullGuid(ParsedLicenseId) and not IsNullGuid(ParsedAppId));
    end;


    /// <summary>
    /// Imports the parsed license into the license registry.
    /// </summary>
    local procedure ImportParsedLicense()
    var
        LicenseRegistry: Record "License Registry";
        LicenseOutStream: OutStream;
    begin
        // Check if license already exists
        if LicenseRegistry.Get(ParsedLicenseId) then
            Error(LicenseAlreadyExistsErr, ParsedLicenseId);

        // Warn if validation failed but allow import
        if not ValidationSuccess then
            if not Confirm(StrSubstNo(ConfirmImportInvalidLicenseQst), false) then
                exit;

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

    local procedure ParseLicenseContentCase(FieldName: Text; FieldValue: Text) IsOk: Boolean
    var
        ContentDict: Dictionary of [Text, Dictionary of [Boolean, Text]];
        DicOfEval: Dictionary of [Boolean, Text];
        FormatTxT: Text;
    begin

        IsOk := true;
        PopulateParseLicenseContentCaseSetDict(ContentDict);

        if not ContentDict.Get(FieldName, DicOfEval) then
            exit(false);

        if not DicOfEval.Get(true, FormatTxT) then
            FormatTxT := 'Text';

        case FormatTxT of
            'Guid':
                IsOk := HandleGUID(FieldName, FieldValue);
            'Date':
                IsOk := HandleDate(FieldName, FieldValue);
            'Text':
                HandleText(FieldName, FieldValue);

        end;
        exit(IsOk);
    end;

    local procedure PopulateParseLicenseContentCaseSetDict(var ContentDict: Dictionary of [Text, Dictionary of [Boolean, Text]])
    var
        DicOfEval: Dictionary of [Boolean, Text];
    begin
        Clear(DicOfEval);
        DicOfEval.Add(true, 'Guid');
        ContentDict.Add('ID', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(true, 'Guid');
        ContentDict.Add('APP-ID', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(false, 'Text');
        ContentDict.Add('APP-NAME', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(false, 'Text');
        ContentDict.Add('CUSTOMER', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(true, 'Date');
        ContentDict.Add('VALID-FROM', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(true, 'Date');
        ContentDict.Add('VALID-TO', DicOfEval);

        Clear(DicOfEval);
        DicOfEval.Add(false, 'Text');
        ContentDict.Add('FEATURES', DicOfEval);
    end;

    local procedure HandleGUID(FieldName: Text; FieldValue: Text): Boolean
    var
        FormatGuid: Guid;
    begin
        if not Evaluate(FormatGuid, FieldValue) then
            exit(false);

        case FieldName of
            'ID':
                ParsedLicenseId := FormatGuid;
            'APP-ID':
                ParsedAppId := FormatGuid;
        end;
    end;

    local procedure HandleDate(FieldName: Text; FieldValue: Text): Boolean
    var
        FormatDate: Date;
    begin
        if not Evaluate(FormatDate, FieldValue) then
            exit(false);

        case FieldName of
            'VALID-FROM':
                ParsedValidFrom := FormatDate;
            'VALID-TO':
                ParsedValidTo := FormatDate;
        end;
        exit(true);
    end;

    local procedure HandleText(FieldName: Text; FieldValue: Text)
    begin
        case FieldName of
            'APP-NAME':
                ParsedAppName := CopyStr(FieldValue, 1, MaxStrLen(ParsedAppName));
            'CUSTOMER':
                ParsedCustomerName := CopyStr(FieldValue, 1, MaxStrLen(ParsedCustomerName));
            'FEATURES':
                ParsedFeatures := CopyStr(FieldValue, 1, MaxStrLen(ParsedFeatures));
        end;
    end;

    var
        // Additional labels
        ValidLicenseLbl: Label 'Valid License', MaxLength = 100;
        InvalidLicenseLbl: Label 'Invalid License', MaxLength = 100;
        ImportLicenseDialogLbl: Label 'Import License File';
        ImportLicenseFileFilterLbl: Label 'License Files (*.lic)|*.lic|Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
}