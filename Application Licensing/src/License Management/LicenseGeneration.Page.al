namespace ApplicationLicensing.Pages;

using ApplicationLicensing.Codeunit;
using ApplicationLicensing.Tables;

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

    layout
    {
        area(Content)
        {
            group(Application)
            {
                Caption = 'Application Selection';
                field(SelectedAppId; SelectedAppId)
                {
                    ApplicationArea = All;
                    Caption = 'Application';
                    ToolTip = 'Select the application for which to generate a license.';
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
                    ApplicationArea = All;
                    Caption = 'Application Name';
                    ToolTip = 'Shows the selected application name.';
                    Editable = false;
                }
                field(SelectedPublisher; SelectedPublisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Shows the selected application publisher.';
                    Editable = false;
                }
                field(SelectedVersion; SelectedVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    ToolTip = 'Shows the selected application version.';
                    Editable = false;
                }
            }
            group(Customer)
            {
                Caption = 'Customer Information';
                field(CustomerName; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Enter the customer name for the license.';
                    ShowMandatory = true;
                }
            }
            group(Validity)
            {
                Caption = 'License Validity';
                field(ValidFrom; ValidFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Valid From';
                    ToolTip = 'Enter the date when the license becomes valid.';
                    ShowMandatory = true;
                }
                field(ValidTo; ValidTo)
                {
                    ApplicationArea = All;
                    Caption = 'Valid To';
                    ToolTip = 'Enter the date when the license expires.';
                    ShowMandatory = true;
                }
            }
            group(Features)
            {
                Caption = 'Licensed Features';
                field(LicensedFeatures; LicensedFeatures)
                {
                    ApplicationArea = All;
                    Caption = 'Features';
                    ToolTip = 'Enter comma-separated list of licensed features.';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
        ValidFrom := Today;
        ValidTo := CalcDate('<+1Y>', Today);
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

        if ValidTo < Today then
            Error(EndDateCannotBePastErr);
    end;

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    local procedure NewLine(): Char
    begin
        exit(10);
    end;

    var
        // Labels for translatable text
        LicenseGeneratedSuccessMsg: Label 'License generated successfully!\\License ID: %1';
        FailedGenerateLicenseErr: Label 'Failed to generate license.';
        PleaseSelectApplicationErr: Label 'Please select an application.';
        PleaseEnterCustomerNameErr: Label 'Please enter a customer name.';
        PleaseEnterValidStartDateErr: Label 'Please enter a valid start date.';
        PleaseEnterValidEndDateErr: Label 'Please enter a valid end date.';
        StartDateBeforeEndDateErr: Label 'Start date must be before end date.';
        EndDateCannotBePastErr: Label 'End date cannot be in the past.';
}