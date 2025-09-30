namespace ApplicationLicensing.Enums;

/// <summary>
/// Enum Customer License Line Type (ID 80521).
/// Defines the possible types of lines in a customer license document.
/// </summary>
enum 80521 "Customer License Line Type"
{
    Extensible = true;
    Caption = 'Customer License Line Type';

    value(0; "Application")
    {
        Caption = 'Application';
    }
    value(1; "Comment")
    {
        Caption = 'Comment';
    }
}