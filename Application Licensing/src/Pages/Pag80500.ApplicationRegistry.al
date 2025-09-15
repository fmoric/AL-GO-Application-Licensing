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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique application identifier.';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the publisher name.';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application version.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the application is active.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the application was registered.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who registered the application.';
                }
            }
        }
        area(FactBoxes)
        {
            part(LicenseInfo; "Application License FactBox")
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
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
            action(GenerateLicense)
            {
                ApplicationArea = All;
                Caption = 'Generate License';
                Image = Certificate;
                ToolTip = 'Generate a new license for this application.';
                Enabled = Rec.Active;

                trigger OnAction()
                var
                    LicenseGeneration: Page "License Generation";
                begin
                    LicenseGeneration.SetApplicationId(Rec."App ID");
                    LicenseGeneration.RunModal();
                end;
            }
            action(ViewLicenses)
            {
                ApplicationArea = All;
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
        area(Navigation)
        {
            action(LicenseManagement)
            {
                ApplicationArea = All;
                Caption = 'License Management';
                Image = Setup;
                ToolTip = 'Open license management center.';

                trigger OnAction()
                var
                    LicenseManagementPage: Page "License Management Center";
                begin
                    LicenseManagementPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseManagement: Codeunit "License Management";
    begin
        // Initialize licensing system if needed
        LicenseManagement.InitializeLicensingSystem();
    end;
}