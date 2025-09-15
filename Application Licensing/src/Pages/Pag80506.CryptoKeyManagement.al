/// <summary>
/// Page Crypto Key Management (ID 80506).
/// List page for managing cryptographic keys.
/// </summary>
page 80506 "Crypto Key Management"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Crypto Key Storage";
    Caption = 'Cryptographic Key Management';

    layout
    {
        area(Content)
        {
            repeater(Keys)
            {
                field("Key ID"; Rec."Key ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique key identifier.';
                }
                field("Key Type"; Rec."Key Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of cryptographic key.';
                }
                field(Algorithm; Rec.Algorithm)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cryptographic algorithm used.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the key is active.';
                    Style = Favorable;
                    StyleExpr = Rec.Active;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the key was created.';
                }
                field("Expires Date"; Rec."Expires Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the key expires.';
                    Style = Attention;
                    StyleExpr = (Rec."Expires Date" <> 0D) and (Rec."Expires Date" < Today);
                }
                field("Usage Count"; Rec."Usage Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many times the key has been used.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the key.';
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
                ApplicationArea = All;
                Caption = 'Generate Signing Key';
                Image = EncryptionKeys;
                ToolTip = 'Generate a new RSA signing key.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    KeyId: Text;
                    ExpirationDate: Date;
                begin
                    KeyId := StrSubstNo('SIGN-KEY-%1', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2>'));
                    ExpirationDate := CalcDate('<+5Y>', Today);
                    
                    if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Signing Key", ExpirationDate) then begin
                        Message('Signing key generated successfully: %1', KeyId);
                        CurrPage.Update(false);
                    end else
                        Error('Failed to generate signing key.');
                end;
            }
            action(GenerateValidationKey)
            {
                ApplicationArea = All;
                Caption = 'Generate Validation Key';
                Image = EncryptionKeys;
                ToolTip = 'Generate a new RSA validation key.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    KeyId: Text;
                    ExpirationDate: Date;
                begin
                    KeyId := StrSubstNo('VALID-KEY-%1', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2>'));
                    ExpirationDate := CalcDate('<+5Y>', Today);
                    
                    if CryptoKeyManager.GenerateKeyPair(CopyStr(KeyId, 1, 20), "Crypto Key Type"::"Validation Key", ExpirationDate) then begin
                        Message('Validation key generated successfully: %1', KeyId);
                        CurrPage.Update(false);
                    end else
                        Error('Failed to generate validation key.');
                end;
            }
            action(DeactivateKey)
            {
                ApplicationArea = All;
                Caption = 'Deactivate Key';
                Image = Cancel;
                ToolTip = 'Deactivate the selected key.';
                Enabled = Rec.Active;

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if ConfirmManagement.GetResponseOrDefault(
                        StrSubstNo('Are you sure you want to deactivate key %1?', Rec."Key ID"), false) then begin
                        if CryptoKeyManager.DeactivateKey(Rec."Key ID") then begin
                            Message('Key deactivated successfully.');
                            CurrPage.Update(false);
                        end else
                            Error('Failed to deactivate key.');
                    end;
                end;
            }
        }
        area(Navigation)
        {
            action(CheckSystemStatus)
            {
                ApplicationArea = All;
                Caption = 'Check System Status';
                Image = Status;
                ToolTip = 'Check the status of the cryptographic system.';

                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                    StatusMessage: Text;
                begin
                    StatusMessage := 'Cryptographic System Status:' + NewLine() + NewLine();
                    
                    if CryptoKeyManager.IsSigningKeyAvailable() then
                        StatusMessage += 'Signing Key: Available' + NewLine()
                    else
                        StatusMessage += 'Signing Key: NOT AVAILABLE' + NewLine();
                    
                    StatusMessage += StrSubstNo('Total Keys: %1', Rec.Count) + NewLine();
                    
                    Rec.SetRange(Active, true);
                    StatusMessage += StrSubstNo('Active Keys: %1', Rec.Count) + NewLine();
                    
                    Rec.SetRange(Active);
                    Rec.SetRange("Key Type", Rec."Key Type"::"Signing Key");
                    StatusMessage += StrSubstNo('Signing Keys: %1', Rec.Count) + NewLine();

                    Message(StatusMessage);
                    Rec.SetRange("Key Type");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    local procedure NewLine(): Text[1]
    begin
        exit('\n');
    end;
}