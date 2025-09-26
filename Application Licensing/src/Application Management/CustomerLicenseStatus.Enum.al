namespace ApplicationLicensing.Enums;

/// <summary>
/// Enum Customer License Status (ID 80520).
/// Defines the possible states of a customer license document following BC standard document pattern.
/// Flow: Open → Released → Expired/Archived
/// </summary>
enum 80520 "Customer License Status"
{
    Extensible = true;
    Caption = 'Customer License Status';

    value(0; "Open")
    {
        Caption = 'Open';
    }
    value(1; "Released")
    {
        Caption = 'Released';
    }
    value(2; "Expired")
    {
        Caption = 'Expired';
    }
    value(3; "Archived")
    {
        Caption = 'Archived';
    }
}