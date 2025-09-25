namespace ApplicationLicensing.Extensions;

/// <summary>
/// Page Extension Customer Card (ID 80520).
/// Extends the standard Customer Card page to display Due Amount information.
/// </summary>
pageextension 80520 "Customer Card Extension" extends "Customer Card"
{
    layout
    {
        addafter("Credit Limit (LCY)")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Specifies the total due amount for the customer based on outstanding ledger entries within the applied date filter.';
                Style = Attention;
                StyleExpr = Rec."Due Amount" > 0;
                
                trigger OnDrillDown()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                begin
                    CustLedgerEntry.SetRange("Customer No.", Rec."No.");
                    if Rec.GetFilter("Date Filter") <> '' then
                        CustLedgerEntry.SetFilter("Due Date", Rec.GetFilter("Date Filter"));
                    CustLedgerEntry.SetFilter("Remaining Amount", '<>%1', 0);
                    Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
                end;
            }
            field("Date Filter"; Rec."Date Filter")
            {
                ApplicationArea = All;
                Caption = 'Due Date Filter';
                ToolTip = 'Specifies a date filter to calculate due amounts up to a specific date.';
                
                trigger OnValidate()
                begin
                    Rec.CalcFields("Due Amount");
                    CurrPage.Update(false);
                end;
            }
        }
    }
}