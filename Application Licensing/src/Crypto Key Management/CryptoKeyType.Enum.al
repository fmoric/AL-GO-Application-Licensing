namespace ApplicationLicensing.Enums;
/// <summary>
/// Enum Crypto Key Type (ID 80501).
/// Represents the type of cryptographic key.
/// </summary>
enum 80501 "Crypto Key Type"
{
    Extensible = true;
    Caption = 'Cryptographic Key Type';

    value(0; "Signing Key")
    {
        Caption = 'Signing Key';
    }
    value(1; "Validation Key")
    {
        Caption = 'Validation Key';
    }
    value(2; "Master Key")
    {
        Caption = 'Master Key';
    }
    value(3; Certificate)
    {
        Caption = 'Certificate';
    }
}