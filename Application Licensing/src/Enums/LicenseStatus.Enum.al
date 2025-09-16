/// <summary>
/// Enum License Status (ID 80500).
/// Represents the current status of a license.
/// </summary>
enum 80500 "License Status"
{
    Extensible = true;
    Caption = 'License Status';

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; Expired)
    {
        Caption = 'Expired';
    }
    value(2; Suspended)
    {
        Caption = 'Suspended';
    }
    value(3; Revoked)
    {
        Caption = 'Revoked';
    }
    value(4; Invalid)
    {
        Caption = 'Invalid';
    }
}