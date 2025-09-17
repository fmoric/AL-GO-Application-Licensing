namespace ApplicationLicensing.Tables;

using System.Security.AccessControl;
using ApplicationLicensing.Pages;
using System.Apps;
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
            TableRelation = "NAV App Installed App"."App ID";
            ValidateTableRelation = false;
            NotBlank = true;
            trigger OnValidate()
            begin
                if IsNullGuid("App ID") then begin
                    ClearAppFields();
                    exit;
                end;
                InitializeFromPublishedApplication();
            end;
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

    /// <summary>
    /// Initializes application fields from the NAV App Installed App table when App ID exists.
    /// </summary>
    local procedure InitializeFromPublishedApplication()
    var
        NavAppInstalledApp: Record "NAV App Installed App";
    begin
        if NavAppInstalledApp.Get("App ID") then begin
            if "App Name" = '' then
                "App Name" := CopyStr(NavAppInstalledApp.Name, 1, MaxStrLen("App Name"));
            if Publisher = '' then
                Publisher := CopyStr(NavAppInstalledApp.Publisher, 1, MaxStrLen(Publisher));
            if Version = '' then
                Version := CopyStr(Format(NavAppInstalledApp."Version Major") + '.' +
                                 Format(NavAppInstalledApp."Version Minor") + '.' +
                                 Format(NavAppInstalledApp."Version Build") + '.' +
                                 Format(NavAppInstalledApp."Version Revision"), 1, MaxStrLen(Version));
            if Description = '' then
                Description := CopyStr(NavAppInstalledApp.Name, 1, MaxStrLen(Description));
        end;
    end;

    local procedure ClearAppFields()
    begin
        "App Name" := '';
        Publisher := '';
        Version := '';
        Description := '';
    end;
}