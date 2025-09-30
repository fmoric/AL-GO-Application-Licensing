namespace ApplicationLicensing.Base.Codeunit;

using ApplicationLicensing.Base.Tables;
using System.Utilities;

codeunit 80501 "License Management Install"
{
    Subtype = Install;
#if not DBG
    [NonDebuggable]
#endif
    trigger OnInstallAppPerCompany()
    var
        AppLicSetup: Record "Application Licensing Setup";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        if not AppLicSetup.Get() then begin
            AppLicSetup.Init();
            AppLicSetup.SetAdminPassword(InitialPassword());
            TempBlob.CreateOutStream(OutStr);
            OutStr.WriteText(InitialPublicKey());
            AppLicSetup.SetPublicKey(TempBlob);
            AppLicSetup.Insert(true);
        end;
    end;
#if not DBG
    [NonDebuggable]
#endif
    local procedure InitialPassword(): Text
    begin
        exit('BEterna2025.!')
    end;

    local procedure InitialPublicKey(): Text
    begin
        exit('<RSAKeyValue><Modulus>0YuZkexPVx+WZuR4Q4GA3kXU77tlYNMeM1Q5z29PDlNgcszCYZFPGhQAicGNNTGz/tn8FGMi8RPi4cgEkJah4kwdevpH1iNplKsNhZ301FjC/7Jn09DlFwnGN1wseQVCZ2NX5jg29yNOGwGDARtfZOevfs6KUAoDSuoUKZT/2ze36Mt2tOB/GupVxrQ9usrSkoKDOPR5P12CTIBYkM6a/ADKvOo1rAxhEz4ZMjh8eICS+i3rfE6OmOUUPsSXZkWxdAYfL0je+qiS1qyfMzv8xPWIdVLzAmX6GbYvdypDqTuQ0j4A9fzA6zZOjvOdL4Zq8jx8Hu7eUrXdYpIM1H3jZw==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>')
    end;
}
