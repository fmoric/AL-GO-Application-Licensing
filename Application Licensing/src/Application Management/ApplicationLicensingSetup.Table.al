namespace ApplicationLicensing.Tables;

using Microsoft.Foundation.NoSeries;

/// <summary>
/// Table Application Licensing Setup (ID 80521).
/// Setup table for Application Licensing extension containing number series and configuration.
/// </summary>
table 80521 "Application Licensing Setup"
{
    DataClassification = SystemMetadata;
    Caption = 'Application Licensing Setup';
    DataPerCompany = false;
    Permissions = tabledata "Application Licensing Setup" = rimd,
                  tabledata "No. Series" = r;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key for the setup table.';
            NotBlank = true;
        }
        field(10; "Customer License Nos."; Code[20])
        {
            Caption = 'Customer License Nos.';
            ToolTip = 'Specifies the number series for customer license documents.';
            TableRelation = "No. Series";
        }
        field(20; "Default License Duration"; Integer)
        {
            Caption = 'Default License Duration (Days)';
            ToolTip = 'Specifies the default duration in days for new licenses.';
            MinValue = 1;
            InitValue = 365;
        }
        field(21; "Auto Generate Licenses"; Boolean)
        {
            Caption = 'Auto Generate Licenses';
            ToolTip = 'Specifies whether to automatically generate license files when a document is released.';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the setup record, creating it if it doesn't exist.
    /// </summary>
    /// <returns>The setup record.</returns>
    procedure GetSetup(): Record "Application Licensing Setup"
    var
        ApplicationLicensingSetup: Record "Application Licensing Setup";
    begin
        if not ApplicationLicensingSetup.Get() then begin
            ApplicationLicensingSetup.Init();
            ApplicationLicensingSetup.Insert(true);
        end;
        exit(ApplicationLicensingSetup);
    end;
}