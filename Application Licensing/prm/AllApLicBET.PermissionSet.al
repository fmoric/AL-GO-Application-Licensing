permissionset 80500 "All-ApLicBET"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "Application Manager" = X,
         codeunit "Crypto Key Manager" = X,
         codeunit "Customer License Management" = X,
         codeunit "License Generator" = X,
         codeunit "License Management" = X,
         page "Application Card" = X,
         page "Application License FactBox" = X,
         page "Application Licensing Setup" = X,
         page "Application Registry" = X,
         page "Crypto Key Management" = X,
         page "Customer Application Lines" = X,
         page "Customer Application List" = X,
         page "Customer License" = X,
         page "Customer License FactBox" = X,
         page "Customer License List" = X,
         page "License Import" = X,
         page "License Management Center" = X,
         page "License Registry" = X,
         table "Application Licensing Setup" = X,
         table "Application Registry" = X,
         table "Crypto Key Storage" = X,
         table "Customer License Header" = X,
         table "Customer License Line" = X,
         table "License Registry" = X,
         tabledata "Application Licensing Setup" = RIMD,
         tabledata "Application Registry" = RIMD,
         tabledata "Crypto Key Storage" = RIMD,
         tabledata "Customer License Header" = RIMD,
         tabledata "Customer License Line" = RIMD,
         tabledata "License Registry" = RIMD;
}