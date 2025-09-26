namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Tables;
using ApplicationLicensing.Codeunit;

/// <summary>
/// Page Customer License List (ID 80505).
/// List page for managing customer licenses following BC standard header/lines pattern.
/// Displays customer license headers with drill-down to application lines.
/// </summary>
page 80510 "Customer License List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Customer License Header";
    Caption = 'Customer Licenses';
    CardPageId = "Customer License";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(CustomerLicenses)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the unique customer identifier.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Contact Person"; Rec."Contact Person")
                {
                    ToolTip = 'Specifies the primary contact person.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ToolTip = 'Specifies the email address for notifications.';
                }
                field("License Start Date"; Rec."License Start Date")
                {
                    ToolTip = 'Specifies the overall start date for licenses.';
                }
                field("License End Date"; Rec."License End Date")
                {
                    ToolTip = 'Specifies the overall end date for licenses.';
                    Style = Attention;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the document status.';
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Released;
                }
                field("No. of Applications"; Rec."No. of Applications")
                {
                    ToolTip = 'Specifies the number of applications licensed.';
                    BlankZero = true;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ToolTip = 'Specifies when the customer was created.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CustomerApplications; "Customer License FactBox")
            {
                SubPageLink = "Customer No." = field("Customer No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewCustomer)
            {
                Caption = 'New Customer License';
                Image = New;
                ToolTip = 'Create a new customer license record.';

                trigger OnAction()
                var
                    CustomerLicenseCard: Page "Customer License";
                begin
                    CustomerLicenseCard.SetNewMode();
                    CustomerLicenseCard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ManageApplications)
            {
                Caption = 'Manage Applications';
                Image = ApplicationWorksheet;
                ToolTip = 'Manage applications for the selected document.';
                Enabled = Rec."No." <> '';

                trigger OnAction()
                var
                    CustomerApplications: Page "Customer Application List";
                begin
                    CustomerApplications.SetDocument(Rec."No.", Rec."Customer Name");
                    CustomerApplications.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(GenerateAllLicenses)
            {
                Caption = 'Generate All Licenses';
                Image = CreateDocument;
                ToolTip = 'Generate license files for all applications in the selected document.';
                Enabled = Rec."No." <> '';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.GenerateAllCustomerLicenses(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            action(ValidateAllLicenses)
            {
                Caption = 'Validate All Licenses';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Validate all licenses in the selected document.';
                Enabled = Rec."No." <> '';

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.ValidateAllCustomerLicenses(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ShowApplicationRegistry)
            {
                Caption = 'Application Registry';
                Image = ShowList;
                ToolTip = 'Show the application registry to manage available applications.';

                trigger OnAction()
                var
                    ApplicationRegistry: Page "Application Registry";
                begin
                    ApplicationRegistry.Run();
                end;
            }
            action(ShowLicenseRegistry)
            {
                Caption = 'License Registry';
                Image = Certificate;
                ToolTip = 'Show the license registry with all generated licenses.';

                trigger OnAction()
                var
                    LicenseRegistry: Page "License Registry";
                begin
                    LicenseRegistry.Run();
                end;
            }
        }
        area(Reporting)
        {
            action(PrintCustomerLicenses)
            {
                Caption = 'Print Customer Licenses';
                Image = Print;
                ToolTip = 'Print a report of customer licenses.';

                trigger OnAction()
                begin
                    // TODO: Implement customer license report
                    Message('Customer license reporting will be implemented in future updates.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Calculate FlowFields for display
        Rec.CalcFields("No. of Applications");
    end;
}