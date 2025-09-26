namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;

/// <summary>
/// Page Application Registry (ID 80500).
/// List page for managing application registrations.
/// </summary>
page 80500 "Application Registry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Application Registry";
    Caption = 'Application Registry';
    CardPageId = "Application Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Applications)
            {
                field("App ID"; Rec."App ID")
                {
                    ToolTip = 'Specifies the unique application identifier.';
                }
                field("App Name"; Rec."App Name")
                {

                    ToolTip = 'Specifies the application name.';
                }
                field(Publisher; Rec.Publisher)
                {

                    ToolTip = 'Specifies the publisher name.';
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the application version.';
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies whether the application is active.';
                }
                field("Created Date"; Rec."Created Date")
                {

                    ToolTip = 'Specifies when the application was registered.';
                }
                field("Created By"; Rec."Created By")
                {

                    ToolTip = 'Specifies who registered the application.';
                }
            }
        }
        area(FactBoxes)
        {
            part(LicenseInfo; "Application License FactBox")
            {

                SubPageLink = "App ID" = field("App ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewApplication)
            {

                Caption = 'New Application';
                Image = New;
                ToolTip = 'Register a new application.';

                trigger OnAction()
                var
                    ApplicationCard: Page "Application Card";
                begin
                    ApplicationCard.SetNewMode();
                    ApplicationCard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ViewLicenses)
            {

                Caption = 'View Licenses';
                Image = ViewDetails;
                ToolTip = 'View all licenses for this application.';

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                    LicenseRegistryPage: Page "License Registry";
                begin
                    LicenseRegistry.SetRange("App ID", Rec."App ID");
                    LicenseRegistryPage.SetTableView(LicenseRegistry);
                    LicenseRegistryPage.Run();
                end;
            }
        }

    }
}