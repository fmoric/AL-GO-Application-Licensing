namespace ApplicationLicensing.Generator.PageExt;

using ApplicationLicensing.Generator.Pages;
using ApplicationLicensing.Generator.Codeunit;

pageextension 80525 "Crypto Key Management" extends "Crypto Key Management"
{
    actions
    {
        addfirst(Processing)
        {
            action(ImpoertCertificate)
            {
                ApplicationArea = All;
                Caption = 'Import Certificate';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Import a certificate from a .p12 file.';
                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                begin
                    CryptoKeyManager.UploadAndValidateCertificate(Rec);
                end;
            }
        }
        addafter(ImportPublicKey)
        {
            action(DownloadPublicKey)
            {
                ApplicationArea = All;
                Caption = 'Download Public Key';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Download a public key to a PEM file.';
                trigger OnAction()
                var
                    CryptoKeyManager: Codeunit "Crypto Key Manager";
                begin
                    CryptoKeyManager.DownloadPublicKey(Rec);
                end;
            }
        }
    }
}
