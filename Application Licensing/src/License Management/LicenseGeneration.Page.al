namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;
using System.Reflection;

/// <summary>
/// Page License Generation (ID 80503).
/// Card page for generating new licenses.
/// </summary>
page 80503 "License Generation"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Generate License';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Permissions = tabledata "Application Registry" = rimd,
              tabledata "License Registry" = rimd,
              tabledata "Crypto Key Storage" = r;
    layout
    {
        area(Content)
        {
            group(Application)
            {
                Caption = 'Application Selection';
                field(SelectedAppId; SelectedAppId)
                {

                    Caption = 'Application';
                    ToolTip = 'Specifies the application for which the license is being generated.';
                    TableRelation = "Application Registry"."App ID" where(Active = const(true));
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ApplicationRegistry: Record "Application Registry";
                        ApplicationRegistryPage: Page "Application Registry";
                    begin
                        ApplicationRegistry.SetRange(Active, true);
                        ApplicationRegistryPage.SetTableView(ApplicationRegistry);
                        ApplicationRegistryPage.LookupMode := true;
                        if ApplicationRegistryPage.RunModal() = Action::LookupOK then begin
                            ApplicationRegistryPage.GetRecord(ApplicationRegistry);
                            SelectedAppId := ApplicationRegistry."App ID";
                            SelectedAppName := ApplicationRegistry."App Name";
                            SelectedPublisher := ApplicationRegistry.Publisher;
                            SelectedVersion := ApplicationRegistry.Version;
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ApplicationRegistry: Record "Application Registry";
                    begin
                        if ApplicationRegistry.Get(SelectedAppId) then begin
                            SelectedAppName := ApplicationRegistry."App Name";
                            SelectedPublisher := ApplicationRegistry.Publisher;
                            SelectedVersion := ApplicationRegistry.Version;
                        end else begin
                            Clear(SelectedAppName);
                            Clear(SelectedPublisher);
                            Clear(SelectedVersion);
                        end;
                    end;
                }
                field(SelectedAppName; SelectedAppName)
                {

                    Caption = 'Application Name';
                    ToolTip = 'Specifies the name of the selected application.';
                    Editable = false;
                }
                field(SelectedPublisher; SelectedPublisher)
                {

                    Caption = 'Publisher';
                    ToolTip = 'Specifies the publisher of the selected application.';
                    Editable = false;
                }
                field(SelectedVersion; SelectedVersion)
                {

                    Caption = 'Version';
                    ToolTip = 'Specifies the version of the selected application.';
                    Editable = false;
                }
            }
            group(Customer)
            {
                Caption = 'Customer Information';
                field(CustomerName; CustomerName)
                {

                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer for whom the license is being generated.';
                    ShowMandatory = true;
                }
            }
            group(Validity)
            {
                Caption = 'License Validity';
                field(ValidFrom; ValidFrom)
                {

                    Caption = 'Valid From';
                    ToolTip = 'Specifies the date when the license becomes valid.';
                    ShowMandatory = true;
                }
                field(ValidTo; ValidTo)
                {

                    Caption = 'Valid To';
                    ToolTip = 'Specifies the date when the license expires.';
                    ShowMandatory = true;
                }
            }
            group(Features)
            {
                Caption = 'Licensed Features';
                field(LicensedFeatures; LicensedFeatures)
                {

                    Caption = 'Features';
                    ToolTip = 'Specifies the licensed features for the application.';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateLicense)
            {

                Caption = 'Generate License';
                Image = Certificate;
                ToolTip = 'Generate the license with the specified parameters.';
                InFooterBar = true;

                trigger OnAction()
                var
                    LicenseGenerator: Codeunit "License Generator";
                    GeneratedLicenseId: Guid;
                begin
                    ValidateInput();

                    GeneratedLicenseId := LicenseGenerator.GenerateLicense(
                        SelectedAppId,
                        CustomerName,
                        ValidFrom,
                        ValidTo,
                        LicensedFeatures);

                    if not IsNullGuid(GeneratedLicenseId) then begin
                        Message(LicenseGeneratedSuccessMsg, GeneratedLicenseId);
                        CurrPage.Close();
                    end else
                        Error(FailedGenerateLicenseErr);
                end;
            }
            action(Cancel)
            {

                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Cancel license generation.';
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        SelectedAppId: Guid;
        SelectedAppName: Text[100];
        SelectedPublisher: Text[100];
        SelectedVersion: Text[20];
        CustomerName: Text[100];
        ValidFrom: Date;
        ValidTo: Date;
        LicensedFeatures: Text[250];

    trigger OnOpenPage()
    begin
        ValidFrom := Today();
        ValidTo := CalcDate('<+1Y>', Today());
    end;

    /// <summary>
    /// Sets the application ID for license generation.
    /// </summary>
    /// <param name="AppId">The application identifier.</param>
    procedure SetApplicationId(AppId: Guid)
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        SelectedAppId := AppId;
        if ApplicationRegistry.Get(AppId) then begin
            SelectedAppName := ApplicationRegistry."App Name";
            SelectedPublisher := ApplicationRegistry.Publisher;
            SelectedVersion := ApplicationRegistry.Version;
        end;
    end;

    /// <summary>
    /// Validates the input before generating a license.
    /// </summary>
    //TODO Collect Errors and show in one message
    local procedure ValidateInput()
    begin
        if IsNullGuid(SelectedAppId) then
            Error(PleaseSelectApplicationErr);

        if CustomerName = '' then
            Error(PleaseEnterCustomerNameErr);

        if ValidFrom = 0D then
            Error(PleaseEnterValidStartDateErr);

        if ValidTo = 0D then
            Error(PleaseEnterValidEndDateErr);

        if ValidFrom > ValidTo then
            Error(StartDateBeforeEndDateErr);

        if ValidTo < Today() then
            Error(EndDateCannotBePastErr);
    end;

    var
        EndDateCannotBePastErr: Label 'End date cannot be in the past.';
        FailedGenerateLicenseErr: Label 'Failed to generate license.';
        // Labels for translatable text
        LicenseGeneratedSuccessMsg: Label 'License generated successfully!\\License ID: %1', Comment = '%1 - The generated license ID.';
        PleaseEnterCustomerNameErr: Label 'Please enter a customer name.';
        PleaseEnterValidEndDateErr: Label 'Please enter a valid end date.';
        PleaseEnterValidStartDateErr: Label 'Please enter a valid start date.';
        PleaseSelectApplicationErr: Label 'Please select an application.';
        StartDateBeforeEndDateErr: Label 'Start date must be before end date.';
}