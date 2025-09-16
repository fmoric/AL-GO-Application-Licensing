namespace ApplicationLicensing.Tables;

using System.Security.AccessControl;
using ApplicationLicensing.Pages;
/// <summary>
/// Table Application Registry (ID 80500).
/// Stores registered applications with version control and activation status.
/// </summary>
table 80500 "Application Registry"
{
    DataClassification = SystemMetadata;
    Caption = 'Application Registry';
    LookupPageId = "Application Registry";
    DrillDownPageId = "Application Registry";

    fields
    {
        field(1; "App ID"; Guid)
        {
            Caption = 'Application ID';

            NotBlank = true;
        }
        field(2; "App Name"; Text[100])
        {
            Caption = 'Application Name';

            NotBlank = true;
        }
        field(3; "Publisher"; Text[100])
        {
            Caption = 'Publisher';

            NotBlank = true;
        }
        field(4; "Version"; Text[20])
        {
            Caption = 'Version';

            NotBlank = true;
        }
        field(5; "Description"; Text[250])
        {
            Caption = 'Description';

        }
        field(6; "Active"; Boolean)
        {
            Caption = 'Active';

            InitValue = true;
        }
        field(7; "Created Date"; DateTime)
        {
            Caption = 'Created Date';

            Editable = false;
        }
        field(8; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(9; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';

            Editable = false;
        }
        field(10; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(PK; "App ID")
        {
            Clustered = true;
        }
        key(Name; "App Name")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        "Last Modified Date" := "Created Date";
        "Last Modified By" := "Created By";
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By" := CopyStr(UserId, 1, MaxStrLen("Last Modified By"));
    end;
}