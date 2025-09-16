namespace ApplicationLicensing.Codeunit;

using ApplicationLicensing.Tables;

/// <summary>
/// Codeunit Application Manager (ID 80500).
/// Manages application registration, updates, and lifecycle operations.
/// </summary>
codeunit 80500 "Application Manager"
{

    /// <summary>
    /// Registers a new application in the system.
    /// </summary>
    /// <param name="AppId">The unique application identifier.</param>
    /// <param name="AppName">The application name.</param>
    /// <param name="Publisher">The publisher name.</param>
    /// <param name="Version">The application version.</param>
    /// <param name="Description">Optional description.</param>
    /// <returns>True if registration was successful.</returns>
    procedure RegisterApplication(AppId: Guid; AppName: Text[100]; Publisher: Text[100]; Version: Text[20]; Description: Text[250]): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if ApplicationExists(AppId) then
            Error('Application with ID %1 already exists.', AppId);

        ApplicationRegistry.Init();
        ApplicationRegistry."App ID" := AppId;
        ApplicationRegistry."App Name" := AppName;
        ApplicationRegistry.Publisher := Publisher;
        ApplicationRegistry.Version := Version;
        ApplicationRegistry.Description := Description;
        ApplicationRegistry.Active := true;

        exit(ApplicationRegistry.Insert(true));
    end;

    /// <summary>
    /// Updates an existing application registration.
    /// </summary>
    /// <param name="AppId">The application identifier to update.</param>
    /// <param name="AppName">The new application name.</param>
    /// <param name="Publisher">The new publisher name.</param>
    /// <param name="Version">The new version.</param>
    /// <param name="Description">The new description.</param>
    /// <returns>True if update was successful.</returns>
    procedure UpdateApplication(AppId: Guid; AppName: Text[100]; Publisher: Text[100]; Version: Text[20]; Description: Text[250]): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            Error('Application with ID %1 does not exist.', AppId);

        ApplicationRegistry."App Name" := AppName;
        ApplicationRegistry.Publisher := Publisher;
        ApplicationRegistry.Version := Version;
        ApplicationRegistry.Description := Description;

        exit(ApplicationRegistry.Modify(true));
    end;

    /// <summary>
    /// Activates or deactivates an application.
    /// </summary>
    /// <param name="AppId">The application identifier.</param>
    /// <param name="Active">True to activate, false to deactivate.</param>
    /// <returns>True if operation was successful.</returns>
    procedure SetApplicationStatus(AppId: Guid; Active: Boolean): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            Error('Application with ID %1 does not exist.', AppId);

        ApplicationRegistry.Active := Active;
        exit(ApplicationRegistry.Modify(true));
    end;

    /// <summary>
    /// Checks if an application exists in the registry.
    /// </summary>
    /// <param name="AppId">The application identifier to check.</param>
    /// <returns>True if application exists.</returns>
    procedure ApplicationExists(AppId: Guid): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
    begin
        exit(ApplicationRegistry.Get(AppId));
    end;

    /// <summary>
    /// Gets application information.
    /// </summary>
    /// <param name="AppId">The application identifier.</param>
    /// <param name="ApplicationRegistry">Output parameter with application data.</param>
    /// <returns>True if application was found.</returns>
    procedure GetApplication(AppId: Guid; var ApplicationRegistry: Record "Application Registry"): Boolean
    begin
        exit(ApplicationRegistry.Get(AppId));
    end;

    /// <summary>
    /// Gets all active applications.
    /// </summary>
    /// <param name="ApplicationRegistry">Output record set with active applications.</param>
    procedure GetActiveApplications(var ApplicationRegistry: Record "Application Registry")
    begin
        ApplicationRegistry.SetRange(Active, true);
    end;

    /// <summary>
    /// Deletes an application and all associated licenses.
    /// </summary>
    /// <param name="AppId">The application identifier to delete.</param>
    /// <returns>True if deletion was successful.</returns>
    procedure DeleteApplication(AppId: Guid): Boolean
    var
        ApplicationRegistry: Record "Application Registry";
        LicenseRegistry: Record "License Registry";
    begin
        if not ApplicationRegistry.Get(AppId) then
            Error('Application with ID %1 does not exist.', AppId);

        // Check for existing licenses
        LicenseRegistry.SetRange("App ID", AppId);
        if not LicenseRegistry.IsEmpty then
            if not Confirm(
                StrSubstNo('Application %1 has associated licenses. Delete all licenses and the application?', ApplicationRegistry."App Name"), false) then
                exit(false);

        // Delete all associated licenses
        LicenseRegistry.DeleteAll(true);

        // Delete the application
        exit(ApplicationRegistry.Delete(true));
    end;
}