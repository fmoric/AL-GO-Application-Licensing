/// <summary>
/// Table Crypto Key Storage (ID 80502).
/// Stores RSA public/private key pairs for license signing and validation.
/// </summary>
table 80502 "Crypto Key Storage"
{
    DataClassification = SystemMetadata;
    Caption = 'Cryptographic Key Storage';

    fields
    {
        field(1; "Key ID"; Code[20])
        {
            Caption = 'Key ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2; "Key Type"; Enum "Crypto Key Type")
        {
            Caption = 'Key Type';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; "Algorithm"; Text[50])
        {
            Caption = 'Algorithm';
            DataClassification = SystemMetadata;
            InitValue = 'RSA-2048';
        }
        field(4; "Public Key"; Blob)
        {
            Caption = 'Public Key';
            DataClassification = SystemMetadata;
        }
        field(5; "Private Key"; Blob)
        {
            Caption = 'Private Key';
            DataClassification = SystemMetadata;
        }
        field(6; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(7; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(9; "Expires Date"; Date)
        {
            Caption = 'Expires Date';
            DataClassification = SystemMetadata;
        }
        field(10; "Usage Count"; Integer)
        {
            Caption = 'Usage Count';
            DataClassification = SystemMetadata;
            Editable = false;
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

    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
    end;

    trigger OnDelete()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo('Are you sure you want to delete the cryptographic key %1?', "Key ID"), false) then
            Error('');
    end;
}