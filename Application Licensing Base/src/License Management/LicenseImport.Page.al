namespace ApplicationLicensing.Base.Pages;

using ApplicationLicensing.Base.Codeunit;
using ApplicationLicensing.Base.Tables;
using System.Reflection;
using System.IO;
using System.Utilities;

/// <summary>
/// Page License Import (ID 80502).
/// Card page for importing license files into the Base Application.
/// 
/// This page allows users to:
/// - Import license files from external sources
/// - Parse and validate license content
/// - Store licenses in the License Registry
/// </summary>
page 80501 "License Import"
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
            group(ParsedData)
            {
                Caption = 'Parsed License Information';
                Visible = ShowParsedData;

                field(ParsedLicenseId; ParsedLicenseId)
                {
                    ApplicationArea = All;
                    Caption = 'License ID';
                    ToolTip = 'Specifies the unique identifier for this license.';
                    Editable = false;
                }
                field(ParsedAppId; ParsedAppId)
                {
                    ApplicationArea = All;
                    Caption = 'Application ID';
                    ToolTip = 'Specifies the unique identifier of the application this license is for.';
                    Editable = false;
                }
                field(ParsedAppName; ParsedAppName)
                {
                    ApplicationArea = All;
                    Caption = 'Application Name';
                    ToolTip = 'Specifies the name of the application.';
                    Editable = false;
                }
                field(ParsedCustomerName; ParsedCustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer.';
                    Editable = false;
                }
                field(ParsedValidFrom; ParsedValidFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Valid From';
                    ToolTip = 'Specifies the start date of the license validity.';
                    Editable = false;
                }
                field(ParsedValidTo; ParsedValidTo)
                {
                    ApplicationArea = All;
                    Caption = 'Valid To';
                    ToolTip = 'Specifies the end date of the license validity.';
                    Editable = false;
                }
                field(ParsedFeatures; ParsedFeatures)
                {
                    ApplicationArea = All;
                    Caption = 'Licensed Features';
                    ToolTip = 'Specifies the features enabled by this license.';
                    Editable = false;
                }
                field(ValidationStatus; ValidationStatus)
                {
                    ApplicationArea = All;
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
            action(ImportFromFile)
            {
                ApplicationArea = All;
                Caption = 'Import from File';
                Image = Import;
                ToolTip = 'Import a license file from disk.';
                InFooterBar = true;

                trigger OnAction()
                begin
                    ImportLicenseFromFile();
                end;
            }
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
        LicenseValidator: Codeunit "License Validator";
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

        // Labels
        LicenseImportedSuccessMsg: Label 'License imported successfully.\\License ID: %1', Comment = '%1 = License ID';
        LicenseAlreadyExistsErr: Label 'A license with ID %1 already exists in the system.', Comment = '%1 = License ID';
        InvalidLicenseFormatErr: Label 'Invalid license file format. Please check the file content.';
        ApplicationNotFoundWarningMsg: Label 'Warning: Application %1 (%2) is not registered in the system.', Comment = '%1 = Application Name, %2 = Application ID';
        ConfirmImportInvalidLicenseQst: Label 'The license validation failed. Do you want to import it anyway?';
        ImportLicenseDialogLbl: Label 'Import License File';
        ImportLicenseFileFilterLbl: Label 'License Files (*.lic)|*.lic|Text Files (*.txt)|*.txt|All Files (*.*)|*.*';

    trigger OnOpenPage()
    begin
        ShowParsedData := false;
        CanImport := false;
        ValidationSuccess := false;
    end;

    /// <summary>
    /// Imports a license file from disk and parses its content.
    /// </summary>
    local procedure ImportLicenseFromFile()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        //TODO upload and validate license
    end;

    /// <summary>
    /// Parses the imported license file content.
    /// </summary>
    /// <returns>True if parsing was successful.</returns>
    local procedure ParseLicenseFile(): Boolean
    var
        LicenseContent: Text;
        SignatureContent: Text;
        LicenseFields: List of [Text];
        FieldPair: Text;
        FieldName: Text;
        FieldValue: Text;
        ColonPos: Integer;
    begin
        // Extract license and signature content
        if not LicenseValidator.ParseLicenseFile(LicenseFileContent, LicenseContent, SignatureContent) then
            exit(false);

        ParsedSignature := CopyStr(SignatureContent, 1, MaxStrLen(ParsedSignature));

        // Parse license content fields
        LicenseFields := LicenseContent.Split('|');
        foreach FieldPair in LicenseFields do begin
            ColonPos := FieldPair.IndexOf(':');
            if ColonPos > 0 then begin
                FieldName := FieldPair.Substring(1, ColonPos - 1);
                FieldValue := FieldPair.Substring(ColonPos + 1);
                ParseLicenseField(FieldName, FieldValue);
            end;
        end;

        exit(not IsNullGuid(ParsedLicenseId) and not IsNullGuid(ParsedAppId));
    end;

    /// <summary>
    /// Parses individual license fields.
    /// </summary>
    /// <param name="FieldName">The field name.</param>
    /// <param name="FieldValue">The field value.</param>
    local procedure ParseLicenseField(FieldName: Text; FieldValue: Text)
    var
        TempGuid: Guid;
        TempDate: Date;
    begin
        case FieldName of
            'ID':
                if Evaluate(TempGuid, FieldValue) then
                    ParsedLicenseId := TempGuid;
            'APP-ID':
                if Evaluate(TempGuid, FieldValue) then
                    ParsedAppId := TempGuid;
            'APP-NAME':
                ParsedAppName := CopyStr(FieldValue, 1, MaxStrLen(ParsedAppName));
            'CUSTOMER':
                ParsedCustomerName := CopyStr(FieldValue, 1, MaxStrLen(ParsedCustomerName));
            'VALID-FROM':
                if Evaluate(TempDate, FieldValue) then
                    ParsedValidFrom := TempDate;
            'VALID-TO':
                if Evaluate(TempDate, FieldValue) then
                    ParsedValidTo := TempDate;
            'FEATURES':
                ParsedFeatures := CopyStr(FieldValue, 1, MaxStrLen(ParsedFeatures));
        end;
    end;



    /// <summary>
    /// Clears all imported data and resets the form.
    /// </summary>
    local procedure ClearImportData()
    begin
        Clear(LicenseFileContent);
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
}