namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Base.Pages;
using ApplicationLicensing.Base.Tables;

/// <summary>
/// Page Application Card (ID 80526).
/// Card page for creating and editing application registrations.
/// </summary>
page 80526 "Application Card"
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
                    Editable = IsNewRecord;
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
                field("Created Date"; Rec."Created Date")
                {

                }
                field("Created By"; Rec."Created By")
                {

                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {

                }
                field("Last Modified By"; Rec."Last Modified By")
                {

                }
            }
        }
        area(FactBoxes)
        {
            part(LicenseInfo; "Application License FactBox")
            {

                SubPageLink = "App ID" = field("App ID");
                Visible = not IsNewRecord;
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
                Enabled = not IsNewRecord;

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
        area(Navigation)
        {
            action(GenerateGuid)
            {

                Caption = 'Generate New GUID';
                Image = New;
                ToolTip = 'Generate a new unique identifier for the application.';
                Enabled = IsNewRecord;

                trigger OnAction()
                begin
                    Rec."App ID" := CreateGuid();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        IsNewRecord: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsNewRecord := true;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsNewRecord := IsNullGuid(Rec."App ID");
    end;

    /// <summary>
    /// Sets the page in new record mode.
    /// </summary>
    procedure SetNewMode()
    begin
        IsNewRecord := true;
    end;
}