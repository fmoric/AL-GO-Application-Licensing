namespace ApplicationLicensing.Base.Pages;

using ApplicationLicensing.Base.Tables;



/// <summary>
/// Page Application Licensing Setup (ID 80540).
/// Setup page for configuring Application Licensing extension settings.
/// </summary>
page 80500 "Application Licensing Setup"
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
                field(PublicKeyUploaded; PublicKeyUploaded)
                {
                    Caption = 'Public Key Uploadeded';
                    ToolTip = 'Upload a new public key for license verification.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(AdminPasswordSet; AdminPasswordSet)
                {
                    Caption = 'Admin Password Set';
                    ToolTip = 'Indicates if the admin password has been set.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    //TODO transfer to generator part of application licensing
    // actions
    // {
    //     area(Processing)
    //     {
    //         group("Application Management")
    //         {
    //             Caption = 'Application Management';
    //             action("Application Registry")
    //             {

    //                 Caption = 'Application Registry';
    //                 Image = Setup;
    //                 ToolTip = 'Open the application registry to manage applications.';
    //                 Promoted = true;
    //                 PromotedCategory = Category4;
    //                 PromotedIsBig = true;

    //                 trigger OnAction()
    //                 var
    //                     ApplicationRegistryPage: Page "Application Registry";
    //                 begin
    //                     ApplicationRegistryPage.Run();
    //                 end;
    //             }
    //             action("Customer Licenses")
    //             {

    //                 Caption = 'Customer Licenses';
    //                 Image = CustomerLedger;
    //                 ToolTip = 'Open the customer license list to manage customer licenses.';
    //                 Promoted = true;
    //                 PromotedCategory = Category4;
    //                 PromotedIsBig = true;

    //                 trigger OnAction()
    //                 var
    //                     CustomerLicenseListPage: Page "Customer License List";
    //                 begin
    //                     CustomerLicenseListPage.Run();
    //                 end;
    //             }
    //         }
    //         group("Crypto Management")
    //         {
    //             Caption = 'Crypto Management';
    //             action("Crypto Key Management")
    //             {

    //                 Caption = 'Crypto Key Management';
    //                 Image = Certificate;
    //                 ToolTip = 'Manage cryptographic keys for license signing.';
    //                 Promoted = true;
    //                 PromotedCategory = Process;
    //                 PromotedIsBig = true;

    //                 trigger OnAction()
    //                 var
    //                     CryptoKeyManagementPage: Page "Crypto Key Management";
    //                 begin
    //                     CryptoKeyManagementPage.Run();
    //                 end;
    //             }
    //         }
    //     }
    // }

    actions
    {
        area(Processing)
        {
            group(CryptoManagement)
            {
                Caption = 'Crypto Management';
                action(ImportPublicKey)
                {
                    Caption = 'Import Public Key';
                    Image = Import;
                    ToolTip = 'Import a new public key for license verification.';

                    trigger OnAction()
                    begin
                        Rec.ImportPublicKey();
                        SetValues();
                    end;
                }
                action(SetAdminPassword)
                {
                    Caption = 'Set Admin Password';
                    Image = Administration;
                    ToolTip = 'Set or change the admin password for accessing sensitive operations.';

                    trigger OnAction()
                    begin
                        Rec.SetAdminPassword();
                        SetValues();
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
        SetValues();
    end;

    local procedure SetValues()
    var
#if not DBG
[NonDebuggable]
#endif
        AdminPasswordFake: Text;
    begin
        AdminPasswordSet := Rec.TryGetAdminPassword(AdminPasswordFake);
        Rec.CalcFields("Public Key");
        PublicKeyUploaded := Rec."Public Key".HasValue;
    end;

    var
        PublicKeyUploaded, AdminPasswordSet : Boolean;
}