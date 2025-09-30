namespace ApplicationLicensing.Generator.Pages;

using ApplicationLicensing.Generator.Tables;
using ApplicationLicensing.Generator.Codeunit;

/// <summary>
/// Page Customer License Card (ID 80511).
/// Card page for creating and editing customer license headers.
/// Includes subpage for managing application lines.
/// </summary>
page 80532 "Customer License"
{
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "Customer License Header";
    Caption = 'Customer License';
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';
                field("No."; Rec."No.")
                {
                    Editable = IsNewRecord;
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ShowMandatory = true;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ShowMandatory = true;
                }
                field("Contact Person"; Rec."Contact Person")
                {
                }
                field("Email Address"; Rec."Email Address")
                {
                }
                field("Phone No."; Rec."Phone No.")
                {
                }
            }
            part(ApplicationLines; "Customer Application Lines")
            {
                Caption = 'Licensed Applications';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(AddressInfo)
            {
                Caption = 'Address Information';
                field(AddressField; Rec."Address")
                {
                }
                field("Address 2"; Rec."Address 2")
                {
                }
                field(City; Rec."City")
                {
                }
                field("Post Code"; Rec."Post Code")
                {
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                }
            }
            group(License)
            {
                Caption = 'License Information';
                field("License Start Date"; Rec."License Start Date")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the start date for all licenses in this document.';
                }
                field("License End Date"; Rec."License End Date")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the end date for all licenses in this document.';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Released;
                }
                field("No. of Applications"; Rec."No. of Applications")
                {
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowApplicationLines();
                    end;
                }
            }
            group(NotesInfo)
            {
                Caption = 'Additional Information';
                field(Description; Rec.Description)
                {
                    MultiLine = true;
                }
            }
            group(Metadata)
            {
                Caption = 'Record Information';
                field("Created Date"; Rec.SystemCreatedAt)
                {
                    Editable = false;
                }
                field("Created By"; Rec.SystemCreatedBy)
                {
                    Editable = false;
                }
                field("Last Modified Date"; Rec.SystemModifiedAt)
                {
                    Editable = false;
                }
                field("Last Modified By"; Rec.SystemModifiedBy)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddApplication)
            {
                Caption = 'Add Application';
                Image = New;
                ToolTip = 'Add a new application to this customer license.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    AddNewApplicationLine();
                end;
            }
            action(GenerateAllLicenses)
            {
                Caption = 'Generate All Licenses';
                Image = CreateDocument;
                ToolTip = 'Generate license files for all applications.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    CustomerLicenseManagement: Codeunit "Customer License Management";
                begin
                    CustomerLicenseManagement.GenerateAllCustomerLicenses(Rec."No.");
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
                ToolTip = 'Show available applications that can be licensed.';

                trigger OnAction()
                var
                    ApplicationRegistry: Page "Application Registry";
                begin
                    ApplicationRegistry.Run();
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsNewRecord := true;
    end;

    trigger OnAfterGetRecord()
    begin
        IsNewRecord := false;
        Rec.CalcFields("No. of Applications");
    end;

    /// <summary>
    /// Sets the page in new record mode.
    /// </summary>
    procedure SetNewMode()
    begin
        IsNewRecord := true;
    end;

    /// <summary>
    /// Shows the application lines for this document.
    /// </summary>
    local procedure ShowApplicationLines()
    var
        CustomerApplicationList: Page "Customer Application List";
    begin
        CustomerApplicationList.SetDocument(Rec."No.", Rec."Customer Name");
        CustomerApplicationList.RunModal();
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Adds a new application line to this document.
    /// </summary>
    local procedure AddNewApplicationLine()
    var
        CustomerLicenseLine: Record "Customer License Line";
        ApplicationRegistry: Record "Application Registry";
        ApplicationList: Page "Application Registry";
        NextLineNo: Integer;
    begin
        ApplicationList.LookupMode(true);
        if ApplicationList.RunModal() = Action::LookupOK then begin
            ApplicationList.SetSelectionFilter(ApplicationRegistry);
            if ApplicationRegistry.FindSet() then
                repeat

                    CustomerLicenseLine.SetRange("Document No.", Rec."No.");
                    if CustomerLicenseLine.FindLast() then
                        NextLineNo := CustomerLicenseLine."Line No." + 10000
                    else
                        NextLineNo := 10000;

                    CustomerLicenseLine.Init();
                    CustomerLicenseLine."Document No." := Rec."No.";
                    CustomerLicenseLine."Line No." := NextLineNo;
                    CustomerLicenseLine.Type := CustomerLicenseLine.Type::Application;
                    CustomerLicenseLine.Validate("Application ID", ApplicationRegistry."App ID");
                    // License dates are managed at the header level
                    CustomerLicenseLine.Insert(true);
                until ApplicationRegistry.Next() = 0;
            CurrPage.Update(false);
        end;
    end;

    var
        IsNewRecord: Boolean;
}