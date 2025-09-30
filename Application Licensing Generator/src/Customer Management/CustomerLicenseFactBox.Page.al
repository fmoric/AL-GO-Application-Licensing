namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Base.Pages;

/// <summary>
/// Page Customer License FactBox (ID 80514).
/// FactBox showing customer license statistics and summary information.
/// Displays information about a customer's licensed applications and their status.
/// </summary>
page 80533 "Customer License FactBox"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "Customer License Header";
    Caption = 'Customer License Information';

    layout
    {
        area(Content)
        {
            group(CustomerInfo)
            {
                Caption = 'Customer Information';
                field("Customer Name"; Rec."Customer Name")
                {
                    Editable = false;
                    Style = Strong;
                }
                field("Contact Person"; Rec."Contact Person")
                {
                    Editable = false;
                }
                field("Email Address"; Rec."Email Address")
                {
                    Editable = false;
                }
            }
            group(LicenseStats)
            {
                Caption = 'License Statistics';
                field("No. of Applications"; Rec."No. of Applications")
                {
                    Editable = false;
                    Caption = 'Total Applications';
                    Style = Strong;

                    trigger OnDrillDown()
                    begin
                        ShowApplications();
                    end;
                }
                field(ExpiredLicenses; ExpiredLicensesCount)
                {
                    Editable = false;
                    Caption = 'Expired Licenses';
                    ToolTip = 'Specifies the number of expired licenses for this customer.';
                    Style = Attention;

                    trigger OnDrillDown()
                    begin
                        ShowExpiredLicenses();
                    end;
                }
                field(SuspendedLicenses; SuspendedLicensesCount)
                {
                    Editable = false;
                    Caption = 'Suspended Licenses';
                    ToolTip = 'Specifies the number of suspended licenses for this customer.';
                    Style = Subordinate;

                    trigger OnDrillDown()
                    begin
                        ShowSuspendedLicenses();
                    end;
                }
            }
            group(LicenseTimeline)
            {
                Caption = 'License Timeline';
                field("License Start Date"; Rec."License Start Date")
                {
                    Editable = false;
                    Caption = 'Valid From';
                }
                field("License End Date"; Rec."License End Date")
                {
                    Editable = false;
                    Caption = 'Valid To';
                    Style = Attention;
                    StyleExpr = IsNearExpiration;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Released;
                }
            }
            group(RecentActivity)
            {
                Caption = 'Recent Activity';
                field(LastLicenseGenerated; LastLicenseGenerated)
                {
                    Editable = false;
                    Caption = 'Last License Generated';
                    ToolTip = 'Specifies when the last license was generated for this customer.';
                }
                field(LastValidation; LastValidation)
                {
                    Editable = false;
                    Caption = 'Last Validation';
                    ToolTip = 'Specifies when the last license validation was performed.';
                }
                field(RecentApplication; RecentApplicationName)
                {
                    Editable = false;
                    Caption = 'Recent Application';
                    ToolTip = 'Specifies the most recently licensed application for this customer.';

                    trigger OnDrillDown()
                    begin
                        ShowRecentApplication();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenCustomerCard)
            {
                Caption = 'Open Customer';
                Image = Customer;
                ToolTip = 'Open the customer license card.';

                trigger OnAction()
                var
                    CustomerLicenseCard: Page "Customer License";
                begin
                    CustomerLicenseCard.SetRecord(Rec);
                    CustomerLicenseCard.Run();
                end;
            }
            action(ManageApplications)
            {
                Caption = 'Manage Applications';
                Image = ApplicationWorksheet;
                ToolTip = 'Manage applications for this customer.';

                trigger OnAction()
                begin
                    ShowApplications();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateCalculatedFields();
        UpdateVisualCues();
    end;

    /// <summary>
    /// Updates calculated fields and statistics.
    /// </summary>
    local procedure UpdateCalculatedFields()
    var
        CustomerLicenseLine: Record "Customer License Line";
    begin
        // Calculate FlowFields
        Rec.CalcFields("No. of Applications");

        // Calculate expired licenses
        CustomerLicenseLine.SetRange("Document No.", Rec."No.");
        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Expired);
        ExpiredLicensesCount := CustomerLicenseLine.Count();

        // Calculate suspended licenses
        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Suspended);
        SuspendedLicensesCount := CustomerLicenseLine.Count();

        // Find recent activity
        CustomerLicenseLine.SetRange("License Status");
        CustomerLicenseLine.SetFilter("License Generated", '%1', true);
        CustomerLicenseLine.SetCurrentKey("Created Date");
        CustomerLicenseLine.Ascending(false);
        if CustomerLicenseLine.FindFirst() then begin
            LastLicenseGenerated := CustomerLicenseLine."Created Date";
            RecentApplicationName := CustomerLicenseLine."Application Name";
        end;

        // Find last validation
        CustomerLicenseLine.SetRange("License Generated");
        CustomerLicenseLine.SetFilter("Last Validated", '<>%1', 0DT);
        CustomerLicenseLine.SetCurrentKey("Last Validated");
        CustomerLicenseLine.Ascending(false);
        if CustomerLicenseLine.FindFirst() then
            LastValidation := CustomerLicenseLine."Last Validated";
    end;

    /// <summary>
    /// Updates visual cues based on data state.
    /// </summary>
    local procedure UpdateVisualCues()
    begin
        IsNearExpiration := (Rec."License End Date" <> 0D) and
                           (Rec."License End Date" < CalcDate('<+30D>', Today()));
    end;

    /// <summary>
    /// Shows all applications for this customer.
    /// </summary>
    local procedure ShowApplications()
    var
        CustomerApplicationList: Page "Customer Application List";
    begin
        CustomerApplicationList.SetCustomer(Rec."Customer No.", Rec."Customer Name");
        CustomerApplicationList.Run();
    end;


    /// <summary>
    /// Shows expired licenses for this customer.
    /// </summary>
    local procedure ShowExpiredLicenses()
    var
        CustomerLicenseLine: Record "Customer License Line";
        CustomerApplicationList: Page "Customer Application List";
    begin
        CustomerLicenseLine.SetRange("Document No.", Rec."No.");
        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Expired);

        CustomerApplicationList.SetDocument(Rec."No.", Rec."Customer Name");
        CustomerApplicationList.SetTableView(CustomerLicenseLine);
        CustomerApplicationList.Run();
    end;

    /// <summary>
    /// Shows suspended licenses for this customer.
    /// </summary>
    local procedure ShowSuspendedLicenses()
    var
        CustomerLicenseLine: Record "Customer License Line";
        CustomerApplicationList: Page "Customer Application List";
    begin
        CustomerLicenseLine.SetRange("Document No.", Rec."No.");
        CustomerLicenseLine.SetRange("License Status", CustomerLicenseLine."License Status"::Suspended);

        CustomerApplicationList.SetDocument(Rec."No.", Rec."Customer Name");
        CustomerApplicationList.SetTableView(CustomerLicenseLine);
        CustomerApplicationList.Run();
    end;

    /// <summary>
    /// Shows details of the most recent application.
    /// </summary>
    local procedure ShowRecentApplication()
    var
        CustomerLicenseLine: Record "Customer License Line";
        ApplicationRegistry: Record "Application Registry";
        ApplicationCard: Page "Application Card";
    begin
        CustomerLicenseLine.SetRange("Document No.", Rec."No.");
        CustomerLicenseLine.SetCurrentKey("Created Date");
        CustomerLicenseLine.Ascending(false);

        if CustomerLicenseLine.FindFirst() then
            if ApplicationRegistry.Get(CustomerLicenseLine."Application ID") then begin
                ApplicationCard.SetRecord(ApplicationRegistry);
                ApplicationCard.Run();
            end;
    end;

    var
        ExpiredLicensesCount: Integer;
        SuspendedLicensesCount: Integer;
        LastLicenseGenerated: DateTime;
        LastValidation: DateTime;
        RecentApplicationName: Text[100];
        IsNearExpiration: Boolean;
}