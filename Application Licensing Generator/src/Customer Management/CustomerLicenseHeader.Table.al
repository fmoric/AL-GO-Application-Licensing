namespace ApplicationLicensing.Generator.Tables;

using ApplicationLicensing.Generator.Pages;
using ApplicationLicensing.Generator.Enums;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.NoSeries;
using ApplicationLicensing.Base.Tables;

/// <summary>
/// Table Customer License Header (ID 80525).
/// Document header following BC standard document pattern for customer license management.
/// Contains customer information, license timeline, and document control fields.
/// Status flow: Open → Released → Expired/Archived
/// </summary>
table 80528 "Customer License Header"
{
    DataClassification = CustomerContent;
    Caption = 'Customer License Header';
    LookupPageId = "Customer License List";
    DrillDownPageId = "Customer License List";
    Permissions = tabledata "Customer License Header" = r;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the number of the customer license document.';
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    TestNoSeries();
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            ToolTip = 'Specifies the customer number for this license.';

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Customer No." <> xRec."Customer No." then
                    ClearCustomerFields();

                if not Customer.Get("Customer No.") then
                    Clear(Customer);

                "Customer Name" := Customer.Name;
                "Contact Person" := Customer."Contact";
                "Email Address" := Customer."E-Mail";
                "Phone No." := Customer."Phone No.";
                "Address" := Customer.Address;
                "Address 2" := Customer."Address 2";
                "City" := Customer.City;
                "Post Code" := Customer."Post Code";
                "Country/Region Code" := Customer."Country/Region Code";
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Specifies the name of the customer.';
            Editable = false;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
            ToolTip = 'Specifies the date when the license document was created.';
        }
        field(10; "License Start Date"; Date)
        {
            Caption = 'License Start Date';
            ToolTip = 'Specifies the start date for all licenses in this document.';

            trigger OnValidate()
            begin
                if ("License Start Date" <> 0D) and ("License End Date" <> 0D) then
                    if "License Start Date" > "License End Date" then
                        Error(StartDateAfterEndDateErr);
            end;
        }
        field(11; "License End Date"; Date)
        {
            Caption = 'License End Date';
            ToolTip = 'Specifies the end date for all licenses in this document.';

            trigger OnValidate()
            begin
                if ("License Start Date" <> 0D) and ("License End Date" <> 0D) then
                    if "License Start Date" > "License End Date" then
                        Error(StartDateAfterEndDateErr);
            end;
        }
        field(12; Status; Enum "Customer License Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the license document.';
            InitValue = Open;

            trigger OnValidate()
            begin
                if Status <> xRec.Status then
                    case Status of
                        Status::Released:
                            Release();
                        Status::Open:
                            Reopen();
                    end;
            end;
        }
        field(13; "No. of Applications"; Integer)
        {
            Caption = 'No. of Applications';
            ToolTip = 'Specifies the number of application lines in this document.';
            Editable = false;
            CalcFormula = count("Customer License Line" where("Document No." = field("No."), Type = const(Application)));
            FieldClass = FlowField;
        }
        field(15; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            ToolTip = 'Specifies the number series code for this document.';
            Editable = false;
        }
        field(20; "Contact Person"; Text[100])
        {
            Caption = 'Contact Person';
            ToolTip = 'Specifies the primary contact person for this customer.';
        }
        field(21; "Email Address"; Text[80])
        {
            Caption = 'Email Address';
            ToolTip = 'Specifies the email address for license notifications.';
            ExtendedDatatype = EMail;
        }
        field(22; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ToolTip = 'Specifies the phone number of the customer.';
            ExtendedDatatype = PhoneNo;
        }
        field(30; Address; Text[100])
        {
            Caption = 'Address';
            ToolTip = 'Specifies the customer address.';
        }
        field(31; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            ToolTip = 'Specifies additional address information.';
        }
        field(32; City; Text[30])
        {
            Caption = 'City';
            ToolTip = 'Specifies the customer city.';
        }
        field(33; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            ToolTip = 'Specifies the customer postal code.';
        }
        field(34; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            ToolTip = 'Specifies the customer country/region.';
        }
        field(80; "Released Date"; DateTime)
        {
            Caption = 'Released Date';
            ToolTip = 'Specifies when the license document was released.';
            Editable = false;
        }
        field(81; "Released By"; Code[50])
        {
            Caption = 'Released By';
            ToolTip = 'Specifies who released the license document.';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(90; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description for this license document.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Customer; "Customer No.", "Document Date")
        {
        }

    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Customer Name", "Document Date", Status)
        {
        }
        fieldgroup(Brick; "No.", "Customer Name", "License Start Date", "License End Date", Status)
        {
        }
    }

    trigger OnInsert()
    begin
        InitializeDocument();
    end;

    trigger OnModify()
    begin
        TestStatusOpen();
    end;

    trigger OnDelete()
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        TestStatusOpen();

        // Delete all related lines
        CustomerLicenseLine.SetRange("Document No.", "No.");
        CustomerLicenseLine.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        TestStatusOpen();
    end;

    /// <summary>
    /// Initializes a new license document with default values and number series.
    /// </summary>
    local procedure InitializeDocument()
    var
        CustomerLicHeader2: Record "Customer License Header";
        NoSeries: Codeunit "No. Series";
        FormatTok: Label '<%1D>', Locked = true;
        NoSeriesCode: Code[20];

    begin
        ApplicationLicensingSetup.GetSetup();

        if "No." = '' then begin
            TestNoSeries();
            NoSeriesCode := GetNoSeriesCode();
            "No. Series" := NoSeriesCode;
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series", "Document Date");
            CustomerLicHeader2.ReadIsolation(IsolationLevel::ReadUncommitted);
            CustomerLicHeader2.SetLoadFields("No.");
            while CustomerLicHeader2.Get("No.") do
                "No." := NoSeries.GetNextNo("No. Series", "Document Date");
        end;
        if "Document Date" = 0D then
            "Document Date" := WorkDate();

        "License Start Date" := "Document Date";
        if ApplicationLicensingSetup."Default License Duration" <> 0 then
            "License End Date" := CalcDate(StrSubstNo(FormatTok, ApplicationLicensingSetup."Default License Duration"), "License Start Date");

        Status := Status::Open;
    end;

    /// <summary>
    /// Releases the license document and generates license files.
    /// </summary>
    procedure Release()
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        TestField("Customer No.");
        TestField("License Start Date");
        TestField("License End Date");

        CustomerLicenseLine.SetRange("Document No.", "No.");
        CustomerLicenseLine.SetRange(Type, CustomerLicenseLine.Type::Application);
        if CustomerLicenseLine.IsEmpty() then
            Error(NoApplicationLinesErr);

        Status := Status::Released;
        "Released Date" := CurrentDateTime();
        "Released By" := CopyStr(UserId(), 1, MaxStrLen("Released By"));

        // Generate license files for all application lines
        GenerateAllLicenseFiles();
    end;

    /// <summary>
    /// Reopens a released license document for editing.
    /// </summary>
    procedure Reopen()
    begin
        if Status = Status::Open then
            exit;

        Status := Status::Open;
        "Released Date" := 0DT;
        "Released By" := '';
    end;

    /// <summary>
    /// Tests that the document status is Open for modification.
    /// </summary>
    local procedure TestStatusOpen()
    begin
        if Status <> Status::Open then
            Error(DocumentNotEditableErr, "No.", Status);
    end;

    /// <summary>
    /// Tests number series setup.
    /// </summary>
    procedure TestNoSeries()
    begin
        ApplicationLicensingSetup.GetSetup();
        ApplicationLicensingSetup.TestField("Customer License Nos.");
    end;

    // License dates are managed at header level only

    /// <summary>
    /// Generates license files for all application lines in the document.
    /// </summary>
    local procedure GenerateAllLicenseFiles()
    var
        CustomerLicenseLine: Record "Customer License Line";
        LicenseId: Guid;
    begin
        CustomerLicenseLine.SetRange("Document No.", "No.");
        CustomerLicenseLine.SetRange(Type, CustomerLicenseLine.Type::Application);

        if CustomerLicenseLine.FindSet(true) then
            repeat
                // TODO: Implement license generation logic
                LicenseId := CreateGuid();

                if not IsNullGuid(LicenseId) then begin
                    CustomerLicenseLine."License ID" := LicenseId;
                    CustomerLicenseLine."License Generated" := true;
                    CustomerLicenseLine.Modify();
                end;
            until CustomerLicenseLine.Next() = 0;
    end;

    // License timeline is managed directly on the header

    local procedure ClearCustomerFields()
    begin
        Clear("Customer Name");
        Clear("Contact Person");
        Clear("Email Address");
        Clear("Phone No.");
        Clear("Address");
        Clear("Address 2");
        Clear("City");
        Clear("Post Code");
        Clear("Country/Region Code");
    end;

    procedure GetNoSeriesCode(): Code[20]
    var
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        ApplicationLicensingSetup.GetSetup();
        NoSeriesCode := ApplicationLicensingSetup."Customer License Nos.";

        if NoSeries.IsAutomatic(NoSeriesCode) then
            exit(NoSeriesCode);

        if NoSeries.HasRelatedSeries(NoSeriesCode) then
            if NoSeries.LookupRelatedNoSeries(NoSeriesCode, "No. Series") then
                exit("No. Series");

        exit(NoSeriesCode);
    end;

    procedure AssistEdit(OldCustomerLicHeader: Record "Customer License Header") Result: Boolean
    var
        CustomerLicHeader2: Record "Customer License Header";
        NoSeries: Codeunit "No. Series";
        AlreadyExistsErr: Label 'The Customer License No. %1 already exists.', Comment = '%1 = Customer License No.';
    begin
        CustomerLicHeader.Copy(Rec);
        ApplicationLicensingSetup.GetSetup();
        CustomerLicHeader.TestNoSeries();
        if NoSeries.LookupRelatedNoSeries(CustomerLicHeader.GetNoSeriesCode(), OldCustomerLicHeader."No. Series", CustomerLicHeader."No. Series") then begin
            CustomerLicHeader."No." := NoSeries.GetNextNo(CustomerLicHeader."No. Series");
            if CustomerLicHeader2.Get(CustomerLicHeader."No.") then
                Error(AlreadyExistsErr, CustomerLicHeader."No.");
            Rec := CustomerLicHeader;
            exit(true);
        end;
    end;

    var

        StartDateAfterEndDateErr: Label 'License Start Date cannot be after License End Date.';
        DocumentNotEditableErr: Label 'License document %1 cannot be modified when status is %2.', Comment = '%1 = Document No., %2 = Status';
        NoApplicationLinesErr: Label 'You must add at least one application line before releasing the document.';

    protected var
        CustomerLicHeader: Record "Customer License Header";
        ApplicationLicensingSetup: Record "Application Licensing Setup";

}