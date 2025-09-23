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
                        Message('License generated successfully!' + NewLine() + 'License ID: %1', GeneratedLicenseId);
                        CurrPage.Close();
                    end else
                        Error('Failed to generate license.');
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
    local procedure ValidateInput()
    begin
        if IsNullGuid(SelectedAppId) then
            Error('Please select an application.');

        if CustomerName = '' then
            Error('Please enter a customer name.');

        if ValidFrom = 0D then
            Error('Please enter a valid start date.');

        if ValidTo = 0D then
            Error('Please enter a valid end date.');

        if ValidFrom > ValidTo then
            Error('Start date must be before end date.');

        if ValidTo < Today then
            Error('End date cannot be in the past.');
    end;

    /// <summary>
    /// Gets a newline character for formatting.
    /// </summary>
    local procedure NewLine(): Char
    begin
        exit(10);
    end;
}