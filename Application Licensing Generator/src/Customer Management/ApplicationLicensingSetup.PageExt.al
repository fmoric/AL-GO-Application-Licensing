namespace ApplicationLicensing.Generator.PageExt;

using ApplicationLicensing.Base.Pages;

pageextension 80525 "Application Licensing Setup" extends "Application Licensing Setup"
{
    layout
    {
        addlast(General)
        {
            field("Customer License Nos."; Rec."Customer License Nos.")
            {
                ApplicationArea = All;
            }
        }
        addafter(General)
        {
            group("License Defaults")
            {
                Caption = 'License Defaults';
                field("Default License Duration"; Rec."Default License Duration")
                {
                    ApplicationArea = All;
                }
                field("Auto Generate Licenses"; Rec."Auto Generate Licenses")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}