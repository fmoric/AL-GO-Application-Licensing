namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;

/// <summary>
/// Page Customer Application Lines (ID 80535).
/// Subpage for managing application lines within a customer license.
/// Used in the Customer License Card to display and edit licensed applications.
/// </summary>
page 80530 "Customer Application Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Customer License Line";
    Caption = 'Licensed Applications';
    Permissions = tabledata "Customer License Header" = rimd,
                  tabledata "Application Registry" = rimd;
    layout
    {
        area(Content)
        {
            repeater(ApplicationLines)
            {
                field("Application Name"; Rec."Application Name")
                {
                    ToolTip = 'Specifies the application name.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ShowApplicationDetails();
                    end;
                }
                field(Publisher; Rec.Publisher)
                {
                    ToolTip = 'Specifies the application publisher.';
                    Editable = false;
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the application version.';
                    Editable = false;
                }
                field("License Status"; Rec."License Status")
                {
                    ToolTip = 'Specifies the license status.';
                    Style = Favorable;
                    StyleExpr = Rec."License Status" = Rec."License Status"::Active;
                }
                field("Licensed Features"; Rec."Licensed Features")
                {
                    ToolTip = 'Specifies the licensed features.';
                }
                field("License Generated"; Rec."License Generated")
                {
                    ToolTip = 'Specifies whether a license file has been generated.';
                    Editable = false;
                }
                field("Last Validated"; Rec."Last Validated")
                {
                    ToolTip = 'Specifies when the license was last validated.';
                    Editable = false;
                }
                field("Validation Result"; Rec."Validation Result")
                {
                    ToolTip = 'Specifies the last validation result.';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = IsValidationFailed;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateVisualCues();
    end;


    /// <summary>
    /// Shows detailed information about the selected application.
    /// </summary>
    local procedure ShowApplicationDetails()
    var
        ApplicationRegistry: Record "Application Registry";
        ApplicationCard: Page "Application Card";
    begin
        ApplicationRegistry.SetRange("App ID", Rec."Application ID");
        if ApplicationRegistry.FindFirst() then begin
            ApplicationCard.SetRecord(ApplicationRegistry);
            ApplicationCard.Run();
        end;
    end;

    /// <summary>
    /// Updates visual cues based on record state.
    /// </summary>
    local procedure UpdateVisualCues()
    begin
        // License expiration is checked at header level
        IsValidationFailed := (Rec."Validation Result" <> '') and (Rec."Validation Result" <> 'Valid');
    end;

    var
        IsValidationFailed: Boolean;

}