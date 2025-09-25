namespace ApplicationLicensing.Tables;

using ApplicationLicensing.Codeunit;
using System.Security.AccessControl;
using ApplicationLicensing.Pages;
using ApplicationLicensing.Enums;

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
            ToolTip = 'Unique identifier for the license.';
            NotBlank = true;
        }
        field(2; "App ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Unique identifier for the application.';
            AllowInCustomizations = Never;
            TableRelation = "Application Registry"."App ID";
            NotBlank = true;
        }
        field(3; "App Name"; Text[100])
        {
            Caption = 'Application Name';
            ToolTip = 'Name of the registered application.';
            CalcFormula = lookup("Application Registry"."App Name" where("App ID" = field("App ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Name of the customer to whom the license is issued.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Valid From"; Date)
        {
            Caption = 'Valid From';
            ToolTip = 'Start date of the license validity period.';
            NotBlank = true;
        }
        field(6; "Valid To"; Date)
        {
            Caption = 'Valid To';
            ToolTip = 'End date of the license validity period.';
            NotBlank = true;
        }
        field(7; Features; Text[250])
        {
            Caption = 'Licensed Features';
            ToolTip = 'Features enabled by this license.';
        }
        field(8; "License File"; Blob)
        {
            Caption = 'License File';
            ToolTip = 'The actual license file content.';
        }
        field(9; "Digital Signature"; Text[1024])
        {
            Caption = 'Digital Signature';
            ToolTip = 'Digital signature of the license for integrity verification.';
            AllowInCustomizations = Never;
            Editable = false;
        }
        field(10; Status; Enum "License Status")
        {
            Caption = 'Status';
            ToolTip = 'Current status of the license.';
            InitValue = Active;
        }
        field(11; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Date and time when the license was created.';
            Editable = false;
        }
        field(12; "Created By"; Code[50])
        {
            Caption = 'Created By';
            ToolTip = 'User who created the license.';
            DataClassification = EndUserIdentifiableInformation;
            AllowInCustomizations = Never;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(13; "Last Validated"; DateTime)
        {
            Caption = 'Last Validated';
            ToolTip = 'Date and time when the license was last validated.';
            Editable = false;
        }
        field(14; "Validation Result"; Text[100])
        {
            Caption = 'Last Validation Result';
            ToolTip = 'Result of the last license validation.';
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
    fieldgroups
    {
        fieldgroup(DropDown; "App Name", "Customer Name", "Valid From", "Valid To", Status)
        {
        }
        fieldgroup(Brick; "App Name", "Customer Name", "Valid From", "Valid To")
        {
        }
    }
    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime();
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;

}