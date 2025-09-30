namespace ApplicationLicensing.Base.Enums;

/// <summary>
/// Enum License Status (ID 80500).
/// Represents the current status of a license.
/// </summary>
enum 80500 "License Status"
{
    Extensible = true;
    Caption = 'License Status';
    value(0; "")
    {
        Caption = '', Locked = true;
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Expired)
    {
        Caption = 'Expired';
    }
    value(3; Suspended)
    {
        Caption = 'Suspended';
    }
    value(4; Revoked)
    {
        Caption = 'Revoked';
    }
    value(5; Invalid)
    {
        Caption = 'Invalid';
    }
}