// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Smart Steuerung';

  @override
  String get home => 'Startseite';

  @override
  String get config => 'Konfiguration';

  @override
  String get navViewLayout => 'View-Layout';

  @override
  String get navHaDashboard => 'HA-Dashboard';

  @override
  String get addWidget => 'Widget hinzufügen';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryGeneral => 'Allgemein';

  @override
  String get categoryWeather => 'Wetter';

  @override
  String get categoryCalendar => 'Kalender';

  @override
  String get categoryTransit => 'ÖPNV';

  @override
  String get categorySmartHome => 'Smart Home';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get biometricsFaceUnavailableTooltip =>
      'Das verbundene Gerät unterstützt keine Gesichtserkennung';

  @override
  String get biometricsFingerprintUnavailableTooltip =>
      'Das verbundene Gerät unterstützt keinen Fingerabdruckleser';

  @override
  String get admin => 'Admin';

  @override
  String get logs => 'Protokolle';

  @override
  String get about => 'Über';

  @override
  String get setup => 'Einrichtung';

  @override
  String get screenshot => 'Screenshot';

  @override
  String get themeMode => 'Designmodus';

  @override
  String get homeActivateGuest => 'Gast Modus';

  @override
  String get language => 'Sprache';

  @override
  String get addPageTooltip => 'Seite hinzufügen';

  @override
  String get deletePageTooltip => 'Seite löschen';

  @override
  String get deletePageTitle => 'Seite löschen';

  @override
  String get deletePageContent =>
      'Möchten Sie diese Seite wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get loading => 'Lädt';

  @override
  String pageLabel(Object current, Object total) {
    return 'Seite $current / $total';
  }

  @override
  String pageTabLabel(Object number) {
    return 'Seite $number';
  }

  @override
  String get apiKeyLabel => 'API-Schlüssel';

  @override
  String get cityLabel => 'Stadt';

  @override
  String get unitsLabel => 'Einheiten';

  @override
  String get unitsMetricCelsius => 'metrisch (°C)';

  @override
  String get unitsImperialFahrenheit => 'imperial (°F)';

  @override
  String get unitsStandardKelvin => 'Standard (K)';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get apiKeyMissingShort =>
      'Kein API-Key konfiguriert (Einstellungen prüfen).';

  @override
  String weatherPanelSummary(Object city, Object units) {
    return 'Wetter: $city\nEinheiten: $units';
  }

  @override
  String get apiKeyRequired => 'API-Schlüssel erforderlich.';

  @override
  String get cityRequired => 'Stadt erforderlich.';

  @override
  String get apiErrorInvalidKey => 'Ungültiger API-Schlüssel.';

  @override
  String get apiErrorRateLimited =>
      'Rate-Limit überschritten. Bitte später erneut versuchen.';

  @override
  String get apiErrorNetwork => 'Netzwerkfehler. Bitte Verbindung prüfen.';

  @override
  String get apiErrorGenericKeyValidation =>
      'API-Schlüssel konnte nicht validiert werden.';

  @override
  String get cityNotFound => 'Stadt nicht gefunden.';

  @override
  String get openWeatherSettingsTitle => 'OpenWeather-Einstellungen';

  @override
  String get widgetNameOpenWeatherCurrent => 'Aktuelles Wetter';

  @override
  String get widgetNameOpenWeatherForecast => 'Wettervorhersage';

  @override
  String get widgetNameTextLabel => 'Text-Label';

  @override
  String get widgetNameImage => 'Bild';

  @override
  String get widgetNameRainRadar => 'Regenradar';

  @override
  String get rainRadarSettingsTitle => 'Regenradar-Einstellungen';

  @override
  String get googleCalendarSettingsTitle => 'Google Kalender Einstellungen';

  @override
  String get googleAuthorizeButton => 'Google autorisieren';

  @override
  String get googleAuthRequired =>
      'Bitte Google autorisieren, um fortzufahren.';

  @override
  String get googleAuthFailed =>
      'Autorisierung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get googleErrorInvalid =>
      'Ungültiges oder widerrufenes Token. Bitte erneut anmelden.';

  @override
  String get googleErrorScopes =>
      'Berechtigungen fehlen. Bitte erlauben Sie den Zugriff auf Ihren Kalender.';

  @override
  String get googleErrorNetwork =>
      'Google konnte zum Validieren des Tokens nicht erreicht werden.';

  @override
  String get googleConnected => 'Google ist verbunden';

  @override
  String get googleNotConnected => 'Google ist nicht verbunden';

  @override
  String get googleCalendarIdLabel => 'Kalender-ID';

  @override
  String get googleMaxResultsLabel => 'Maximale Ergebnisse';

  @override
  String get googleMaxResultsInvalid => 'Geben Sie eine positive Zahl ein';

  @override
  String get widgetNameGoogleCalendarUpcoming =>
      'Kommende Google Kalender Termine';

  @override
  String get widgetNameGoogleCalendarNextTwoDay => 'Zwei Tage';

  @override
  String get widgetNameGoogleTasks => 'Google Aufgaben';

  @override
  String get googleTasksSettingsTitle => 'Google Aufgaben-Einstellungen';

  @override
  String get googleTasksReady => 'Google Aufgaben bereit';

  @override
  String get googleCalendarMissingToken =>
      'Google-Token fehlt (Einstellungen öffnen)';

  @override
  String get googleCalendarReady => 'Google Kalender bereit';

  @override
  String get googleCalendarNextTwoDays => 'Google nächste zwei Tage mit';

  @override
  String maxResults(int count) {
    return 'Maximale Ergebnisse: $count';
  }

  @override
  String get upload => 'Hochladen';

  @override
  String get configGestures => 'Gesten';

  @override
  String get homeAssistantMap => 'Home Assistant Karte';

  @override
  String get personalData => 'Persönliche Daten';

  @override
  String get haDisableSnapping => 'Raster-Einrasten deaktivieren';

  @override
  String get haEnableSnapping => 'Raster-Einrasten aktivieren';

  @override
  String get haRenameDashboard => 'Aktuelles Dashboard umbenennen';

  @override
  String get haAddDashboard => 'Neues Dashboard erstellen';

  @override
  String get haDeleteDashboard => 'Dieses Dashboard dauerhaft löschen';

  @override
  String get haSwitchDashboard => 'Zwischen Dashboards wechseln';

  @override
  String get haRefreshStates => 'Home Assistant Zustände aktualisieren';

  @override
  String get haEmptyHint => 'Gedrückt halten, um ein Element hinzuzufügen';

  @override
  String get haDeleteConfirmTitle => 'Dashboard löschen';

  @override
  String haDeleteConfirmContent(String name) {
    return 'Bist du sicher, dass du \'$name\' löschen möchtest? Alle Elemente auf diesem Dashboard gehen verloren.';
  }

  @override
  String get haConfigTitle => 'Home Assistant Konfiguration';

  @override
  String get haTokenError => 'Token-Fehler';

  @override
  String get haUnreachable => 'Nicht erreichbar';

  @override
  String get haConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get haRetry => 'Wiederholen';

  @override
  String get haConfigureConnection => 'Verbindung konfigurieren';

  @override
  String get haTokenErrorMessage =>
      'Der Home Assistant Token fehlt oder ist abgelaufen. Bitte prüfe die Backend-Verbindung.';

  @override
  String get haUnreachableMessage =>
      'Die Home Assistant URL ist falsch oder der Server ist nicht erreichbar.';

  @override
  String get haNewDashboard => 'Neues Dashboard';

  @override
  String get haRenameDashboardTitle => 'Dashboard umbenennen';

  @override
  String get haDashboardNameField => 'Name';

  @override
  String get haConfigUrlLabel => 'Server-URL';

  @override
  String get haConfigUrlHint => 'http://ip:port';

  @override
  String get haConfigTokenLabel => 'Langlebiger Zugriffs-Token';

  @override
  String get haConfigTest => 'Testen';

  @override
  String get haConfigSuccess => 'Verbindung erfolgreich!';

  @override
  String get haConfigInvalidUrl => 'Bitte geben Sie eine gültige URL ein';

  @override
  String get haConfigRequiredField => 'Dies ist ein Pflichtfeld';

  @override
  String get widgetNameHASingleDashboard => 'SingleDashboard';

  @override
  String get haSelectDashboard => 'Dashboard auswählen';

  @override
  String get haNoDashboardsFound =>
      'Keine Dashboards für diesen Benutzer gefunden. Erstellen Sie zuerst eines in den HA-Einstellungen.';

  @override
  String get haSearchEntities => 'Entitäten suchen...';

  @override
  String get haFilterAll => 'Alle';

  @override
  String get haFilterBool => 'Binär';

  @override
  String get haFilterNumeric => 'Numerisch';

  @override
  String get haFilterOnlyAvailable => 'Nur Verfügbare';

  @override
  String get haStateUnavailable => 'Nicht verfügbar';

  @override
  String get haFilterString => 'Text/Status';

  @override
  String get haDeleteSymbol => 'Symbol löschen';

  @override
  String get haDeleteSymbolConfirm =>
      'Möchtest du dieses Symbol wirklich löschen?';

  @override
  String get haConfigNoLocalError =>
      'Adressen mit \'.local\' werden nicht unterstützt';

  @override
  String get widgetNameCataasImage => 'Zufälliges Katzenbild';

  @override
  String get widgetNameCataasGif => 'Random Cat GIF';

  @override
  String get widgetNameRandomDog => 'Zufälliges Hundebild';

  @override
  String get widgetNamePokemonOfTheDay => 'Pokémon des Tages';

  @override
  String get widgetNameRandomPokemon => 'Zufälliges Pokémon';

  @override
  String get widgetNameRandomCompliment => 'Zufälliges Kompliment';

  @override
  String get widgetNameRandomInsult => 'Zufällige Beleidigung';

  @override
  String get widgetNameRandomUselessFact => 'Zufälliger unnützer Fakt';

  @override
  String get randomInsultAllow18Plus => '18+-Beleidigungen erlauben';

  @override
  String get editWidgetProperties => 'Widget-Stil bearbeiten';

  @override
  String get widgetNameHAMultiDashboard => 'Multi-Dashboard';

  @override
  String get haSelectDashboards => 'Dashboards konfigurieren';

  @override
  String get haAvailableDashboards => 'Wähle enthaltene Dashboards';

  @override
  String get widgetNameBusStop => 'Bushaltestelle';

  @override
  String get widgetNameSystemUsage => 'Systemauslastung';

  @override
  String get haConfigureBusStop => 'Bushaltestelle konfigurieren';

  @override
  String get haBusLine => 'Linie';

  @override
  String get haDepartures => 'Abfahrten';

  @override
  String get haAddBusLine => 'Linie hinzufügen';

  @override
  String get haLineNumber => 'Liniennummer';

  @override
  String get haAddDeparture => 'Abfahrt hinzufügen';

  @override
  String get haEditBusLine => 'Linie bearbeiten';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get fontFamily => 'Schriftart';

  @override
  String get textInput => 'Text';

  @override
  String get adminScreenTitle => 'Admin';

  @override
  String get adminCreateUserTitle => 'Benutzer erstellen';

  @override
  String get adminFieldUsername => 'Benutzername';

  @override
  String get adminFieldPassword => 'Passwort';

  @override
  String get adminFieldConfirmPassword => 'Passwort bestätigen';

  @override
  String get adminCreateUserButton => 'Benutzer anlegen';

  @override
  String get adminValidatorPasswordMismatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get adminUserCreateSuccess => 'Benutzer erfolgreich erstellt.';

  @override
  String get adminTokenAddSuccess => 'Token erfolgreich hinzugefügt.';

  @override
  String get validatorRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get errorInvalidCredentials => 'Ungültige Anmeldedaten.';

  @override
  String get errorConfigError => 'Konfigurationsfehler.';

  @override
  String get errorInvalidMessage => 'Ungültige Nachricht.';

  @override
  String get errorUnknown => 'Ein unbekannter Fehler ist aufgetreten.';

  @override
  String get errorAddToken => 'Token konnte nicht hinzugefügt werden.';

  @override
  String get errorFaceTrainingSuccess => 'Gesichtstraining erfolgreich.';

  @override
  String get errorFaceTrainingFailed => 'Gesichtstraining fehlgeschlagen.';

  @override
  String get errorAddCreateUserSuccess => 'Benutzer erfolgreich erstellt.';

  @override
  String get errorAddCreateUserFailed => 'Benutzererstellung fehlgeschlagen.';

  @override
  String get errorUnauthorized => 'Unbefugte Aktion.';

  @override
  String get errorServiceNotAvailable => 'Dienst nicht verfügbar.';

  @override
  String get errorFrontendUpdated => 'Frontend erfolgreich aktualisiert.';

  @override
  String get errorBackendUpdated => 'Backend erfolgreich aktualisiert.';

  @override
  String get errorWebappUpdated => 'Webapp erfolgreich aktualisiert.';

  @override
  String get errorUpdateFailed => 'Update fehlgeschlagen.';

  @override
  String get adminDeviceSettingsTitle => 'Geräteeinstellungen';

  @override
  String get adminDeviceName => 'Gerätename';

  @override
  String get adminAutoSwitch => 'Automatischer Wechsel';

  @override
  String get adminAutoSwitchTooltip =>
      'Wechselt Benutzer automatisch per FaceID. Nur mit aktiver Kamera empfohlen. Kann auch benutzt werden zum automatischen Abmelden.';

  @override
  String get adminApplySettings => 'Einstellungen übernehmen';

  @override
  String get adminSettingsSuccess => 'Geräteeinstellungen aktualisiert.';

  @override
  String get adminUpdateSectionTitle => 'Updates';

  @override
  String get adminCheckForUpdates => 'Nach Updates suchen';

  @override
  String get adminUpdatesNotChecked =>
      'Es wurde noch keine Update-Prüfung durchgeführt.';

  @override
  String get adminNoUpdatesFound => 'Keine neuen Updates verfügbar.';

  @override
  String get adminNoUpdatesAvailable => 'Kein Update verfügbar';

  @override
  String get adminFrontendUpdate => 'Frontend';

  @override
  String get adminBackendUpdate => 'Backend';

  @override
  String get adminWebappUpdate => 'Webapp';

  @override
  String get adminTomlUploadTitle => 'TOML-Konfiguration';

  @override
  String get adminTomlUploadDescription =>
      'Wählen Sie eine TOML-Datei von Ihrem Gerät aus und senden Sie deren Inhalt an das Backend.';

  @override
  String get adminTomlChooseFile => 'TOML-Datei auswählen';

  @override
  String get adminTomlNoFileSelected => 'Noch keine TOML-Datei ausgewählt.';

  @override
  String adminTomlSelectedFile(String fileName) {
    return 'Ausgewählte Datei: $fileName';
  }

  @override
  String get adminTomlUploadButton => 'Konfiguration hochladen';

  @override
  String get adminTomlReadError =>
      'Die ausgewählte TOML-Datei konnte nicht gelesen werden.';

  @override
  String get adminTomlUploadSuccess => 'Konfiguration erfolgreich hochgeladen.';

  @override
  String get adminTomlUploadError => 'Die TOML-Konfiguration ist ungültig.';

  @override
  String adminTomlUploadErrorWithMessage(String message) {
    return 'Die TOML-Konfiguration ist ungültig: $message';
  }

  @override
  String get adminTomlDownloadButton => 'Konfiguration herunterladen';

  @override
  String get adminTomlDownloadSuccess =>
      'Konfiguration erfolgreich heruntergeladen.';

  @override
  String get adminTomlRestartTitle => 'smirror neu starten?';

  @override
  String get adminTomlRestartMessage =>
      'Die neue Konfiguration wurde gespeichert. Ein Neustart von smirror wird empfohlen. Möchten Sie jetzt neu starten?';

  @override
  String get adminTomlRestartYes => 'Ja';

  @override
  String get syncAvailableTitle => 'Update verfügbar';

  @override
  String get syncAvailableMessage =>
      'Eine neuere Ansichtskonfiguration ist vom verbundenen Gerät verfügbar. Möchten Sie aktualisieren?';

  @override
  String get welcomeUpdateAvailableTitle => 'Geräte-Update verfügbar';

  @override
  String welcomeFrontendUpdateAvailable(String version) {
    return 'Ein Frontend-Update ist verfügbar: $version';
  }

  @override
  String welcomeBackendUpdateAvailable(String version) {
    return 'Ein Backend-Update ist verfügbar: $version';
  }

  @override
  String welcomeWebappUpdateAvailable(String version) {
    return 'Ein Webapp-Update ist verfügbar: $version';
  }

  @override
  String get welcomeUpdateAvailableAction =>
      'Bitte wechseln Sie zum Admin-Konto und führen Sie das Update durch.';

  @override
  String get update => 'Aktualisieren';

  @override
  String get updateAll => 'Alle aktualisieren';

  @override
  String get haNoDashboards =>
      'Noch keine Dashboards. Erstellen Sie eines, um zu beginnen.';

  @override
  String get adminUsersTitle => 'Benutzer';

  @override
  String get adminNoUsers => 'Keine Benutzer gefunden.';

  @override
  String get adminColumnUser => 'Benutzer';

  @override
  String get adminDeleteUser => 'Benutzer löschen';

  @override
  String get adminDeleteConfirmTitle => 'Benutzer löschen?';

  @override
  String adminDeleteConfirmMessage(String name) {
    return 'Benutzer \"$name\" wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get adminDeleteConfirmButton => 'Löschen';

  @override
  String get adminTokenTitle => 'API-Tokens';

  @override
  String adminTokenMissingWarning(String provider) {
    return 'Token für $provider fehlt. Bitte in den Admin-Einstellungen hinzufügen.';
  }

  @override
  String get adminTokenPresent => 'Verbunden';

  @override
  String get adminTokenAbsent => 'Nicht konfiguriert';

  @override
  String get adminTokenAdd => 'Token hinzufügen';

  @override
  String get adminTokenDelete => 'Token löschen';

  @override
  String get adminTokenDeleteConfirmTitle => 'Token löschen?';

  @override
  String get adminTokenDeleteConfirmText =>
      'Sind Sie sicher, dass Sie diesen Token löschen möchten? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get adminTokenDeleteConfirmYes => 'Ja, löschen';

  @override
  String get adminTokenDeleteConfirmNo => 'Abbrechen';

  @override
  String get adminTokenAuthorize => 'Autorisieren';

  @override
  String adminEditTokenTitle(String provider) {
    return '$provider Token bearbeiten';
  }

  @override
  String get adminEditTokenSave => 'Token speichern';

  @override
  String get adminGoogleManualConfigTitle =>
      'Mirror-Backend hat keine Google Client ID. Manuell eingeben:';

  @override
  String get adminGoogleClientId => 'Google Client ID';

  @override
  String get adminGoogleClientSecret => 'Google Client Secret (Optional)';

  @override
  String get adminGoogleApplyLocal => 'Anmeldedaten lokal anwenden';

  @override
  String get adminDeleteProtectedAdmin =>
      'Das Adminkonto kann nicht gelöscht werden.';

  @override
  String get adminRightsProtectedAdmin =>
      'Das Adminkonto hat immer alle Rechte.';

  @override
  String get biometrics => 'Biometrie';

  @override
  String get biometricsTitle => 'Biometrie & Sicherheit';

  @override
  String get biometricsUserEnrollment => 'Benutzerregistrierung';

  @override
  String get biometricsFaceRecognition => 'Gesichtserkennung';

  @override
  String get biometricsFaceSubtitle =>
      'Gesichtsdaten für den aktuellen Benutzer registrieren';

  @override
  String get biometricsTrainFace => 'Gesicht trainieren';

  @override
  String get biometricsFingerprint => 'Fingerabdruck';

  @override
  String get biometricsFingerprintSubtitle =>
      'Fingerabdruck für den aktuellen Benutzer registrieren';

  @override
  String get biometricsTrainFinger => 'Finger trainieren';

  @override
  String get biometricsFaceTrainingStart =>
      'Der sMirror ist nun im Suchmodus. Bitte stellen Sie sich vor den sMirror.';

  @override
  String get biometricsFingerprintStart =>
      'Fingerabdruck-Training angefordert (warte auf Backend).';

  @override
  String get deviceConnection => 'Geräteverbindung';

  @override
  String get currentUser => 'Aktueller Benutzer';

  @override
  String get changeUser => 'Benutzer wechseln';

  @override
  String get changeUserLogin => 'Benutzeranmeldung ändern';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get apply => 'Anwenden';

  @override
  String get loginErrorCredentials =>
      'Bitte überprüfen Sie Ihren Benutzernamen oder Ihr Passwort.';

  @override
  String get loginErrorNetwork =>
      'Verbindung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get setupAppearance => 'Erscheinungsbild';

  @override
  String get setupSystem => 'System';

  @override
  String get setupThemeLight => 'Hell';

  @override
  String get setupThemeDark => 'Dunkel';

  @override
  String get setupThemeSystem => 'System';

  @override
  String get logNoLogsAvailable => 'Keine Protokolle verfügbar';

  @override
  String get logTime => 'Zeit';

  @override
  String get logLevel => 'Level';

  @override
  String get logMessage => 'Nachricht';

  @override
  String get logRefresh => 'Protokolle aktualisieren';

  @override
  String get homeControlsTitle => 'Steuerung';

  @override
  String get homeWaitingForStatus => 'Warte auf Status...';

  @override
  String haConfigEntityTitle(Object entityId) {
    return '$entityId konfigurieren';
  }

  @override
  String get haConfigStandardStyle => 'Standardstil (Basis-/Aus-Zustand)';

  @override
  String get haConfigDisplayName => 'Anzeigename';

  @override
  String get haConfigTriggerValue => 'Auslöserwert (>=)';

  @override
  String haEntityPickerError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get haSelectBackgroundImage => 'Hintergrundbild auswählen';

  @override
  String haBusEditLine(Object num) {
    return 'Linie $num bearbeiten';
  }

  @override
  String get haBusAutoGenerate => 'Automatisch generieren';

  @override
  String get haBusLineNumberLabel => 'Liniennummer';

  @override
  String get haBusFrequency => 'Häufigkeit (Minuten)';

  @override
  String get haBusGenerateSchedule => 'Fahrplan generieren';

  @override
  String get haBusNoRanges => 'Noch keine Zeitfenster hinzugefügt.';

  @override
  String haBusTimeRangeTitle(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String haBusTimeRangeSubtitle(Object freq) {
    return 'Alle $freq Min';
  }

  @override
  String get haBusAddTimeRange => 'Zeitfenster hinzufügen';

  @override
  String get haBusGenerate => 'Generieren';

  @override
  String get haBusAdd => 'Hinzufügen';

  @override
  String get editTextLabelTitle => 'Text-Label bearbeiten';

  @override
  String get editImagePickPhotos => 'Fotos auswählen';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get appBackendDemoTitle => 'App → Backend WebSocket Demo';

  @override
  String get homeWakeUp => 'Aufwachen';

  @override
  String get homeStandBy => 'StandBy';

  @override
  String get homeActivateUser => 'Benutzer aktivieren';

  @override
  String get homeNextTheme => 'Design umschalten';

  @override
  String get homeSystemStatus => 'Systemstatus';

  @override
  String get homeFrontend => 'Frontend';

  @override
  String get homeOn => 'EIN';

  @override
  String get homeOff => 'AUS';

  @override
  String get homeAutoSwitch => 'Auto-Wechsel';

  @override
  String get homeActiveUserStatus => 'Aktiver Benutzer';

  @override
  String get homeNone => 'Keiner';

  @override
  String get addDevice => 'Gerät hinzufügen';

  @override
  String get close => 'Schließen';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get ipAddress => 'IP-Adresse';

  @override
  String get port => 'Port';

  @override
  String get noDevicesConfigured => 'Keine Geräte konfiguriert.';

  @override
  String get testResultSuccess => 'Verbindung erfolgreich';

  @override
  String get testResultUnauthorized => 'Verbunden (Login erforderlich)';

  @override
  String get testResultOutdated => 'App-Version zu alt!';

  @override
  String get testResultFailed => 'Verbindung fehlgeschlagen';

  @override
  String get upgradeRequiredTitle => 'App-Update erforderlich';

  @override
  String get upgradeRequiredMessage =>
      'Das verbundene Gerät erfordert eine neuere Version dieser App. Bitte aktualisieren Sie die App, um fortzufahren.';

  @override
  String get setupDangerZone => 'Gefahrenzone';

  @override
  String get setupFactoryReset => 'Auf Werkseinstellungen zurücksetzen';

  @override
  String get setupFactoryResetConfirmTitle => 'Werkseinstellungen';

  @override
  String get setupFactoryResetConfirmMessage =>
      'Sind Sie sicher, dass Sie die App vollständig zurücksetzen möchten? Alle lokalen Daten, Dashboards und Einstellungen werden dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get logThreadId => 'Thread';

  @override
  String get logSourceLocation => 'Quelle';

  @override
  String setupVersion(String version) {
    return 'Version $version';
  }

  @override
  String get developerModeEnabled => 'Entwicklermodus aktiviert';

  @override
  String get developerModeDisabled => 'Entwicklermodus deaktiviert';

  @override
  String get developerMode => 'Entwicklermodus';

  @override
  String get emulateHomeAssistant => 'Home Assistant emulieren';

  @override
  String get emulatedConnection => 'Emulierte Verbindung';

  @override
  String get developerLogs => 'Entwickler-Logs';

  @override
  String get viewSettingsTitle => 'Ansichtseinstellungen';

  @override
  String get viewMetadataTooltip => 'Metadaten der Ansicht';

  @override
  String get viewLanguageLabel => 'Sprache';

  @override
  String get viewThemeLabel => 'Design';

  @override
  String get themeBlue => 'Blau';

  @override
  String get themeNeon => 'Neon';

  @override
  String get setupDialogTitle => 'Ersteinrichtung des Geräts';

  @override
  String get setupDialogDescription =>
      'Bitte konfigurieren Sie Ihr neues Gerät. Ändern Sie den Standardnamen und vergeben Sie ein sicheres Admin-Passwort.';

  @override
  String get setupSuccessMessage => 'Gerät erfolgreich konfiguriert!';

  @override
  String get setupErrorMessage =>
      'Fehler beim Aktualisieren der Einstellungen. Bitte erneut versuchen.';

  @override
  String get setupAdminPasswordLabel => 'Neues Admin password';

  @override
  String get setupAdminPasswordConfirmLabel => 'Bestätige neues Passwort';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmNewPassword => 'Passwort bestätigen';

  @override
  String get passwordChangeSuccess => 'Passwort erfolgreich geändert.';

  @override
  String get passwordChangeError => 'Passwortänderung fehlgeschlagen.';

  @override
  String get homeLedControl => 'LED-Steuerung';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get landingTitle => 'Gerät verbinden';

  @override
  String get landingSubtitle =>
      'Wählen Sie ein Gerät, verbinden Sie sich damit und melden Sie sich mit den auf diesem Gerät hinterlegten Benutzerdaten an, bevor Sie die App nutzen.';

  @override
  String get landingDeviceSectionTitle => '1. Mit einem Gerät verbinden';

  @override
  String get landingDeviceSectionSubtitle =>
      'Wählen Sie ein gespeichertes Gerät oder fügen Sie ein neues mit IP-Adresse und Port hinzu.';

  @override
  String get landingLoginSectionTitle => '2. Für dieses Gerät anmelden';

  @override
  String get landingLoginSectionSubtitle =>
      'Verwenden Sie die Zugangsdaten, die zu dem ausgewählten Gerät gehören.';

  @override
  String get landingNoConnectionPossible =>
      'Zu diesem Gerät ist derzeit keine Verbindung möglich. Prüfen Sie Gerät, Netzwerk, IP-Adresse und Port.';

  @override
  String get landingWrongCredentialsForDevice =>
      'Die gespeicherten Zugangsdaten sind für dieses Gerät falsch. Bitte melden Sie sich mit den korrekten Benutzerdaten erneut an.';

  @override
  String get landingSelectDeviceFirst =>
      'Wählen Sie zuerst ein Gerät aus oder fügen Sie eines hinzu, bevor Sie sich anmelden.';

  @override
  String get landingLoginFormError =>
      'Geben Sie Benutzername und Passwort ein.';

  @override
  String get landingDeviceFormError =>
      'Geben Sie eine gültige IP-Adresse und einen gültigen Port ein.';

  @override
  String get landingNoActiveDevice => 'Kein Gerät ausgewählt';

  @override
  String landingConnectedAs(String username) {
    return 'Verbunden als $username.';
  }

  @override
  String get locationSettingsTitle => 'Standort-Einstellungen';

  @override
  String get getCurrentLocation => 'Aktuellen Standort abrufen';

  @override
  String get errorFetchingLocation =>
      'Standort konnte nicht abgerufen werden. GPS und Berechtigungen prüfen.';

  @override
  String get locationSaved => 'Standort erfolgreich gespeichert.';

  @override
  String get locationConfig => 'Standort-Konfig';

  @override
  String get rainRadarZoomLabel => 'Zoom';

  @override
  String get rainRadarForecastHoursLabel => 'Vorhersagezeitraum';

  @override
  String get widgetNameDigitalClock => 'Digitale Uhr';

  @override
  String get digitalClockSettingsTitle => 'Uhr-Einstellungen';

  @override
  String get digitalClock24hLabel => '24-Stunden-Format verwenden';

  @override
  String get logout => 'Abmelden';

  @override
  String get dashboardUploadSuccess => 'Dashboard erfolgreich hochgeladen.';

  @override
  String get dashboardUploadError => 'Fehler beim Hochladen des Dashboards.';

  @override
  String get viewUploadSuccess => 'Layout erfolgreich hochgeladen.';

  @override
  String get viewUploadError => 'Fehler beim Hochladen des Layouts.';

  @override
  String get conflictDialogTitle => 'Sitzungskonflikt';

  @override
  String get conflictDialogMessage =>
      'Eine andere App hat sich mit demselben Benutzer angemeldet. Die Verbindung wurde getrennt.';

  @override
  String get dashboardUpdatedNotification =>
      'Dashboard automatisch aktualisiert';

  @override
  String get viewUpdatedNotification =>
      'Ansichtslayout automatisch aktualisiert';
}
