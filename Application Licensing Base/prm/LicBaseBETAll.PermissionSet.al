permissionset 80500 "LicBaseBET All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "License Validator" = X,
         page "License Import" = X,
         page "License Registry" = X,
         table "License Registry" = X,
         tabledata "License Registry" = RIMD;
}