namespace ApplicationLicensing.Extensions;

/// <summary>
/// Table Extension Customer (ID 80520).
/// Extends the standard Customer table with Due Amount FlowField functionality.
/// </summary>
tableextension 80520 "Customer Extension" extends Customer
{
    fields
    {
        field(80520; "Due Amount"; Decimal)
        {
            Caption = 'Due Amount';
            ToolTip = 'Specifies the total due amount for the customer based on outstanding ledger entries within the applied date filter.';
            FieldClass = FlowField;
            CalcFormula = sum("Cust. Ledger Entry"."Remaining Amount" where("Customer No." = field("No."),
                                                                            "Due Date" = field("Date Filter"),
                                                                            "Remaining Amount" = filter('<>0')));
            Editable = false;
        }
        field(80521; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            ToolTip = 'Specifies a date filter to calculate due amounts up to a specific date.';
            FieldClass = FlowFilter;
        }
    }
}