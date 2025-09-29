namespace ApplicationLicensing.Base.Permissions;

using ApplicationLicensing.Base.Tables;
using ApplicationLicensing.Base.Pages;
using ApplicationLicensing.Base.Codeunit;

/// <summary>
/// Permission Set for Application Licensing Base (ID 80500).
/// Provides access to base application licensing functionality for customers.
/// </summary>
permissionset 80500 "AP LIC BASE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Application Licensing Base', MaxLength = 30;

    // Tables
    Permissions =
        tabledata "Application Registry" = R,
        tabledata "License Registry" = RIMD,
        // Pages
        page "Application Registry" = X,
        page "License Registry" = X,
        page "License Import" = X,
        // Codeunits
        codeunit "Application Manager" = X,
        codeunit "License Validator" = X;
}