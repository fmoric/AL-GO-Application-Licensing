namespace ApplicationLicensing.Pages;

using System.Reflection;
using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;
using ApplicationLicensing.Enums;
/// <summary>
/// Page Crypto Key Management (ID 80506).
/// List page for managing cryptographic keys.
/// </summary>
page 80506 "Crypto Key Management"
{
    PageType = List;

    UsageCategory = Administration;
    SourceTable = "Crypto Key Storage";
    Caption = 'Cryptographic Key Management';
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            repeater(Keys)
            {
                field("Key ID"; Rec."Key ID")
                {
                }
                field("Key Type"; Rec."Key Type")
                {

                    Editable = not Rec."Imported Certificate";
                }
                field(Algorithm; Rec.Algorithm)
                {
                    Editable = not Rec."Imported Certificate";
                }
                field(Active; Rec.Active)
                {
                    Style = Favorable;
                    StyleExpr = Rec.Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("Expires Date"; Rec."Expires Date")
                {
                    Style = Attention;
                    StyleExpr = ValidToExpr;
                    Editable = Rec."Key Type" <> Rec."Key Type"::Certificate;
                }
                field("Usage Count"; Rec."Usage Count")
                {
                }
                field("Created By"; Rec."Created By")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateSigningKey)
            {

                Caption = 'Generate Signing Key';
                Image = EncryptionKeys;
                ToolTip = 'Generate a new RSA signing key.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    KeyId: Text;
                    ExpirationDate: Date;
                begin
                    KeyId := StrSubstNo(KeyIdSigningFormatLbl, Format(CurrentDateTime(), 0, KeyIdDateFormatLbl));
                    ExpirationDate := CalcDate('<+5Y>', Today());

                    if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Signing Key", ExpirationDate) then begin
                        Message(SigningKeyGeneratedMsg, KeyId);
                        CurrPage.Update(false);
                    end else
                        Error(FailedGenerateSigningKeyErr);
                end;
            }
            action(UploadCertificate)
            {

                Caption = 'Upload Certificate';
                Image = Import;
                ToolTip = 'Directly upload and save a .p12 certificate file with automatic key generation.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NewCryptoKeyStorage: Record "Crypto Key Storage";
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                begin
                    CryptoKeyManager.UploadAndValidateCertificate(NewCryptoKeyStorage);
                end;
            }
            action(GenerateValidationKey)
            {

                Caption = 'Generate Validation Key';
                Image = EncryptionKeys;
                ToolTip = 'Generate a new RSA validation key.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    KeyId: Text;
                    ExpirationDate: Date;
                begin
                    KeyId := StrSubstNo(KeyIdValidationFormatLbl, Format(CurrentDateTime(), 0, KeyIdDateFormatLbl));
                    ExpirationDate := CalcDate('<+5Y>', Today());

                    if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Validation Key", ExpirationDate) then begin
                        Message(ValidationKeyGeneratedMsg, KeyId);
                        CurrPage.Update(false);
                    end else
                        Error(FailedGenerateValidationKeyErr);
                end;
            }
            action(DeactivateKey)
            {

                Caption = 'Deactivate Key';
                Image = Cancel;
                ToolTip = 'Deactivate the selected key.';
                Enabled = Rec.Active;

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                begin
                    if not Confirm(ConfirmDeactivateKeyQst, false, Rec."Key ID") then
                        exit;

                    if CryptoKeyManager.DeactivateKey(Rec."Key ID") then
                        Message(KeyDeactivatedSuccessMsg)
                    else
                        Error(FailedDeactivateKeyErr);

                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(CheckSystemStatus)
            {

                Caption = 'Check System Status';
                Image = Status;
                ToolTip = 'Check the status of the cryptographic system.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    StatusMessage: Text;
                begin
                    StatusMessage := CryptoSystemStatusLbl + NewLine() + NewLine();

                    if CryptoKeyManager.IsSigningKeyAvailable() then
                        StatusMessage += SigningKeyAvailableLbl + NewLine()
                    else
                        StatusMessage += SigningKeyNotAvailableLbl + NewLine();

                    StatusMessage += StrSubstNo(TotalKeysLbl, Rec.Count()) + NewLine();

                    Rec.SetRange(Active, true);
                    StatusMessage += StrSubstNo(ActiveKeysLbl, Rec.Count()) + NewLine();

                    Rec.SetRange(Active);
                    Rec.SetRange("Key Type", Rec."Key Type"::"Signing Key");
                    StatusMessage += StrSubstNo(SigningKeysLbl, Rec.Count()) + NewLine();

                    Message(StatusMessage);
                    Rec.SetRange("Key Type");
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Expires Date" < Today() then
            ValidToExpr := Format(PageStyle::Unfavorable)
        else
            ValidToExpr := Format(PageStyle::None);
    end;

    local procedure NewLine(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.NewLine());
    end;

    var
        ValidToExpr: Text;

        // Labels for translatable text
        CryptoSystemStatusLbl: Label 'Cryptographic System Status:';
        SigningKeyAvailableLbl: Label 'Signing Key: Available';
        SigningKeyNotAvailableLbl: Label 'Signing Key: NOT AVAILABLE';
        TotalKeysLbl: Label 'Total Keys: %1', Comment = '%1 = Number of total keys';
        ActiveKeysLbl: Label 'Active Keys: %1', Comment = '%1 = Number of active keys';
        SigningKeysLbl: Label 'Signing Keys: %1', Comment = '%1 = Number of signing keys';
        SigningKeyGeneratedMsg: Label 'Signing key generated successfully: %1', Comment = '%1 = Key ID';
        ValidationKeyGeneratedMsg: Label 'Validation key generated successfully: %1', Comment = '%1 = Key ID';
        KeyDeactivatedSuccessMsg: Label 'Key deactivated successfully.';
        ConfirmDeactivateKeyQst: Label 'Are you sure you want to deactivate key %1?', Comment = '%1 = Key ID';
        FailedGenerateSigningKeyErr: Label 'Failed to generate signing key.';
        FailedGenerateValidationKeyErr: Label 'Failed to generate validation key.';
        FailedDeactivateKeyErr: Label 'Failed to deactivate key.';

        // Locked labels for technical strings
        KeyIdSigningFormatLbl: Label 'SIGN-KEY-%1', Locked = true;
        KeyIdValidationFormatLbl: Label 'VALID-KEY-%1', Locked = true;
        KeyIdDateFormatLbl: Label '<Year4><Month,2><Day,2><Hours24><Minutes,2>', Locked = true;
}