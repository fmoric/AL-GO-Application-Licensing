namespace ApplicationLicensing.Generator.TableExt;

using ApplicationLicensing.Base.Tables;
using Microsoft.Foundation.NoSeries;

tableextension 80525 "Application Licensing Setup" extends "Application Licensing Setup"
{
    fields
    {
        field(80525; "Customer License Nos."; Code[20])
        {
            Caption = 'Customer License Nos.';
            ToolTip = 'Specifies the number series for customer license documents.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(80526; "Default License Duration"; Integer)
        {
            Caption = 'Default License Duration (Days)';
            ToolTip = 'Specifies the default duration in days for new licenses.';
            DataClassification = CustomerContent;
            MinValue = 1;
            InitValue = 365;
        }
        field(80527; "Auto Generate Licenses"; Boolean)
        {
            Caption = 'Auto Generate Licenses';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether to automatically generate license files when a document is released.';
            InitValue = true;
        }
    }
}
