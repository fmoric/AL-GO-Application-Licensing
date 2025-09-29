permissionset 80525 "BET All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "Crypto Key Manager" = X,
         codeunit "Customer License Management" = X,
         codeunit "License Generator" = X,
         codeunit "License Management" = X,
         page "Customer Application Lines" = X,
         page "Customer Application List" = X,
         page "Customer License" = X,
         page "Customer License FactBox" = X,
         page "Customer License List" = X,
         table "Crypto Key Storage" = X,
         table "Customer License Header" = X,
         table "Customer License Line" = X,
         tabledata "Crypto Key Storage" = RIMD,
         tabledata "Customer License Header" = RIMD,
         tabledata "Customer License Line" = RIMD;
}