namespace ApplicationLicensing.Base.Tables;

using Microsoft.Foundation.NoSeries;
using System.Security.AccessControl;
using System.Utilities;
using System.IO;

/// <summary>
/// Table Application Licensing Setup (ID 80521).
/// Setup table for Application Licensing extension containing number series and configuration.
/// </summary>
table 80500 "Application Licensing Setup"
{
    DataClassification = SystemMetadata;
    Caption = 'Application Licensing Setup';
    DataPerCompany = false;
    Permissions = tabledata "Application Licensing Setup" = rimd,
                  tabledata "No. Series" = r;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key for the setup table.';
            NotBlank = true;
        }
        field(2; "Admin Password GUID"; Guid)
        {
            Caption = 'Admin Password GUID';
            ToolTip = 'Specifies the GUID for the admin password in the secure storage.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(3; "Public Key"; Blob)
        {
            Caption = 'Public Key';
            ToolTip = 'Specifies the public key used for license verification.';
            AllowInCustomizations = Never;
        }

    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the setup record, creating it if it doesn't exist.
    /// </summary>
    /// <returns>The setup record.</returns>
    procedure GetSetup()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
#if not DBG
[NonDebuggable]
#endif
    internal procedure SetAdminPassword()
    var
        PasswordDlgMtgm: Codeunit "Password Dialog Management";
        OldPassErr: Label 'The old password does not match. Password change aborted.';
        SecretPassword, OldSecretPassword, OldSecretPasswordToCompare : Text;
    begin
        if not TryGetAdminPassword(OldSecretPassword) then
            //TODO change to secret text once secret text comparison is implemented
            //https://github.com/microsoft/BCApps/issues/4653
#pragma warning disable AL0432
            SecretPassword := PasswordDlgMtgm.OpenPasswordDialog()
#pragma warning restore AL0432
        else begin
            OldSecretPasswordToCompare := GetAdminPassword();
#pragma warning disable AL0432 //TODO change to secret text once secret text comparison is implemented
            PasswordDlgMtgm.OpenChangePasswordDialog(OldSecretPassword, SecretPassword);
#pragma warning restore AL0432
            if OldSecretPasswordToCompare <> OldSecretPassword then
                Error(OldPassErr);
        end;
        if SecretPassword = '' then
            exit;
        SetAdminPassword(SecretPassword);
        Rec.Modify();
    end;
#if not DBG
[NonDebuggable]
#endif
    internal procedure SetAdminPassword(SecretPassword: Text)
    var
        PasswordDlgMtgm: Codeunit "Password Dialog Management";
        OldSecretPassword, OldSecretPasswordToCompare : Text;
    begin
        if IsNullGuid(Rec."Admin Password GUID") then
            Rec."Admin Password GUID" := CreateGuid();

        if SecretPassword = '' then
            exit;
        IsolatedStorage.Set(Rec."Admin Password GUID", SecretPassword);
    end;
#if not DBG
[NonDebuggable]
#endif
    [TryFunction]
    internal procedure TryGetAdminPassword(SecretPass: Text)
    begin
        SecretPass := GetAdminPassword();
    end;
#if not DBG
[NonDebuggable]
#endif
    local procedure GetAdminPassword() SecretPass: Text
    var
        AdminPassErr: Label 'Admin password is not set. Please set the admin password first.';
    begin
        if IsNullGuid(Rec."Admin Password GUID") then
            Error(AdminPassErr);

        if not IsolatedStorage.Get(Rec."Admin Password GUID", SecretPass) then
            Error(AdminPassErr);
    end;
#if not DBG
[NonDebuggable]
#endif
    local procedure EnterAdminPassword()
    var
        PasswordDlgMtgm: Codeunit "Password Dialog Management";
        AdminSecret, SecretPassword : Text;
        AdminPassErr: Label 'The entered password is incorrect. Please try again.';
    begin
        AdminSecret := GetAdminPassword();
#pragma warning disable AL0432
        SecretPassword := PasswordDlgMtgm.OpenPasswordDialog(true, true);
#pragma warning restore AL0432
        if SecretPassword <> AdminSecret then
            Error(AdminPassErr);
    end;

    internal procedure ImportPublicKey(): Boolean
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CertExtFilterTxt: Label 'pem', Locked = true;
        CertFileFilterTxt: Label 'Certificate Files (*.pem)|*.pem';
        SelectFileTxt: Label 'Select Public Key File';
        FilePath: Text;
    begin
        EnterAdminPassword();

        FilePath := FileMgt.BLOBImportWithFilter(TempBlob, SelectFileTxt, '', CertFileFilterTxt, CertExtFilterTxt);
        if FilePath = '' then
            exit(false);

        SetPublicKey(TempBlob);
        Rec.Modify();
    end;

    internal procedure SetPublicKey(TempBlob: Codeunit "Temp Blob")
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        TempBlob.CreateInStream(InStr);
        Rec."Public Key".CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;
}