namespace ApplicationLicensing.Generator.Tables;

using System.Security.AccessControl;
using ApplicationLicensing.Generator.Pages;
using System.Apps;
/// <summary>
/// Table Application Registry (ID 80500).
/// Master registry of available applications that can be licensed to customers.
/// 
/// This is the core table of the Base Application, providing the foundation
/// for application registration and license validation.
/// </summary>
table 80526 "Application Registry"
{
    DataClassification = SystemMetadata;
    Caption = 'Application Registry';
    LookupPageId = "Application Registry";
    DrillDownPageId = "Application Registry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "App ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Specifies the unique identifier for the application.';
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
        field(3; "App Name"; Text[100])
        {
            Caption = 'Application Name';
            ToolTip = 'Specifies the name of the application.';
            NotBlank = true;
        }
        field(4; Publisher; Text[100])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the application.';
            NotBlank = true;
        }
        field(5; Version; Text[20])
        {
            Caption = 'Version';
            ToolTip = 'Specifies the version of the application.';
            NotBlank = true;
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies an optional description for the application.';
        }
        field(7; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies whether the application is active and available for licensing.';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(UK; "App ID")
        {
        }
        key(Name; "App Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "App Name", Publisher, Version, Active)
        {

        }
        fieldgroup(Brick; "App Name", Publisher, Version, Active)
        {

        }
    }

    /// <summary>
    /// Initializes application fields from the NAV App Installed App table when App ID exists.
    /// </summary>
    local procedure InitializeFromPublishedApplication()
    var
        NavAppInstalledApp: Record "NAV App Installed App";
    begin
        if not NavAppInstalledApp.Get("App ID") then
            exit;

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

    local procedure ClearAppFields()
    begin
        "App Name" := '';
        Publisher := '';
        Version := '';
        Description := '';
    end;
}