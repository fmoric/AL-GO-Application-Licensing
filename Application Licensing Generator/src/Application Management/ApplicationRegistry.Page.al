namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Base.Pages;

/// <summary>
/// Page Application Registry (ID 80500).
/// List page for managing registered applications.
/// </summary>
page 80528 "Application Registry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Application Registry";
    Caption = 'Application Registry';
    Editable = false;
    CardPageId = "Application Card";

    layout
    {
        area(Content)
        {
            repeater(Applications)
            {
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                }
                field("App ID"; Rec."App ID")
                {
                    ApplicationArea = All;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewLicenses)
            {
                ApplicationArea = All;
                Caption = 'View Licenses';
                Image = Certificate;
                ToolTip = 'View licenses for this application.';

                trigger OnAction()
                var
                    LicenseRegistry: Record "License Registry";
                begin
                    LicenseRegistry.SetRange("App ID", Rec."App ID");
                    Page.Run(Page::"License Registry", LicenseRegistry);
                end;
            }
        }
        area(Navigation)
        {
            action(LicenseRegistry)
            {
                ApplicationArea = All;
                Caption = 'License Registry';
                Image = Certificate;
                ToolTip = 'Open the License Registry to view all licenses.';
                RunObject = page "License Registry";
            }
        }
    }
}