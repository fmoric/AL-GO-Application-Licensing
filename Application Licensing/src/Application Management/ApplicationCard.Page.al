namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Tables;

/// <summary>
/// Page Application Card (ID 80501).
/// Card page for creating and editing application registrations.
/// </summary>
page 80501 "Application Card"
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique application identifier.';
                    Editable = IsNewRecord;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                    ShowMandatory = true;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the publisher name.';
                    ShowMandatory = true;
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application version.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an optional description for the application.';
                    MultiLine = true;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the application is active and can have licenses generated.';
                }
            }
            group(Metadata)
            {
                Caption = 'Metadata';
                Editable = false;
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
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the application was last modified.';
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the application.';
                }
            }
        }
        area(FactBoxes)
        {
            part(LicenseInfo; "Application License FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "App ID" = field("App ID");
                Visible = not IsNewRecord;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateLicense)
            {
                ApplicationArea = All;
                Caption = 'Generate License';
                Image = Certificate;
                ToolTip = 'Generate a new license for this application.';
                Enabled = Rec.Active and not IsNewRecord;

                trigger OnAction()
                var
                    LicenseGeneration: Page "License Generation";
                begin
                    if IsNullGuid(Rec."App ID") then begin
                        LicenseGeneration.SetApplicationId(Rec."App ID");
                        LicenseGeneration.RunModal();
                    end;
                end;
            }
            action(ViewLicenses)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
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