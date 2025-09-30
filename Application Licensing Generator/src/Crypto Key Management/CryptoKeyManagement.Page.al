namespace ApplicationLicensing.Generator.Pages;

using System.Reflection;
using ApplicationLicensing.Generator.Codeunit;
using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Generator.Enums;
/// <summary>
/// Page Crypto Key Management (ID 80506).
/// List page for managing cryptographic keys.
/// </summary>
page 80529 "Crypto Key Management"
{
    PageType = List;

    UsageCategory = Administration;
    SourceTable = "Crypto Key Storage";
    Caption = 'Cryptographic Key Management';
    ApplicationArea = All;
    DelayedInsert = true;
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
            action(ImportPublicKey)
            {
                Caption = 'Import Public Key';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Import an existing public key certificate.';
                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                begin
                    CryptoKeyManager.UploadPublicKey(Rec);
                end;
            }

        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ImportPublicKey_Promoted; ImportPublicKey)
                {
                }
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