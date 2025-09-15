/// <summary>
/// Table License Registry (ID 80501).
/// Stores generated licenses with metadata and validation information.
/// </summary>
table 80501 "License Registry"
{
    DataClassification = SystemMetadata;
    Caption = 'License Registry';
    LookupPageId = "License Registry";
    DrillDownPageId = "License Registry";

    fields
    {
        field(1; "License ID"; Guid)
        {
            Caption = 'License ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2; "App ID"; Guid)
        {
            Caption = 'Application ID';
            DataClassification = SystemMetadata;
            TableRelation = "Application Registry"."App ID";
            NotBlank = true;
        }
        field(3; "App Name"; Text[100])
        {
            Caption = 'Application Name';
            DataClassification = SystemMetadata;
            CalcFormula = lookup("Application Registry"."App Name" where("App ID" = field("App ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Valid From"; Date)
        {
            Caption = 'Valid From';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(6; "Valid To"; Date)
        {
            Caption = 'Valid To';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(7; "Features"; Text[250])
        {
            Caption = 'Licensed Features';
            DataClassification = SystemMetadata;
        }
        field(8; "License File"; Blob)
        {
            Caption = 'License File';
            DataClassification = SystemMetadata;
        }
        field(9; "Digital Signature"; Text[1024])
        {
            Caption = 'Digital Signature';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Status"; Enum "License Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            InitValue = Active;
        }
        field(11; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(13; "Last Validated"; DateTime)
        {
            Caption = 'Last Validated';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Validation Result"; Text[100])
        {
            Caption = 'Last Validation Result';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "License ID")
        {
            Clustered = true;
        }
        key(AppId; "App ID", "Valid From")
        {
        }
        key(Customer; "Customer Name")
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
        LicenseMgmt: Codeunit "License Management";
    begin
        LicenseMgmt.OnLicenseDeleted("License ID");
    end;
}