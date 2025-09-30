namespace ApplicationLicensing.Tables;

using System.Security.AccessControl;
using ApplicationLicensing.Pages;
using ApplicationLicensing.Enums;

/// <summary>
/// Table Customer License Line (ID 80504).
/// Lines table storing applications assigned to each customer following BC standard header/lines pattern.
/// Contains application-specific license information linked to the Customer License Header.
/// </summary>
table 80504 "Customer License Line"
{
    DataClassification = CustomerContent;
    Caption = 'Customer License Line';
    LookupPageId = "Customer Application List";
    DrillDownPageId = "Customer Application List";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            ToolTip = 'Specifies the document number this line belongs to.';
            TableRelation = "Customer License Header"."No.";
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number within the customer license document.';
            NotBlank = true;
        }
        field(3; Type; Enum "Customer License Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of the line (Application or Comment).';
            InitValue = Application;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    ClearApplicationFields();
                    if Type = Type::Comment then
                        ClearLicenseFields();
                end;
            end;
        }
        field(10; "Application ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Specifies the unique identifier for the application.';
            TableRelation = "Application Registry"."App ID";

            trigger OnValidate()
            var
                ApplicationRegistry: Record "Application Registry";
            begin
                TestField(Type, Type::Application);

                if IsNullGuid("Application ID") then begin
                    ClearApplicationFields();
                    exit;
                end;

                if ApplicationRegistry.Get("Application ID") then begin
                    "Application Name" := ApplicationRegistry."App Name";
                    Publisher := ApplicationRegistry.Publisher;
                    Version := ApplicationRegistry.Version;
                end;
            end;
        }
        field(11; "Application Name"; Text[100])
        {
            Caption = 'Application Name';
            ToolTip = 'Specifies the name of the application.';
            Editable = false;
        }
        field(12; Publisher; Text[100])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the application.';
            Editable = false;
        }
        field(13; Version; Text[20])
        {
            Caption = 'Version';
            ToolTip = 'Specifies the version of the application.';
            Editable = false;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description for this line.';
        }
        field(20; "License ID"; Guid)
        {
            Caption = 'License ID';
            ToolTip = 'Specifies the unique identifier for the generated license.';
            TableRelation = "License Registry"."License ID";
            Editable = false;
        }
        // License dates are now managed at the header level
        field(23; "License Status"; Enum "License Status")
        {
            Caption = 'License Status';
            ToolTip = 'Specifies the status of this application license.';
            InitValue = Active;

            trigger OnValidate()
            begin
                TestField(Type, Type::Application);
            end;
        }
        field(30; "Licensed Features"; Text[250])
        {
            Caption = 'Licensed Features';
            ToolTip = 'Specifies the features enabled by this license.';
        }
        field(31; "License Generated"; Boolean)
        {
            Caption = 'License Generated';
            ToolTip = 'Specifies whether a license file has been generated for this line.';
            Editable = false;
        }
        field(40; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when this license line was created.';
            Editable = false;
        }
        field(41; "Created By"; Code[50])
        {
            Caption = 'Created By';
            ToolTip = 'Specifies who created this license line.';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(42; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            ToolTip = 'Specifies when this license line was last modified.';
            Editable = false;
        }
        field(43; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            ToolTip = 'Specifies who last modified this license line.';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(50; "Last Validated"; DateTime)
        {
            Caption = 'Last Validated';
            ToolTip = 'Specifies when this license was last validated.';
            Editable = false;
        }
        field(51; "Validation Result"; Text[100])
        {
            Caption = 'Last Validation Result';
            ToolTip = 'Specifies the result of the last license validation.';
            Editable = false;
        }
        field(60; Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the quantity for this line (e.g., number of seats).';
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if Type = Type::Application then
                    TestField(Quantity);
            end;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Application; "Application ID")
        {
        }
        key(LicenseId; "License ID")
        {
        }
        key(Status; "License Status")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Type, "Application Name", "License Status")
        {
        }
        fieldgroup(Brick; Type, "Application Name", Publisher, Version, "License Status")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("Document No.");
        TestField("Line No.");
        TestHeaderNotReleased();

        if "Line No." = 0 then
            "Line No." := GetNextLineNo();

        "Created Date" := CurrentDateTime();
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
        "Last Modified Date" := "Created Date";
        "Last Modified By" := "Created By";
    end;

    trigger OnModify()
    begin
        TestHeaderNotReleased();

        "Last Modified Date" := CurrentDateTime();
        "Last Modified By" := CopyStr(UserId(), 1, MaxStrLen("Last Modified By"));
    end;

    trigger OnDelete()
    begin
        TestHeaderNotReleased();

        // Clean up related license registry entry if it exists and is not shared
        if Type = Type::Application then
            CleanupLicenseRegistry();
    end;

    // License dates are managed at header level - no validation needed on lines

    /// <summary>
    /// Clears application fields when Application ID is cleared.
    /// </summary>
    local procedure ClearApplicationFields()
    begin
        Clear("Application ID");
        Clear("Application Name");
        Clear(Publisher);
        Clear(Version);
    end;

    /// <summary>
    /// Clears license-specific fields when changing to comment line.
    /// </summary>
    local procedure ClearLicenseFields()
    begin
        Clear("License ID");
        Clear("License Status");
        Clear("Licensed Features");
        Clear("License Generated");
        Clear(Quantity);
    end;

    /// <summary>
    /// Cleans up the license registry entry if this was the only reference.
    /// </summary>
    local procedure CleanupLicenseRegistry()
    var
        LicenseRegistry: Record "License Registry";
        CustomerLicenseLine: Record "Customer License Line";
    begin
        if IsNullGuid("License ID") then
            exit;

        // Check if any other lines reference this license
        CustomerLicenseLine.SetRange("License ID", "License ID");
        CustomerLicenseLine.SetFilter("Document No.", '<>%1', "Document No.");
        CustomerLicenseLine.SetFilter("Line No.", '<>%1', "Line No.");

        if not CustomerLicenseLine.IsEmpty() then
            exit; // Other lines still reference this license

        // Safe to delete the license registry entry
        if LicenseRegistry.Get("License ID") then
            LicenseRegistry.Delete(true);
    end;

    /// <summary>
    /// Generates a license file for this application line.
    /// </summary>
    procedure GenerateLicense(): Boolean
    var
        CustomerLicenseHeader: Record "Customer License Header";
        LicenseId: Guid;
    begin
        TestField(Type, Type::Application);
        TestField("Application ID");

        if not CustomerLicenseHeader.Get("Document No.") then
            Error(CustomerHeaderNotFoundErr, "Document No.");

        // License dates come from header
        CustomerLicenseHeader.TestField("License Start Date");
        CustomerLicenseHeader.TestField("License End Date");

        // TODO: Implement license generation logic
        LicenseId := CreateGuid();

        if not IsNullGuid(LicenseId) then begin
            "License ID" := LicenseId;
            "License Generated" := true;
            "License Status" := "License Status"::Active;
            Modify(true);
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Validates the license for this application line.
    /// </summary>
    procedure ValidateLicense(): Boolean
    var
        CustomerLicenseHeader: Record "Customer License Header";
        IsValid: Boolean;
    begin
        if IsNullGuid("License ID") then
            exit(false);

        if not CustomerLicenseHeader.Get("Document No.") then
            exit(false);

        // TODO: Implement license validation logic
        IsValid := true;
        "Last Validated" := CurrentDateTime();

        if IsValid then begin
            "Validation Result" := CopyStr(ValidLbl, 1, MaxStrLen("Validation Result"));
            if CustomerLicenseHeader."License End Date" < Today() then
                "License Status" := "License Status"::Expired
            else
                if CustomerLicenseHeader."License Start Date" > Today() then
                    "License Status" := "License Status"::Suspended
                else
                    "License Status" := "License Status"::Active;
        end else begin
            "Validation Result" := CopyStr(InvalidLicenseLbl, 1, MaxStrLen("Validation Result"));
            "License Status" := "License Status"::Suspended;
        end;

        Modify(true);
        exit(IsValid);
    end;

    /// <summary>
    /// Tests that the header is not released to allow modifications.
    /// </summary>
    local procedure TestHeaderNotReleased()
    var
        CustomerLicenseHeader: Record "Customer License Header";
    begin
        if CustomerLicenseHeader.Get("Document No.") then
            if CustomerLicenseHeader.Status = CustomerLicenseHeader.Status::Released then
                Error(HeaderReleasedErr, "Document No.");
    end;

    /// <summary>
    /// Gets the next line number for this document.
    /// </summary>
    local procedure GetNextLineNo(): Integer
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        CustomerLicenseLine.SetRange("Document No.", "Document No.");
        if CustomerLicenseLine.FindLast() then
            exit(CustomerLicenseLine."Line No." + 10000)
        else
            exit(10000);
    end;

    var
        CustomerHeaderNotFoundErr: Label 'Customer header not found for document %1.', Comment = '%1 = Document No.';
        HeaderReleasedErr: Label 'Cannot modify lines for released document %1.', Comment = '%1 = Document No.';
        ValidLbl: Label 'Valid';
        InvalidLicenseLbl: Label 'Invalid License';
}