namespace ApplicationLicensing.Tables;

using ApplicationLicensing.Enums;
using System.Security.AccessControl;
using ApplicationLicensing.Pages;

/// <summary>
/// Table Crypto Key Storage (ID 80502).
/// Stores RSA public/private key pairs for license signing and validation.
/// </summary>
table 80502 "Crypto Key Storage"
{
    DataClassification = SystemMetadata;
    Caption = 'Cryptographic Key Storage';
    LookupPageId = "Crypto Key Management";
    DrillDownPageId = "Crypto Key Management";
    fields
    {
        field(1; "Key ID"; Code[20])
        {
            Caption = 'Key ID';
            ToolTip = 'Specifies the unique identifier for the cryptographic key.';
            NotBlank = true;
        }
        field(2; "Key Type"; Enum "Crypto Key Type")
        {
            Caption = 'Key Type';
            ToolTip = 'Specifies the type of cryptographic key.';
            NotBlank = true;
        }
        field(3; Algorithm; Text[50])
        {
            Caption = 'Algorithm';
            InitValue = 'RSA-2048';
            ToolTip = 'Specifies the cryptographic algorithm used for the key.';
        }
        field(4; "Certificate Storage GUID"; Guid)
        {
            Caption = 'Certificate Storage GUID';
            ToolTip = 'Specifies the GUID for the certificate in the certificate store.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(5; "Cert. Password GUID"; Guid)
        {
            Caption = 'Certificate Password GUID';
            ToolTip = 'Specifies the GUID for the certificate password in the secure storage.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(6; "Cert. Expiration Date"; DateTime)
        {
            Caption = 'Cert. Expiration Date';
            Editable = false;
            ToolTip = 'Specifies the expiration date of the certificate.';
            AllowInCustomizations = Never;
        }
        field(7; "Cert. ThumbPrint"; Text[100])
        {
            Caption = 'Cert. ThumbPrint';
            Editable = false;
            ToolTip = 'Specifies the thumbprint of the certificate.';
            AllowInCustomizations = Never;
        }
        field(8; "Cert. Issued By"; Text[100])
        {
            Caption = 'Cert. Issued By';
            Editable = false;
            ToolTip = 'Specifies who issued the certificate.';
            AllowInCustomizations = Never;
        }
        field(9; "Cert. Issued To"; Text[100])
        {
            Caption = 'Cert. Issued To';
            Editable = false;
            ToolTip = 'Specifies who the certificate is issued to.';
            AllowInCustomizations = Never;
        }
        field(10; "Cert. Friendly Name"; Text[100])
        {
            Caption = 'Cert. Friendly Name';
            Editable = false;
            ToolTip = 'Specifies the friendly name of the certificate.';
            AllowInCustomizations = Never;
        }
        field(11; "Cert. Has Priv. Key"; Boolean)
        {
            Caption = 'Cert. Has Priv. Key';
            Editable = false;
            ToolTip = 'Indicates whether the certificate has an associated private key.';
            AllowInCustomizations = Never;
        }
        field(12; "Public Key"; Blob)
        {
            Caption = 'Public Key';
            ToolTip = 'Specifies the public key in binary format.';
        }
        field(13; "Private Key"; Blob)
        {
            Caption = 'Private Key';
            ToolTip = 'Specifies the private key in binary format.';
        }
        field(14; Active; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
            ToolTip = 'Indicates whether the cryptographic key is active and can be used.';
        }
        field(15; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
            ToolTip = 'Specifies when the key was created.';
        }
        field(16; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ToolTip = 'Specifies who created the key.';
        }
        field(17; "Expires Date"; Date)
        {
            Caption = 'Expires Date';
            ToolTip = 'Specifies when the key expires.';

        }
        field(18; "Usage Count"; Integer)
        {
            Caption = 'Usage Count';
            Editable = false;
            ToolTip = 'Specifies how many times the key has been used.';
        }
        field(19; "Imported Certificate"; Boolean)
        {
            Caption = 'Imported Certificate';
            ToolTip = 'Indicates whether the certificate was imported.';
            AllowInCustomizations = Never;
            Editable = false;
            InitValue = false;
        }
    }

    keys
    {
        key(PK; "Key ID")
        {
            Clustered = true;
        }
        key(TypeActive; "Key Type", Active)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Key ID", "Key Type", Active)
        {
        }
        fieldgroup(Brick; "Key ID", "Key Type", Active)
        {
        }
    }
    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime();
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;
}