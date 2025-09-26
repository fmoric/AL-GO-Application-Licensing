namespace ApplicationLicensing.Codeunit;

using ApplicationLicensing.Tables;

/// <summary>
/// Codeunit Customer License Management (ID 80510).
/// Manages customer license operations following BC standard header/lines pattern.
/// Provides functionality for bulk operations on customer licenses and applications.
/// </summary>
codeunit 80510 "Customer License Management"
{
    Permissions = tabledata "Customer License Header" = rimd,
                  tabledata "Customer License Line" = rimd,
                  tabledata "Application Registry" = r,
                  tabledata "License Registry" = rimd;

    /// <summary>
    /// Creates a new customer license header with basic information.
    /// </summary>
    /// <param name="CustomerNo">The unique customer identifier.</param>
    /// <param name="CustomerName">The customer name.</param>
    /// <param name="ContactPerson">Optional contact person.</param>
    /// <param name="EmailAddress">Optional email address.</param>
    /// <returns>True if the customer was created successfully.</returns>
    procedure CreateCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; ContactPerson: Text[100]; EmailAddress: Text[80]): Boolean
    var
        CustomerLicenseHeader: Record "Customer License Header";
    begin
        if CustomerLicenseHeader.Get(CustomerNo) then
            Error(CustomerAlreadyExistsErr, CustomerNo);

        CustomerLicenseHeader.Init();
        CustomerLicenseHeader."Customer No." := CustomerNo;
        CustomerLicenseHeader."Customer Name" := CustomerName;
        CustomerLicenseHeader."Contact Person" := ContactPerson;
        CustomerLicenseHeader."Email Address" := EmailAddress;
        CustomerLicenseHeader.Status := CustomerLicenseHeader.Status::Open;

        exit(CustomerLicenseHeader.Insert(true));
    end;

    /// <summary>
    /// Gets the next line number for a document.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    /// <returns>The next available line number.</returns>
    local procedure GetNextLineNo(DocumentNo: Code[20]): Integer
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        if CustomerLicenseLine.FindLast() then
            exit(CustomerLicenseLine."Line No." + 10000)
        else
            exit(10000);
    end;

    /// <summary>
    /// Adds an application to a customer license document.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    /// <param name="AppId">The application ID.</param>
    /// <param name="ValidFrom">License start date.</param>
    /// <param name="ValidTo">License end date.</param>
    /// <param name="Features">Licensed features.</param>
    /// <returns>True if the application was added successfully.</returns>
    procedure AddApplicationToCustomer(DocumentNo: Code[20]; AppId: Guid; ValidFrom: Date; ValidTo: Date; Features: Text[250]): Boolean
    var
        CustomerLicenseHeader: Record "Customer License Header";
        CustomerLicenseLine: Record "Customer License Line";
        ApplicationRegistry: Record "Application Registry";
    begin
        if not CustomerLicenseHeader.Get(DocumentNo) then
            Error(CustomerNotFoundErr, DocumentNo);

        if not ApplicationRegistry.Get(AppId) then
            Error(ApplicationNotFoundErr, AppId);

        // Check if application is already assigned to this document
        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        CustomerLicenseLine.SetRange("Application ID", AppId);
        if not CustomerLicenseLine.IsEmpty() then
            Error(ApplicationAlreadyAssignedErr, ApplicationRegistry."App Name", DocumentNo);

        CustomerLicenseLine.Init();
        CustomerLicenseLine."Document No." := DocumentNo;
        CustomerLicenseLine."Line No." := GetNextLineNo(DocumentNo);
        CustomerLicenseLine.Validate("Application ID", AppId);
        CustomerLicenseLine."License Start Date" := ValidFrom;
        CustomerLicenseLine."License End Date" := ValidTo;
        CustomerLicenseLine."Licensed Features" := Features;

        exit(CustomerLicenseLine.Insert(true));
    end;

    /// <summary>
    /// Generates license files for all applications in a customer license document.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    procedure GenerateAllCustomerLicenses(DocumentNo: Code[20])
    var
        CustomerLicenseLine: Record "Customer License Line";
        GeneratedCount: Integer;
        FailedCount: Integer;
    begin
        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        CustomerLicenseLine.SetRange("License Generated", false);

        if not CustomerLicenseLine.FindSet() then begin
            Message(NoLicensesToGenerateMsg, DocumentNo);
            exit;
        end;

        repeat
            if CustomerLicenseLine.GenerateLicense() then
                GeneratedCount += 1
            else
                FailedCount += 1;
        until CustomerLicenseLine.Next() = 0;

        if FailedCount = 0 then
            Message(AllLicensesGeneratedMsg, GeneratedCount, DocumentNo)
        else
            Message(SomeLicensesFailedMsg, GeneratedCount, FailedCount, DocumentNo);
    end;

    /// <summary>
    /// Validates all licenses for a customer license document.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    procedure ValidateAllCustomerLicenses(DocumentNo: Code[20])
    var
        CustomerLicenseLine: Record "Customer License Line";
        ValidCount: Integer;
        InvalidCount: Integer;
    begin
        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        CustomerLicenseLine.SetFilter("License ID", '<>%1', BlankGuid);

        if not CustomerLicenseLine.FindSet() then begin
            Message(NoLicensesToValidateMsg, DocumentNo);
            exit;
        end;

        repeat
            if CustomerLicenseLine.ValidateLicense() then
                ValidCount += 1
            else
                InvalidCount += 1;
        until CustomerLicenseLine.Next() = 0;

        if InvalidCount = 0 then
            Message(AllLicensesValidMsg, ValidCount, DocumentNo)
        else
            Message(SomeLicensesInvalidMsg, ValidCount, InvalidCount, DocumentNo);
    end;

    /// <summary>
    /// Migrates existing license registry entries to the new customer structure.
    /// This procedure helps transition from the old single-table structure to the header/lines pattern.
    /// </summary>
    procedure MigrateExistingLicenses()
    var
        LicenseRegistry: Record "License Registry";
        CustomerLicenseHeader: Record "Customer License Header";
        CustomerLicenseLine: Record "Customer License Line";
        CustomerNo: Code[20];
        LineNo: Integer;
        MigratedCount: Integer;
    begin
        LicenseRegistry.SetCurrentKey("Customer Name");
        if not LicenseRegistry.FindSet() then begin
            Message(NoLicensesToMigrateMsg);
            exit;
        end;

        repeat
            // Generate customer number from customer name (first 20 chars, replace spaces with dashes)
            CustomerNo := CopyStr(LicenseRegistry."Customer Name".Replace(' ', '-').ToUpper(), 1, 20);

            // Create customer header if it doesn't exist
            if not CustomerLicenseHeader.Get(CustomerNo) then begin
                CustomerLicenseHeader.Init();
                CustomerLicenseHeader."Customer No." := CustomerNo;
                CustomerLicenseHeader."Customer Name" := LicenseRegistry."Customer Name";
                CustomerLicenseHeader.Insert(true);
                LineNo := 0;
            end;

            // Create customer line
            LineNo += 10000;
            CustomerLicenseLine.Init();
            CustomerLicenseLine."Document No." := CustomerNo;
            CustomerLicenseLine."Line No." := LineNo;
            CustomerLicenseLine.Validate("Application ID", LicenseRegistry."App ID");
            CustomerLicenseLine."License ID" := LicenseRegistry."License ID";
            CustomerLicenseLine."License Start Date" := LicenseRegistry."Valid From";
            CustomerLicenseLine."License End Date" := LicenseRegistry."Valid To";
            CustomerLicenseLine."Licensed Features" := LicenseRegistry.Features;
            CustomerLicenseLine."License Status" := LicenseRegistry.Status;
            CustomerLicenseLine."License Generated" := true;
            CustomerLicenseLine."Last Validated" := LicenseRegistry."Last Validated";
            CustomerLicenseLine."Validation Result" := LicenseRegistry."Validation Result";
            CustomerLicenseLine.Insert(true);

            MigratedCount += 1;
        until LicenseRegistry.Next() = 0;

        // Update all customer headers with timeline information
        CustomerLicenseHeader.Reset();
        if CustomerLicenseHeader.FindSet() then
            repeat
                CustomerLicenseHeader.UpdateLicenseTimeline();
                CustomerLicenseHeader.Modify(true);
            until CustomerLicenseHeader.Next() = 0;

        Message(MigrationCompletedMsg, MigratedCount);
    end;

    /// <summary>
    /// Removes an application from a customer license document.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    /// <param name="AppId">The application ID to remove.</param>
    /// <returns>True if the application was removed successfully.</returns>
    procedure RemoveApplicationFromCustomer(DocumentNo: Code[20]; AppId: Guid): Boolean
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        CustomerLicenseLine.SetRange("Application ID", AppId);

        if not CustomerLicenseLine.FindFirst() then
            Error(ApplicationNotAssignedErr, AppId, DocumentNo);

        exit(CustomerLicenseLine.Delete(true));
    end;

    /// <summary>
    /// Gets customer license document statistics.
    /// </summary>
    /// <param name="DocumentNo">The document number.</param>
    /// <returns>Text with document statistics.</returns>
    procedure GetCustomerStatistics(DocumentNo: Code[20]): Text
    var
        CustomerLicenseHeader: Record "Customer License Header";
        CustomerLicenseLine: Record "Customer License Line";
        TotalApps: Integer;
        ActiveLicenses: Integer;
        ExpiredLicenses: Integer;
        StatText: Text;
    begin
        if not CustomerLicenseHeader.Get(DocumentNo) then
            Error(CustomerNotFoundErr, DocumentNo);

        CustomerLicenseLine.SetRange("Document No.", DocumentNo);
        TotalApps := CustomerLicenseLine.Count();

        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Active);
        ActiveLicenses := CustomerLicenseLine.Count();

        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Expired);
        ExpiredLicenses := CustomerLicenseLine.Count();

        StatText := StrSubstNo(CustomerStatsLbl,
            CustomerLicenseHeader."Customer Name",
            TotalApps,
            ActiveLicenses,
            ExpiredLicenses,
            CustomerLicenseHeader."License Start Date",
            CustomerLicenseHeader."License End Date",
            CustomerLicenseHeader.Status);

        exit(StatText);
    end;

    var
        BlankGuid: Guid;

        // Error messages
        CustomerAlreadyExistsErr: Label 'Customer %1 already exists.', Comment = '%1 = Customer number';
        CustomerNotFoundErr: Label 'Document %1 not found.', Comment = '%1 = Document number';
        ApplicationNotFoundErr: Label 'Application %1 not found in registry.', Comment = '%1 = Application ID';
        ApplicationAlreadyAssignedErr: Label 'Application %1 is already assigned to document %2.', Comment = '%1 = Application name, %2 = Document number';
        ApplicationNotAssignedErr: Label 'Application %1 is not assigned to document %2.', Comment = '%1 = Application ID, %2 = Document number';

        // Information messages
        NoLicensesToGenerateMsg: Label 'No licenses to generate for document %1.', Comment = '%1 = Document number';
        AllLicensesGeneratedMsg: Label 'Successfully generated %1 licenses for document %2.', Comment = '%1 = Number of licenses, %2 = Document number';
        SomeLicensesFailedMsg: Label 'Generated %1 licenses successfully, %2 failed for document %3.', Comment = '%1 = Success count, %2 = Failed count, %3 = Document number';
        NoLicensesToValidateMsg: Label 'No licenses to validate for document %1.', Comment = '%1 = Document number';
        AllLicensesValidMsg: Label 'Successfully validated %1 licenses for document %2.', Comment = '%1 = Number of licenses, %2 = Document number';
        SomeLicensesInvalidMsg: Label 'Validated %1 licenses successfully, %2 invalid for document %3.', Comment = '%1 = Valid count, %2 = Invalid count, %3 = Document number';
        NoLicensesToMigrateMsg: Label 'No existing licenses found to migrate.';
        MigrationCompletedMsg: Label 'Migration completed. %1 license records have been migrated to the new customer structure.', Comment = '%1 = Number of migrated records';
        CustomerStatsLbl: Label 'Customer: %1\\Total Applications: %2\\Active Licenses: %3\\Expired Licenses: %4\\License Period: %5 - %6\\Status: %7', Comment = '%1 = Customer name, %2 = Total apps, %3 = Active licenses, %4 = Expired licenses, %5 = Valid from, %6 = Valid to, %7 = Status';
}