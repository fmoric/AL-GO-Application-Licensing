namespace ApplicationLicensing.Base.Codeunit;

using ApplicationLicensing.Base.Tables;

/// <summary>
/// Codeunit Application Manager (ID 80501).
/// Manages application registration and provides application-related services.
/// 
/// This codeunit provides:
/// - Application registration services
/// - Application validation
/// - Application lookup functionality
/// </summary>
codeunit 80501 "Application Manager"
{
    /// <summary>
    /// Registers a new application in the system.
    /// </summary>
    /// <param name="AppId">The unique application identifier.</param>
    /// <param name="AppName">The application name.</param>
    /// <param name="Publisher">The publisher name.</param>
    /// <param name="Version">The version string.</param>
    /// <param name="Description">Optional description.</param>
    /// <returns>True if registration was successful.</returns>
    procedure RegisterApplication(AppId: Guid; AppName: Text[100]; Publisher: Text[100]; Version: Text[20]; Description: Text[250]): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        // Check if application already exists
        if ApplicationRegistry.Get(AppId) then begin
            // Update existing application
            ApplicationRegistry."App Name" := AppName;
            ApplicationRegistry.Publisher := Publisher;
            ApplicationRegistry.Version := Version;
            ApplicationRegistry.Description := Description;
            ApplicationRegistry.Active := true;
            exit(ApplicationRegistry.Modify(true));
        end else begin
            // Create new application
            ApplicationRegistry.Init();
            ApplicationRegistry."App ID" := AppId;
            ApplicationRegistry."App Name" := AppName;
            ApplicationRegistry.Publisher := Publisher;
            ApplicationRegistry.Version := Version;
            ApplicationRegistry.Description := Description;
            ApplicationRegistry.Active := true;
            exit(ApplicationRegistry.Insert(true));
        end;
    end;

    /// <summary>
    /// Validates if an application is registered and active.
    /// </summary>
    /// <param name="AppId">The application ID to validate.</param>
    /// <returns>True if the application is registered and active.</returns>
    procedure IsApplicationValid(AppId: Guid): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            exit(false);

        exit(ApplicationRegistry.Active);
    end;

    /// <summary>
    /// Gets application information by ID.
    /// </summary>
    /// <param name="AppId">The application ID to lookup.</param>
    /// <param name="AppName">Output: Application name.</param>
    /// <param name="Publisher">Output: Publisher name.</param>
    /// <param name="Version">Output: Version string.</param>
    /// <returns>True if the application was found.</returns>
    procedure GetApplicationInfo(AppId: Guid; var AppName: Text[100]; var Publisher: Text[100]; var Version: Text[20]): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            exit(false);

        AppName := ApplicationRegistry."App Name";
        Publisher := ApplicationRegistry.Publisher;
        Version := ApplicationRegistry.Version;
        exit(true);
    end;

    /// <summary>
    /// Deactivates an application (prevents new licenses but keeps existing ones).
    /// </summary>
    /// <param name="AppId">The application ID to deactivate.</param>
    /// <returns>True if deactivation was successful.</returns>
    procedure DeactivateApplication(AppId: Guid): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            exit(false);

        ApplicationRegistry.Active := false;
        exit(ApplicationRegistry.Modify(true));
    end;

    /// <summary>
    /// Activates an application.
    /// </summary>
    /// <param name="AppId">The application ID to activate.</param>
    /// <returns>True if activation was successful.</returns>
    procedure ActivateApplication(AppId: Guid): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            exit(false);

        ApplicationRegistry.Active := true;
        exit(ApplicationRegistry.Modify(true));
    end;

    /// <summary>
    /// Gets the count of active licenses for an application.
    /// </summary>
    /// <param name="AppId">The application ID.</param>
    /// <returns>The number of active licenses for the application.</returns>
    procedure GetActiveLicenseCount(AppId: Guid): Integer
    var
        LicenseRegistry: Record "License Registry";
    begin
        LicenseRegistry.SetRange("App ID", AppId);
        LicenseRegistry.SetRange(Status, LicenseRegistry.Status::Active);
        exit(LicenseRegistry.Count());
    end;

    /// <summary>
    /// Command-line interface: Register a new application.
    /// </summary>
    /// <param name="AppId">Application identifier (GUID format).</param>
    /// <param name="AppName">Application name.</param>
    /// <param name="Publisher">Publisher name.</param>
    /// <param name="Version">Version string.</param>
    /// <param name="Description">Optional description.</param>
    procedure CLI_RegisterApplication(AppId: Text; AppName: Text; Publisher: Text; Version: Text; Description: Text)
    var
        AppGuid: Guid;
    begin
        if not Evaluate(AppGuid, AppId) then
            Error('Invalid GUID format for App ID: %1', AppId);

        if not RegisterApplication(AppGuid, CopyStr(AppName, 1, 100), CopyStr(Publisher, 1, 100), CopyStr(Version, 1, 20), CopyStr(Description, 1, 250)) then
            Error('Failed to register application: %1', AppName);

        Message('Application registered successfully: %1', AppName);
    end;
}