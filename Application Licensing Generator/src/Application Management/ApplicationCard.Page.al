namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Base.Pages;

/// <summary>
/// Page Application Card (ID 80526).
/// Card page for creating and editing application registrations.
/// </summary>
page 80525 "Application Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Application Registry";
    Caption = 'Application Registration';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';
                field("App ID"; Rec."App ID")
                {
                }
                field("App Name"; Rec."App Name")
                {
                    ShowMandatory = true;
                }
                field(Publisher; Rec.Publisher)
                {
                    ShowMandatory = true;
                }
                field(Version; Rec.Version)
                {
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {

                    MultiLine = true;
                }
                field(Active; Rec.Active)
                {

                }
            }
            group(Metadata)
            {
                Caption = 'Metadata';
                Editable = false;
                field("Created Date"; Rec.SystemCreatedAt)
                {

                }
                field("Created By"; Rec.SystemCreatedBy)
                {

                }
                field("Last Modified Date"; Rec.SystemModifiedAt)
                {

                }
                field("Last Modified By"; Rec.SystemModifiedBy)
                {

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
                    if not IsNullGuid(Rec."App ID") then begin
                        LicenseRegistry.SetRange("App ID", Rec."App ID");
                        LicenseRegistryPage.SetTableView(LicenseRegistry);
                        LicenseRegistryPage.Run();
                    end;
                end;
            }
        }

    }
}