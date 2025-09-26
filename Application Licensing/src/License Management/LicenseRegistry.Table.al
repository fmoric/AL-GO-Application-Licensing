namespace ApplicationLicensing.Tables;

using ApplicationLicensing.Codeunit;
using System.Security.AccessControl;
using ApplicationLicensing.Pages;
using ApplicationLicensing.Enums;

/// <summary>
/// Table License Registry (ID 80501).
/// Stores generated licenses with metadata and validation information.
/// Links to Customer License Lines following BC standard document pattern.
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
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            ToolTip = 'Document number of the Customer License Header this license belongs to.';
            TableRelation = "Customer License Header"."No.";
            NotBlank = true;
        }
        field(3; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            ToolTip = 'Line number in the Customer License document this license was generated from.';
        }
        field(4; "App ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Unique identifier for the application.';
            AllowInCustomizations = Never;
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
        field(6; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Customer number from the Customer License Header.';
            CalcFormula = lookup("Customer License Header"."Customer No." where("No." = field("Document No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Name of the customer to whom the license is issued.';
            CalcFormula = lookup("Customer License Header"."Customer Name" where("No." = field("Document No.")));
            Editable = false;
            FieldClass = FlowField;
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
            AllowInCustomizations = Never;
            Editable = false;
        }
        field(13; "Key ID"; Code[20])
        {
            Caption = 'Key ID';
            ToolTip = 'Certificate key ID used for signing this license.';
            TableRelation = "Crypto Key Storage"."Key ID";
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
            AllowInCustomizations = Never;
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
        key(Document; "Document No.", "Document Line No.")
        {
        }
        key(AppId; "App ID", "Valid From")
        {
        }
        key(CustomerDoc; "Document No.", "App ID")
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
    /// Links this license registry entry to a Customer License Line.
    /// </summary>
    /// <param name="CustomerLicenseLine">The Customer License Line to link to.</param>
    procedure LinkToCustomerLicenseLine(var CustomerLicenseLine: Record "Customer License Line")
    var
        CustomerLicenseHeader: Record "Customer License Header";
    begin
        "Document No." := CustomerLicenseLine."Document No.";
        "Document Line No." := CustomerLicenseLine."Line No.";
        "App ID" := CustomerLicenseLine."Application ID";

        // Get license dates from the header
        if CustomerLicenseHeader.Get(CustomerLicenseLine."Document No.") then begin
            "Valid From" := CustomerLicenseHeader."License Start Date";
            "Valid To" := CustomerLicenseHeader."License End Date";
        end;

        Features := CustomerLicenseLine."Licensed Features";
        Status := CustomerLicenseLine."License Status";
    end;

    /// <summary>
    /// Updates the linked Customer License Line with license information.
    /// </summary>
    procedure UpdateCustomerLicenseLine()
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        if ("Document No." = '') or ("Document Line No." = 0) then
            exit;

        if CustomerLicenseLine.Get("Document No.", "Document Line No.") then begin
            CustomerLicenseLine."License ID" := "License ID";
            CustomerLicenseLine."License Generated" := true;
            CustomerLicenseLine."License Status" := Status;
            CustomerLicenseLine.Modify(true);
        end;
    end;

    /// <summary>
    /// Gets the Customer License Header for this license.
    /// </summary>
    /// <param name="CustomerLicenseHeader">Output parameter with the header record.</param>
    /// <returns>True if the header was found.</returns>
    procedure GetCustomerLicenseHeader(var CustomerLicenseHeader: Record "Customer License Header"): Boolean
    begin
        if "Document No." = '' then
            exit(false);

        exit(CustomerLicenseHeader.Get("Document No."));
    end;

    /// <summary>
    /// Gets the Customer License Line for this license.
    /// </summary>
    /// <param name="CustomerLicenseLine">Output parameter with the line record.</param>
    /// <returns>True if the line was found.</returns>
    procedure GetCustomerLicenseLine(var CustomerLicenseLine: Record "Customer License Line"): Boolean
    begin
        if ("Document No." = '') or ("Document Line No." = 0) then
            exit(false);

        exit(CustomerLicenseLine.Get("Document No.", "Document Line No."));
    end;

}