# Customer Management Extensions

This folder contains extensions for the standard Business Central Customer functionality.

## Files

### CustomerTableExtension.TableExt.al (ID 80520)
- **Purpose**: Extends the Customer table with Due Amount FlowField functionality
- **Features**:
  - `Due Amount` FlowField: Calculates total outstanding amounts from Customer Ledger Entries
  - `Date Filter` FlowFilter: Enables date range filtering for due amount calculations
- **Technical Details**:
  - Sums `Remaining Amount` from `Cust. Ledger Entry` table
  - Filters by Customer No., Due Date, and non-zero remaining amounts
  - Uses proper currency formatting with AutoFormatType

### CustomerCardExtension.PageExt.al (ID 80520)
- **Purpose**: Extends the Customer Card page to display Due Amount information
- **Features**:
  - Due Amount field displayed after Credit Limit (LCY)
  - Date Filter field for interactive filtering
  - Visual styling (attention style when amount > 0)
  - Drill-down functionality to Customer Ledger Entries
- **User Experience**:
  - Users can set date filters to view due amounts for specific periods
  - Drill-down opens filtered Customer Ledger Entries page
  - Auto-refresh when date filter changes

## Usage Example

1. Open any Customer Card
2. The Due Amount field shows total outstanding amounts
3. Use the Date Filter field to filter by due date (e.g., "..12/31/2024" for amounts due by year-end)
4. Click the Due Amount field to drill down to detailed ledger entries

## ID Range

Uses IDs 80520-80521 within the project's allocated range of 80500-80549.