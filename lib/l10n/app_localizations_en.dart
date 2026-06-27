// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Control';

  @override
  String get home => 'Home';

  @override
  String get config => 'Config';

  @override
  String get navViewLayout => 'View Layout';

  @override
  String get navHaDashboard => 'HA Dashboard';

  @override
  String get addWidget => 'Add Widget';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryWeather => 'Weather';

  @override
  String get categoryCalendar => 'Calendar';

  @override
  String get categoryTransit => 'Transit';

  @override
  String get categorySmartHome => 'Smart Home';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get biometricsFaceUnavailableTooltip =>
      'The connected device does not support face recognition';

  @override
  String get biometricsFingerprintUnavailableTooltip =>
      'The connected device does not support fingerprint reading';

  @override
  String get admin => 'Admin';

  @override
  String get logs => 'Logs';

  @override
  String get about => 'About';

  @override
  String get setup => 'Setup';

  @override
  String get screenshot => 'Screenshot';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get homeActivateGuest => 'Guest Mode';

  @override
  String get language => 'Language';

  @override
  String get addPageTooltip => 'Add Page';

  @override
  String get deletePageTooltip => 'Delete Page';

  @override
  String get deletePageTitle => 'Delete Page';

  @override
  String get deletePageContent =>
      'Are you sure you want to delete this page? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading';

  @override
  String pageLabel(Object current, Object total) {
    return 'Page $current / $total';
  }

  @override
  String pageTabLabel(Object number) {
    return 'Page $number';
  }

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get cityLabel => 'City';

  @override
  String get unitsLabel => 'Units';

  @override
  String get unitsMetricCelsius => 'metric (°C)';

  @override
  String get unitsImperialFahrenheit => 'imperial (°F)';

  @override
  String get unitsStandardKelvin => 'standard (K)';

  @override
  String get unknown => 'unknown';

  @override
  String get apiKeyMissingShort => 'No API key configured (check settings).';

  @override
  String weatherPanelSummary(Object city, Object units) {
    return 'Weather: $city\nUnits: $units';
  }

  @override
  String get apiKeyRequired => 'API key required.';

  @override
  String get cityRequired => 'City required.';

  @override
  String get apiErrorInvalidKey => 'Invalid API key.';

  @override
  String get apiErrorRateLimited => 'Rate limited. Try again later.';

  @override
  String get apiErrorNetwork => 'Network error. Check your connection.';

  @override
  String get apiErrorGenericKeyValidation => 'Could not validate API key.';

  @override
  String get cityNotFound => 'City not found.';

  @override
  String get openWeatherSettingsTitle => 'OpenWeather Settings';

  @override
  String get widgetNameOpenWeatherCurrent => 'Current Weather';

  @override
  String get widgetNameOpenWeatherForecast => 'Weather Forecast';

  @override
  String get widgetNameTextLabel => 'Text Label';

  @override
  String get widgetNameImage => 'Image';

  @override
  String get widgetNameRainRadar => 'Rain Radar';

  @override
  String get rainRadarSettingsTitle => 'Rain Radar Settings';

  @override
  String get googleCalendarSettingsTitle => 'Google Calendar Settings';

  @override
  String get googleAuthorizeButton => 'Authorize Google';

  @override
  String get googleAuthRequired => 'Please authorize Google to continue.';

  @override
  String get googleAuthFailed => 'Authorization failed. Please try again.';

  @override
  String get googleErrorInvalid =>
      'Invalid or revoked token. Please log in again.';

  @override
  String get googleErrorScopes =>
      'Permissions missing. Please grant access to your calendar.';

  @override
  String get googleErrorNetwork => 'Cannot reach Google to validate token.';

  @override
  String get googleConnected => 'Google is connected';

  @override
  String get googleNotConnected => 'Google is not connected';

  @override
  String get googleCalendarIdLabel => 'Calendar ID';

  @override
  String get googleMaxResultsLabel => 'Max results';

  @override
  String get googleMaxResultsInvalid => 'Enter a positive number';

  @override
  String get widgetNameGoogleCalendarUpcoming => 'Google Calendar Upcoming';

  @override
  String get widgetNameGoogleCalendarNextTwoDay => 'Two days';

  @override
  String get googleCalendarMissingToken =>
      'Google token missing (open settings)';

  @override
  String get googleCalendarReady => 'Google upcoming with';

  @override
  String get googleCalendarNextTwoDays => 'Google next two days with';

  @override
  String maxResults(int count) {
    return 'Max results: $count';
  }

  @override
  String get upload => 'Upload';

  @override
  String get configGestures => 'Gestures';

  @override
  String get homeAssistantMap => 'Home Assistant Map';

  @override
  String get personalData => 'Personal Data';

  @override
  String get haDisableSnapping => 'Disable grid snapping';

  @override
  String get haEnableSnapping => 'Enable grid snapping';

  @override
  String get haRenameDashboard => 'Rename current dashboard';

  @override
  String get haAddDashboard => 'Create a new dashboard';

  @override
  String get haDeleteDashboard => 'Permanently delete this dashboard';

  @override
  String get haSwitchDashboard => 'Switch between your dashboards';

  @override
  String get haRefreshStates => 'Refresh Home Assistant live states';

  @override
  String get haEmptyHint => 'Long press to add your first entity';

  @override
  String get haDeleteConfirmTitle => 'Delete Dashboard';

  @override
  String haDeleteConfirmContent(String name) {
    return 'Are you sure you want to delete \'$name\'? This will permanently remove all items on this dashboard.';
  }

  @override
  String get haConfigTitle => 'Home Assistant Configuration';

  @override
  String get haTokenError => 'Token Error';

  @override
  String get haUnreachable => 'Unreachable';

  @override
  String get haConnectionFailed => 'Connection Failed';

  @override
  String get haRetry => 'Retry';

  @override
  String get haConfigureConnection => 'Configure Connection';

  @override
  String get haTokenErrorMessage =>
      'Home Assistant token is missing or expired. Please check your backend connection.';

  @override
  String get haUnreachableMessage =>
      'Home Assistant URL is incorrect or the server is down.';

  @override
  String get haNewDashboard => 'New Dashboard';

  @override
  String get haRenameDashboardTitle => 'Rename Dashboard';

  @override
  String get haDashboardNameField => 'Name';

  @override
  String get haConfigUrlLabel => 'Server URL';

  @override
  String get haConfigUrlHint => 'http://ip:port';

  @override
  String get haConfigTokenLabel => 'Long-Lived Access Token';

  @override
  String get haConfigTest => 'Test';

  @override
  String get haConfigSuccess => 'Connection Successful!';

  @override
  String get haConfigInvalidUrl => 'Please enter a valid URL';

  @override
  String get haConfigRequiredField => 'This field is required';

  @override
  String get widgetNameHASingleDashboard => 'SingleDashboard';

  @override
  String get haSelectDashboard => 'Select Dashboard';

  @override
  String get haNoDashboardsFound =>
      'No dashboards found for this user. Create one in the HA Map settings first.';

  @override
  String get haSearchEntities => 'Search entities...';

  @override
  String get haFilterAll => 'All';

  @override
  String get haFilterBool => 'Boolean';

  @override
  String get haFilterNumeric => 'Numeric';

  @override
  String get haFilterOnlyAvailable => 'Only Available';

  @override
  String get haStateUnavailable => 'Unavailable';

  @override
  String get haFilterString => 'Text/Status';

  @override
  String get haDeleteSymbol => 'Delete Symbol';

  @override
  String get haDeleteSymbolConfirm =>
      'Are you sure you want to delete this symbol?';

  @override
  String get haConfigNoLocalError =>
      'Addresses ending in \'.local\' are not supported';

  @override
  String get widgetNameCataasImage => 'Random Cat Image';

  @override
  String get widgetNameCataasGif => 'Random Cat GIF';

  @override
  String get widgetNameRandomDog => 'Random Dog Image';

  @override
  String get widgetNamePokemonOfTheDay => 'Pokémon des Tages';

  @override
  String get widgetNameRandomPokemon => 'Zufälliges Pokémon';

  @override
  String get widgetNameRandomCompliment => 'Random Compliment';

  @override
  String get widgetNameRandomInsult => 'Random Insult';

  @override
  String get widgetNameRandomUselessFact => 'Random Useless Fact';

  @override
  String get randomInsultAllow18Plus => 'Allow 18+ insults';

  @override
  String get editWidgetProperties => 'Edit Widget Style';

  @override
  String get widgetNameHAMultiDashboard => 'Multi-Dashboard';

  @override
  String get haSelectDashboards => 'Configure Dashboards';

  @override
  String get haAvailableDashboards => 'Select dashboards to include';

  @override
  String get widgetNameBusStop => 'Bus Stop';

  @override
  String get widgetNameSystemUsage => 'System Usage';

  @override
  String get haConfigureBusStop => 'Configure Bus Stop';

  @override
  String get haBusLine => 'Line';

  @override
  String get haDepartures => 'Departures';

  @override
  String get haAddBusLine => 'Add Line';

  @override
  String get haLineNumber => 'Line Number';

  @override
  String get haAddDeparture => 'Add Departure';

  @override
  String get haEditBusLine => 'Edit Line';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get textInput => 'Text';

  @override
  String get adminScreenTitle => 'Admin';

  @override
  String get adminCreateUserTitle => 'Create User';

  @override
  String get adminFieldUsername => 'Username';

  @override
  String get adminFieldPassword => 'Password';

  @override
  String get adminFieldConfirmPassword => 'Confirm Password';

  @override
  String get adminCreateUserButton => 'Create User';

  @override
  String get adminValidatorPasswordMismatch => 'Passwords do not match.';

  @override
  String get adminUserCreateSuccess => 'User created successfully.';

  @override
  String get adminTokenAddSuccess => 'Token added successfully.';

  @override
  String get validatorRequired => 'This field is required.';

  @override
  String get errorInvalidCredentials => 'Invalid credentials.';

  @override
  String get errorConfigError => 'Configuration error.';

  @override
  String get errorInvalidMessage => 'Invalid message.';

  @override
  String get errorUnknown => 'An unknown error occurred.';

  @override
  String get errorAddToken => 'Token addition failed.';

  @override
  String get errorFaceTrainingSuccess => 'Face training successful.';

  @override
  String get errorFaceTrainingFailed => 'Face training failed.';

  @override
  String get errorAddCreateUserSuccess => 'User created successfully.';

  @override
  String get errorAddCreateUserFailed => 'Failed to create user.';

  @override
  String get errorUnauthorized => 'Unauthorized action.';

  @override
  String get errorServiceNotAvailable => 'Service not available.';

  @override
  String get errorFrontendUpdated => 'Frontend successfully updated.';

  @override
  String get errorBackendUpdated => 'Backend successfully updated.';

  @override
  String get errorWebappUpdated => 'Webapp successfully updated.';

  @override
  String get errorUpdateFailed => 'Update failed.';

  @override
  String get adminDeviceSettingsTitle => 'Device Settings';

  @override
  String get adminDeviceName => 'Device Name';

  @override
  String get adminAutoSwitch => 'Auto Switch';

  @override
  String get adminAutoSwitchTooltip =>
      'Automatically switches users via FaceID. Recommended only with an active camera. Can also be used to auto-logout.';

  @override
  String get adminApplySettings => 'Apply Settings';

  @override
  String get adminSettingsSuccess => 'Device settings updated.';

  @override
  String get adminUpdateSectionTitle => 'Updates';

  @override
  String get adminCheckForUpdates => 'Check for updates';

  @override
  String get adminUpdatesNotChecked =>
      'No update check has been performed yet.';

  @override
  String get adminNoUpdatesFound => 'No new updates are available.';

  @override
  String get adminNoUpdatesAvailable => 'No update available';

  @override
  String get adminFrontendUpdate => 'Frontend';

  @override
  String get adminBackendUpdate => 'Backend';

  @override
  String get adminWebappUpdate => 'Webapp';

  @override
  String get adminTomlUploadTitle => 'TOML configuration';

  @override
  String get adminTomlUploadDescription =>
      'Choose a TOML file from your device and send its content to the backend.';

  @override
  String get adminTomlChooseFile => 'Choose TOML file';

  @override
  String get adminTomlNoFileSelected => 'No TOML file selected yet.';

  @override
  String adminTomlSelectedFile(String fileName) {
    return 'Selected file: $fileName';
  }

  @override
  String get adminTomlUploadButton => 'Upload config';

  @override
  String get adminTomlReadError => 'The selected TOML file could not be read.';

  @override
  String get adminTomlUploadSuccess => 'Configuration uploaded successfully.';

  @override
  String get adminTomlUploadError => 'The TOML configuration is invalid.';

  @override
  String adminTomlUploadErrorWithMessage(String message) {
    return 'The TOML configuration is invalid: $message';
  }

  @override
  String get adminTomlDownloadButton => 'Download config';

  @override
  String get adminTomlDownloadSuccess =>
      'Configuration downloaded successfully.';

  @override
  String get adminTomlRestartTitle => 'Restart smirror?';

  @override
  String get adminTomlRestartMessage =>
      'The new configuration was saved. Restarting smirror is recommended. Do you want to restart now?';

  @override
  String get adminTomlRestartYes => 'Yes';

  @override
  String get syncAvailableTitle => 'Update Available';

  @override
  String get syncAvailableMessage =>
      'A newer view configuration is available from the connected device. Do you want to update?';

  @override
  String get welcomeUpdateAvailableTitle => 'Device update available';

  @override
  String welcomeFrontendUpdateAvailable(String version) {
    return 'A frontend update is available: $version';
  }

  @override
  String welcomeBackendUpdateAvailable(String version) {
    return 'A backend update is available: $version';
  }

  @override
  String welcomeWebappUpdateAvailable(String version) {
    return 'A webapp update is available: $version';
  }

  @override
  String get welcomeUpdateAvailableAction =>
      'Please switch to the admin account and update the device.';

  @override
  String get update => 'Update';

  @override
  String get updateAll => 'Update All';

  @override
  String get haNoDashboards => 'No dashboards yet. Create one to get started.';

  @override
  String get adminUsersTitle => 'Users';

  @override
  String get adminNoUsers => 'No users found.';

  @override
  String get adminColumnUser => 'User';

  @override
  String get adminDeleteUser => 'Delete user';

  @override
  String get adminDeleteConfirmTitle => 'Delete user?';

  @override
  String adminDeleteConfirmMessage(String name) {
    return 'User \"$name\" will be permanently deleted. This action cannot be undone.';
  }

  @override
  String get adminDeleteConfirmButton => 'Delete';

  @override
  String get adminTokenTitle => 'API Tokens';

  @override
  String adminTokenMissingWarning(String provider) {
    return 'Token for $provider is missing. Please add it in the Admin Settings.';
  }

  @override
  String get adminTokenPresent => 'Connected';

  @override
  String get adminTokenAbsent => 'Not Configured';

  @override
  String get adminTokenAdd => 'Add Token';

  @override
  String get adminTokenDelete => 'Delete Token';

  @override
  String get adminTokenDeleteConfirmTitle => 'Delete Token?';

  @override
  String get adminTokenDeleteConfirmText =>
      'Are you sure you want to delete this token? This cannot be undone.';

  @override
  String get adminTokenDeleteConfirmYes => 'Yes, Delete';

  @override
  String get adminTokenDeleteConfirmNo => 'Cancel';

  @override
  String get adminTokenAuthorize => 'Authorize';

  @override
  String adminEditTokenTitle(String provider) {
    return 'Edit Token: $provider';
  }

  @override
  String get adminEditTokenSave => 'Save Token';

  @override
  String get adminGoogleManualConfigTitle =>
      'Mirror backend has no Google Client ID. Enter manually:';

  @override
  String get adminGoogleClientId => 'Google Client ID';

  @override
  String get adminGoogleClientSecret => 'Google Client Secret (Optional)';

  @override
  String get adminGoogleApplyLocal => 'Apply Credentials Locally';

  @override
  String get adminDeleteProtectedAdmin =>
      'The admin account cannot be deleted.';

  @override
  String get adminRightsProtectedAdmin =>
      'The admin account always has all rights.';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get biometricsTitle => 'Biometrics & Security';

  @override
  String get biometricsUserEnrollment => 'User Enrollment';

  @override
  String get biometricsFaceRecognition => 'Face Recognition';

  @override
  String get biometricsFaceSubtitle => 'Register facial data for current user';

  @override
  String get biometricsTrainFace => 'Train Face';

  @override
  String get biometricsFingerprint => 'Fingerprint';

  @override
  String get biometricsFingerprintSubtitle =>
      'Register fingerprint for current user';

  @override
  String get biometricsTrainFinger => 'Train Finger';

  @override
  String get biometricsFaceTrainingStart =>
      'sMirror is now in search mode. Please move in front of the sMirror.';

  @override
  String get biometricsFingerprintStart =>
      'Fingerprint training requested (waiting for backend).';

  @override
  String get deviceConnection => 'Device Connection';

  @override
  String get currentUser => 'Current User';

  @override
  String get changeUser => 'Change User';

  @override
  String get changeUserLogin => 'Change User Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get apply => 'Apply';

  @override
  String get loginErrorCredentials => 'Please check your username or password.';

  @override
  String get loginErrorNetwork => 'Could not connect. Please try again.';

  @override
  String get setupAppearance => 'Appearance';

  @override
  String get setupSystem => 'System';

  @override
  String get setupThemeLight => 'Light';

  @override
  String get setupThemeDark => 'Dark';

  @override
  String get setupThemeSystem => 'System';

  @override
  String get logNoLogsAvailable => 'No logs available';

  @override
  String get logTime => 'Time';

  @override
  String get logLevel => 'Level';

  @override
  String get logMessage => 'Message';

  @override
  String get logRefresh => 'Refresh Logs';

  @override
  String get homeControlsTitle => 'Controls';

  @override
  String get homeWaitingForStatus => 'Waiting for status...';

  @override
  String haConfigEntityTitle(Object entityId) {
    return 'Configure $entityId';
  }

  @override
  String get haConfigStandardStyle => 'Standard Style (Base/Off State)';

  @override
  String get haConfigDisplayName => 'Display Name';

  @override
  String get haConfigTriggerValue => 'Trigger Value (>=)';

  @override
  String haEntityPickerError(Object error) {
    return 'Error: $error';
  }

  @override
  String get haSelectBackgroundImage => 'Select Background Image';

  @override
  String haBusEditLine(Object num) {
    return 'Edit Line $num';
  }

  @override
  String get haBusAutoGenerate => 'Auto-Generate';

  @override
  String get haBusLineNumberLabel => 'Line Number';

  @override
  String get haBusFrequency => 'Frequency (minutes)';

  @override
  String get haBusGenerateSchedule => 'Generate Schedule';

  @override
  String get haBusNoRanges => 'No ranges added yet.';

  @override
  String haBusTimeRangeTitle(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String haBusTimeRangeSubtitle(Object freq) {
    return 'Every $freq mins';
  }

  @override
  String get haBusAddTimeRange => 'Add Time Range';

  @override
  String get haBusGenerate => 'Generate';

  @override
  String get haBusAdd => 'Add';

  @override
  String get editTextLabelTitle => 'Edit Text Label';

  @override
  String get editImagePickPhotos => 'Pick Photos';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get appBackendDemoTitle => 'App → Backend WebSocket Demo';

  @override
  String get homeWakeUp => 'Wake Up';

  @override
  String get homeStandBy => 'StandBy';

  @override
  String get homeActivateUser => 'Activate User';

  @override
  String get homeNextTheme => 'Toggle Theme';

  @override
  String get homeSystemStatus => 'System Status';

  @override
  String get homeFrontend => 'Frontend';

  @override
  String get homeOn => 'ON';

  @override
  String get homeOff => 'OFF';

  @override
  String get homeAutoSwitch => 'Auto Switch';

  @override
  String get homeActiveUserStatus => 'Active User';

  @override
  String get homeNone => 'None';

  @override
  String get addDevice => 'Add Device';

  @override
  String get close => 'Close';

  @override
  String get deviceName => 'Device Name';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get noDevicesConfigured => 'No devices configured.';

  @override
  String get testResultSuccess => 'Connection Successful';

  @override
  String get testResultUnauthorized => 'Connected (Requires Login)';

  @override
  String get testResultOutdated => 'App version too old!';

  @override
  String get testResultFailed => 'Connection Failed';

  @override
  String get upgradeRequiredTitle => 'App Update Required';

  @override
  String get upgradeRequiredMessage =>
      'The connected device requires a newer version of this app. Please update the app to continue.';

  @override
  String get setupDangerZone => 'Danger Zone';

  @override
  String get setupFactoryReset => 'Factory Reset';

  @override
  String get setupFactoryResetConfirmTitle => 'Factory Reset';

  @override
  String get setupFactoryResetConfirmMessage =>
      'Are you sure you want to completely reset the app? All local data, dashboards, and settings will be permanently deleted. This action cannot be undone.';

  @override
  String get logThreadId => 'Thread';

  @override
  String get logSourceLocation => 'Source';

  @override
  String setupVersion(String version) {
    return 'Version $version';
  }

  @override
  String get developerModeEnabled => 'Developer mode enabled';

  @override
  String get developerModeDisabled => 'Developer mode disabled';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get emulateHomeAssistant => 'Emulate Home Assistant';

  @override
  String get emulatedConnection => 'Emulated Connection';

  @override
  String get developerLogs => 'Developer Logs';

  @override
  String get viewSettingsTitle => 'View Settings';

  @override
  String get viewMetadataTooltip => 'View Metadata';

  @override
  String get viewLanguageLabel => 'Language';

  @override
  String get viewThemeLabel => 'Theme';

  @override
  String get themeBlue => 'Blue';

  @override
  String get themeNeon => 'Neon';

  @override
  String get setupDialogTitle => 'Initial Device Setup';

  @override
  String get setupDialogDescription =>
      'Please configure your new device. Change the default name and set a secure admin password.';

  @override
  String get setupSuccessMessage => 'Device successfully configured!';

  @override
  String get setupErrorMessage =>
      'Failed to update settings. Please try again.';

  @override
  String get setupAdminPasswordLabel => 'New Admin Password';

  @override
  String get setupAdminPasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordChangeSuccess => 'Password changed successfully.';

  @override
  String get passwordChangeError => 'Failed to change password.';

  @override
  String get homeLedControl => 'LED Control';

  @override
  String get brightness => 'Brightness';

  @override
  String get landingTitle => 'Connect your device';

  @override
  String get landingSubtitle =>
      'Choose a device, connect to it, and sign in with the user data stored on that device before entering the app.';

  @override
  String get landingDeviceSectionTitle => '1. Connect to a device';

  @override
  String get landingDeviceSectionSubtitle =>
      'Select a saved device or add a new one with its IP address and port.';

  @override
  String get landingLoginSectionTitle => '2. Sign in for this device';

  @override
  String get landingLoginSectionSubtitle =>
      'Use the credentials that belong to the selected device.';

  @override
  String get landingNoConnectionPossible =>
      'No connection to this device is possible right now. Check the device, network, IP address, and port.';

  @override
  String get landingWrongCredentialsForDevice =>
      'The saved credentials are wrong for this device. Please sign in again with the correct user data.';

  @override
  String get landingSelectDeviceFirst =>
      'Select or add a device before you sign in.';

  @override
  String get landingLoginFormError => 'Enter both username and password.';

  @override
  String get landingDeviceFormError => 'Enter a valid IP address and port.';

  @override
  String get landingNoActiveDevice => 'No device selected';

  @override
  String landingConnectedAs(String username) {
    return 'Connected as $username.';
  }

  @override
  String get locationSettingsTitle => 'Location Settings';

  @override
  String get getCurrentLocation => 'Get Current Location';

  @override
  String get errorFetchingLocation =>
      'Failed to fetch current location. Make sure GPS is enabled and permissions are granted.';

  @override
  String get locationSaved => 'Location saved successfully.';

  @override
  String get locationConfig => 'Location Config';

  @override
  String get rainRadarZoomLabel => 'Zoom';

  @override
  String get rainRadarForecastHoursLabel => 'Forecast horizon';

  @override
  String get widgetNameDigitalClock => 'Digital Clock';

  @override
  String get digitalClockSettingsTitle => 'Digital Clock Settings';

  @override
  String get digitalClock24hLabel => 'Use 24-hour format';

  @override
  String get logout => 'Logout';

  @override
  String get dashboardUploadSuccess => 'Dashboard uploaded successfully.';

  @override
  String get dashboardUploadError => 'Failed to upload dashboard.';

  @override
  String get viewUploadSuccess => 'View layout uploaded successfully.';

  @override
  String get viewUploadError => 'Failed to upload view layout.';

  @override
  String get conflictDialogTitle => 'Session Conflict';

  @override
  String get conflictDialogMessage =>
      'Another app connected as the same user. You have been disconnected.';

  @override
  String get dashboardUpdatedNotification => 'Dashboard updated automatically';

  @override
  String get viewUpdatedNotification => 'View layout updated automatically';
}
