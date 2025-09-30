namespace ApplicationLicensing.Generator.Enums;
/// <summary>
/// Enum Crypto Key Type (ID 80501).
/// Represents the type of cryptographic key.
/// </summary>
enum 80525 "Crypto Key Type"
{
    Extensible = true;
    Caption = 'Cryptographic Key Type';

    value(0; "")
    {
        Caption = '', Locked = true;
    }
    value(1; "Signing Key")
    {
        Caption = 'Signing Key';
    }
    value(2; "Validation Key")
    {
        Caption = 'Validation Key';
    }
    value(3; "Master Key")
    {
        Caption = 'Master Key';
    }
    value(4; "Certificate")
    {
        Caption = 'Certificate';
    }
}