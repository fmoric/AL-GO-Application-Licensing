permissionset 80500 "All-ApLicBET"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "Application Manager" = X,
         codeunit "Crypto Key Manager" = X,
         codeunit "License Generator" = X,
         codeunit "License Management" = X,
         page "Application Card" = X,
         page "Application License FactBox" = X,
         page "Application Registry" = X,
         page "Crypto Key Management" = X,
         page "License Generation" = X,
         page "License Import" = X,
         page "License Management Center" = X,
         page "License Registry" = X,
         table "Application Registry" = X,
         table "Crypto Key Storage" = X,
         table "License Registry" = X,
         tabledata "Application Registry" = RIMD,
         tabledata "Crypto Key Storage" = RIMD,
         tabledata "License Registry" = RIMD;
}