namespace ApplicationLicensing.Base.Tables;

using System.Security.AccessControl;
using ApplicationLicensing.Base.Pages;
using ApplicationLicensing.Base.Enums;

/// <summary>
/// Table License Registry (ID 80501).
/// Stores imported and validated licenses with metadata and validation information.
/// 
/// This is a core table in the Base Application that serves as the central repository
/// for all license records, whether imported from external sources or created by
/// the Generator Application.
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
        field(4; "App ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Unique identifier for the application.';
            TableRelation = "Application Registry"."App ID";
            NotBlank = true;
        }
        field(5; "App Name"; Text[100])
        {
            Caption = 'Application Name';
            ToolTip = 'Name of the registered application.';
            CalcFormula = lookup("Application Registry"."App Name" where("App ID" = field("App ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Name of the customer to whom the license is issued.';
        }
        field(8; "Valid From"; Date)
        {
            Caption = 'Valid From';
            ToolTip = 'Start date of the license validity period.';
            NotBlank = true;
        }
        field(9; "Valid To"; Date)
        {
            Caption = 'Valid To';
            ToolTip = 'End date of the license validity period.';
            NotBlank = true;
        }
        field(10; Features; Text[250])
        {
            Caption = 'Licensed Features';
            ToolTip = 'Features enabled by this license.';
        }
        field(11; "License File"; Blob)
        {
            Caption = 'License File';
            ToolTip = 'The actual license file content.';
        }
        field(12; "Digital Signature"; Text[1024])
        {
            Caption = 'Digital Signature';
            ToolTip = 'Digital signature of the license for integrity verification.';
            Editable = false;
        }
        field(13; "Key ID"; Code[20])
        {
            Caption = 'Key ID';
            ToolTip = 'Certificate key ID used for signing this license.';
            Editable = false;
        }
        field(20; Status; Enum "License Status")
        {
            Caption = 'Status';
            ToolTip = 'Current status of the license.';
            InitValue = Active;
        }
        field(21; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Date and time when the license was created.';
            Editable = false;
        }
        field(22; "Created By"; Code[50])
        {
            Caption = 'Created By';
            ToolTip = 'User who created the license.';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(23; "Last Validated"; DateTime)
        {
            Caption = 'Last Validated';
            ToolTip = 'Date and time when the license was last validated.';
            Editable = false;
        }
        field(24; "Validation Result"; Text[100])
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
        key(Status; Status, "Valid To")
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

    /// <summary>
    /// Validates the license content and dates.
    /// </summary>
    /// <returns>True if the license is valid.</returns>
    procedure ValidateLicense(): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        // Check if application exists and is active
        if not ApplicationRegistry.Get("App ID") then
            exit(false);

        if not ApplicationRegistry.Active then
            exit(false);

        // Check date validity
        if ("Valid From" > Today()) or ("Valid To" < Today()) then begin
            Status := Status::Expired;
            exit(false);
        end;

        // Basic validation without signature checking
        // Signature validation would be handled by License Validator codeunit
        "Last Validated" := CurrentDateTime();
        "Validation Result" := 'Valid';
        Status := Status::Active;
        Modify();

        exit(true);
    end;

    /// <summary>
    /// Checks if the license is currently valid (within date range and active status).
    /// </summary>
    /// <returns>True if the license is currently valid.</returns>
    procedure IsCurrentlyValid(): Boolean
    begin
        exit((Status = Status::Active) and
             ("Valid From" <= Today()) and
             ("Valid To" >= Today()));
    end;
}