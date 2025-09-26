namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Tables;
using Microsoft.Foundation.NoSeries;

/// <summary>
/// Page Application Licensing Setup (ID 80540).
/// Setup page for configuring Application Licensing extension settings.
/// </summary>
page 80540 "Application Licensing Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Application Licensing Setup";
    Caption = 'Application Licensing Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Permissions = tabledata "Application Licensing Setup" = rimd;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Customer License Nos."; Rec."Customer License Nos.")
                {
                    ShowMandatory = true;
                }
            }
            group("License Defaults")
            {
                Caption = 'License Defaults';
                field("Default License Duration"; Rec."Default License Duration")
                {
                    ShowMandatory = true;
                }
                field("Auto Generate Licenses"; Rec."Auto Generate Licenses")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Application Management")
            {
                Caption = 'Application Management';
                action("Application Registry")
                {

                    Caption = 'Application Registry';
                    Image = Setup;
                    ToolTip = 'Open the application registry to manage applications.';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ApplicationRegistryPage: Page "Application Registry";
                    begin
                        ApplicationRegistryPage.Run();
                    end;
                }
                action("Customer Licenses")
                {

                    Caption = 'Customer Licenses';
                    Image = CustomerLedger;
                    ToolTip = 'Open the customer license list to manage customer licenses.';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CustomerLicenseListPage: Page "Customer License List";
                    begin
                        CustomerLicenseListPage.Run();
                    end;
                }
            }
            group("Crypto Management")
            {
                Caption = 'Crypto Management';
                action("Crypto Key Management")
                {

                    Caption = 'Crypto Key Management';
                    Image = Certificate;
                    ToolTip = 'Manage cryptographic keys for license signing.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CryptoKeyManagementPage: Page "Crypto Key Management";
                    begin
                        CryptoKeyManagementPage.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Ensure the setup record exists
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}