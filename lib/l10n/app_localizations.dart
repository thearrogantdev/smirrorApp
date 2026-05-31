import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Control'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @navViewLayout.
  ///
  /// In en, this message translates to:
  /// **'View Layout'**
  String get navViewLayout;

  /// No description provided for @guestView.
  ///
  /// In en, this message translates to:
  /// **'guest-view'**
  String get guestView;

  /// No description provided for @navHaDashboard.
  ///
  /// In en, this message translates to:
  /// **'HA Dashboard'**
  String get navHaDashboard;

  /// No description provided for @addWidget.
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get addWidget;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get categoryWeather;

  /// No description provided for @categoryCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get categoryCalendar;

  /// No description provided for @categoryTransit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get categoryTransit;

  /// No description provided for @categorySmartHome.
  ///
  /// In en, this message translates to:
  /// **'Smart Home'**
  String get categorySmartHome;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @biometricsFaceUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'The connected device does not support face recognition'**
  String get biometricsFaceUnavailableTooltip;

  /// No description provided for @biometricsFingerprintUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'The connected device does not support fingerprint reading'**
  String get biometricsFingerprintUnavailableTooltip;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setup;

  /// No description provided for @screenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get screenshot;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @addPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Page'**
  String get addPageTooltip;

  /// No description provided for @deletePageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Page'**
  String get deletePageTooltip;

  /// No description provided for @deletePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Page'**
  String get deletePageTitle;

  /// No description provided for @deletePageContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this page? This action cannot be undone.'**
  String get deletePageContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @pageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {current} / {total}'**
  String pageLabel(Object current, Object total);

  /// No description provided for @pageTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageTabLabel(Object number);

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsLabel;

  /// No description provided for @unitsMetricCelsius.
  ///
  /// In en, this message translates to:
  /// **'metric (°C)'**
  String get unitsMetricCelsius;

  /// No description provided for @unitsImperialFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'imperial (°F)'**
  String get unitsImperialFahrenheit;

  /// No description provided for @unitsStandardKelvin.
  ///
  /// In en, this message translates to:
  /// **'standard (K)'**
  String get unitsStandardKelvin;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @apiKeyMissingShort.
  ///
  /// In en, this message translates to:
  /// **'No API key configured (check settings).'**
  String get apiKeyMissingShort;

  /// No description provided for @weatherPanelSummary.
  ///
  /// In en, this message translates to:
  /// **'Weather: {city}\nUnits: {units}'**
  String weatherPanelSummary(Object city, Object units);

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API key required.'**
  String get apiKeyRequired;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City required.'**
  String get cityRequired;

  /// No description provided for @apiErrorInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key.'**
  String get apiErrorInvalidKey;

  /// No description provided for @apiErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Rate limited. Try again later.'**
  String get apiErrorRateLimited;

  /// No description provided for @apiErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get apiErrorNetwork;

  /// No description provided for @apiErrorGenericKeyValidation.
  ///
  /// In en, this message translates to:
  /// **'Could not validate API key.'**
  String get apiErrorGenericKeyValidation;

  /// No description provided for @cityNotFound.
  ///
  /// In en, this message translates to:
  /// **'City not found.'**
  String get cityNotFound;

  /// No description provided for @openWeatherSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenWeather Settings'**
  String get openWeatherSettingsTitle;

  /// No description provided for @widgetNameOpenWeatherCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get widgetNameOpenWeatherCurrent;

  /// No description provided for @widgetNameOpenWeatherForecast.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get widgetNameOpenWeatherForecast;

  /// No description provided for @widgetNameTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Text Label'**
  String get widgetNameTextLabel;

  /// No description provided for @widgetNameImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get widgetNameImage;

  /// No description provided for @widgetNameRainRadar.
  ///
  /// In en, this message translates to:
  /// **'Rain Radar'**
  String get widgetNameRainRadar;

  /// No description provided for @rainRadarSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain Radar Settings'**
  String get rainRadarSettingsTitle;

  /// No description provided for @googleCalendarSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar Settings'**
  String get googleCalendarSettingsTitle;

  /// No description provided for @googleAuthorizeButton.
  ///
  /// In en, this message translates to:
  /// **'Authorize Google'**
  String get googleAuthorizeButton;

  /// No description provided for @googleAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please authorize Google to continue.'**
  String get googleAuthRequired;

  /// No description provided for @googleAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authorization failed. Please try again.'**
  String get googleAuthFailed;

  /// No description provided for @googleErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or revoked token. Please log in again.'**
  String get googleErrorInvalid;

  /// No description provided for @googleErrorScopes.
  ///
  /// In en, this message translates to:
  /// **'Permissions missing. Please grant access to your calendar.'**
  String get googleErrorScopes;

  /// No description provided for @googleErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach Google to validate token.'**
  String get googleErrorNetwork;

  /// No description provided for @googleConnected.
  ///
  /// In en, this message translates to:
  /// **'Google is connected'**
  String get googleConnected;

  /// No description provided for @googleNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Google is not connected'**
  String get googleNotConnected;

  /// No description provided for @googleCalendarIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar ID'**
  String get googleCalendarIdLabel;

  /// No description provided for @googleMaxResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max results'**
  String get googleMaxResultsLabel;

  /// No description provided for @googleMaxResultsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get googleMaxResultsInvalid;

  /// No description provided for @widgetNameGoogleCalendarUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar Upcoming'**
  String get widgetNameGoogleCalendarUpcoming;

  /// No description provided for @widgetNameGoogleCalendarNextTwoDay.
  ///
  /// In en, this message translates to:
  /// **'Two days'**
  String get widgetNameGoogleCalendarNextTwoDay;

  /// No description provided for @googleCalendarMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Google token missing (open settings)'**
  String get googleCalendarMissingToken;

  /// No description provided for @googleCalendarReady.
  ///
  /// In en, this message translates to:
  /// **'Google upcoming with'**
  String get googleCalendarReady;

  /// No description provided for @googleCalendarNextTwoDays.
  ///
  /// In en, this message translates to:
  /// **'Google next two days with'**
  String get googleCalendarNextTwoDays;

  /// No description provided for @maxResults.
  ///
  /// In en, this message translates to:
  /// **'Max results: {count}'**
  String maxResults(int count);

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @configGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get configGestures;

  /// No description provided for @homeAssistantMap.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant Map'**
  String get homeAssistantMap;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @haDisableSnapping.
  ///
  /// In en, this message translates to:
  /// **'Disable grid snapping'**
  String get haDisableSnapping;

  /// No description provided for @haEnableSnapping.
  ///
  /// In en, this message translates to:
  /// **'Enable grid snapping'**
  String get haEnableSnapping;

  /// No description provided for @haRenameDashboard.
  ///
  /// In en, this message translates to:
  /// **'Rename current dashboard'**
  String get haRenameDashboard;

  /// No description provided for @haAddDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create a new dashboard'**
  String get haAddDashboard;

  /// No description provided for @haDeleteDashboard.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this dashboard'**
  String get haDeleteDashboard;

  /// No description provided for @haSwitchDashboard.
  ///
  /// In en, this message translates to:
  /// **'Switch between your dashboards'**
  String get haSwitchDashboard;

  /// No description provided for @haRefreshStates.
  ///
  /// In en, this message translates to:
  /// **'Refresh Home Assistant live states'**
  String get haRefreshStates;

  /// No description provided for @haEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Long press to add your first entity'**
  String get haEmptyHint;

  /// No description provided for @haDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Dashboard'**
  String get haDeleteConfirmTitle;

  /// No description provided for @haDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'? This will permanently remove all items on this dashboard.'**
  String haDeleteConfirmContent(String name);

  /// No description provided for @haConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant Configuration'**
  String get haConfigTitle;

  /// No description provided for @haTokenError.
  ///
  /// In en, this message translates to:
  /// **'Token Error'**
  String get haTokenError;

  /// No description provided for @haUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get haUnreachable;

  /// No description provided for @haConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get haConnectionFailed;

  /// No description provided for @haRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get haRetry;

  /// No description provided for @haConfigureConnection.
  ///
  /// In en, this message translates to:
  /// **'Configure Connection'**
  String get haConfigureConnection;

  /// No description provided for @haTokenErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant token is missing or expired. Please check your backend connection.'**
  String get haTokenErrorMessage;

  /// No description provided for @haUnreachableMessage.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant URL is incorrect or the server is down.'**
  String get haUnreachableMessage;

  /// No description provided for @haNewDashboard.
  ///
  /// In en, this message translates to:
  /// **'New Dashboard'**
  String get haNewDashboard;

  /// No description provided for @haRenameDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Dashboard'**
  String get haRenameDashboardTitle;

  /// No description provided for @haDashboardNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get haDashboardNameField;

  /// No description provided for @haConfigUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get haConfigUrlLabel;

  /// No description provided for @haConfigUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://ip:port'**
  String get haConfigUrlHint;

  /// No description provided for @haConfigTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Long-Lived Access Token'**
  String get haConfigTokenLabel;

  /// No description provided for @haConfigTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get haConfigTest;

  /// No description provided for @haConfigSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection Successful!'**
  String get haConfigSuccess;

  /// No description provided for @haConfigInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get haConfigInvalidUrl;

  /// No description provided for @haConfigRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get haConfigRequiredField;

  /// No description provided for @widgetNameHASingleDashboard.
  ///
  /// In en, this message translates to:
  /// **'SingleDashboard'**
  String get widgetNameHASingleDashboard;

  /// No description provided for @haSelectDashboard.
  ///
  /// In en, this message translates to:
  /// **'Select Dashboard'**
  String get haSelectDashboard;

  /// No description provided for @haNoDashboardsFound.
  ///
  /// In en, this message translates to:
  /// **'No dashboards found for this user. Create one in the HA Map settings first.'**
  String get haNoDashboardsFound;

  /// No description provided for @haSearchEntities.
  ///
  /// In en, this message translates to:
  /// **'Search entities...'**
  String get haSearchEntities;

  /// No description provided for @haFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get haFilterAll;

  /// No description provided for @haFilterBool.
  ///
  /// In en, this message translates to:
  /// **'Boolean'**
  String get haFilterBool;

  /// No description provided for @haFilterNumeric.
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get haFilterNumeric;

  /// No description provided for @haFilterOnlyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Only Available'**
  String get haFilterOnlyAvailable;

  /// No description provided for @haStateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get haStateUnavailable;

  /// No description provided for @haFilterString.
  ///
  /// In en, this message translates to:
  /// **'Text/Status'**
  String get haFilterString;

  /// No description provided for @haDeleteSymbol.
  ///
  /// In en, this message translates to:
  /// **'Delete Symbol'**
  String get haDeleteSymbol;

  /// No description provided for @haDeleteSymbolConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this symbol?'**
  String get haDeleteSymbolConfirm;

  /// No description provided for @haConfigNoLocalError.
  ///
  /// In en, this message translates to:
  /// **'Addresses ending in \'.local\' are not supported'**
  String get haConfigNoLocalError;

  /// No description provided for @widgetNameCataasImage.
  ///
  /// In en, this message translates to:
  /// **'Random Cat Image'**
  String get widgetNameCataasImage;

  /// No description provided for @widgetNameCataasGif.
  ///
  /// In en, this message translates to:
  /// **'Random Cat GIF'**
  String get widgetNameCataasGif;

  /// No description provided for @widgetNameRandomDog.
  ///
  /// In en, this message translates to:
  /// **'Random Dog Image'**
  String get widgetNameRandomDog;

  /// No description provided for @widgetNamePokemonOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Pokémon des Tages'**
  String get widgetNamePokemonOfTheDay;

  /// No description provided for @widgetNameRandomPokemon.
  ///
  /// In en, this message translates to:
  /// **'Zufälliges Pokémon'**
  String get widgetNameRandomPokemon;

  /// No description provided for @widgetNameRandomCompliment.
  ///
  /// In en, this message translates to:
  /// **'Random Compliment'**
  String get widgetNameRandomCompliment;

  /// No description provided for @widgetNameRandomInsult.
  ///
  /// In en, this message translates to:
  /// **'Random Insult'**
  String get widgetNameRandomInsult;

  /// No description provided for @widgetNameRandomUselessFact.
  ///
  /// In en, this message translates to:
  /// **'Random Useless Fact'**
  String get widgetNameRandomUselessFact;

  /// No description provided for @randomInsultAllow18Plus.
  ///
  /// In en, this message translates to:
  /// **'Allow 18+ insults'**
  String get randomInsultAllow18Plus;

  /// No description provided for @editWidgetProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit Widget Style'**
  String get editWidgetProperties;

  /// No description provided for @widgetNameHAMultiDashboard.
  ///
  /// In en, this message translates to:
  /// **'Multi-Dashboard'**
  String get widgetNameHAMultiDashboard;

  /// No description provided for @haSelectDashboards.
  ///
  /// In en, this message translates to:
  /// **'Configure Dashboards'**
  String get haSelectDashboards;

  /// No description provided for @haAvailableDashboards.
  ///
  /// In en, this message translates to:
  /// **'Select dashboards to include'**
  String get haAvailableDashboards;

  /// No description provided for @widgetNameBusStop.
  ///
  /// In en, this message translates to:
  /// **'Bus Stop'**
  String get widgetNameBusStop;

  /// No description provided for @widgetNameSystemUsage.
  ///
  /// In en, this message translates to:
  /// **'System Usage'**
  String get widgetNameSystemUsage;

  /// No description provided for @haConfigureBusStop.
  ///
  /// In en, this message translates to:
  /// **'Configure Bus Stop'**
  String get haConfigureBusStop;

  /// No description provided for @haBusLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get haBusLine;

  /// No description provided for @haDepartures.
  ///
  /// In en, this message translates to:
  /// **'Departures'**
  String get haDepartures;

  /// No description provided for @haAddBusLine.
  ///
  /// In en, this message translates to:
  /// **'Add Line'**
  String get haAddBusLine;

  /// No description provided for @haLineNumber.
  ///
  /// In en, this message translates to:
  /// **'Line Number'**
  String get haLineNumber;

  /// No description provided for @haAddDeparture.
  ///
  /// In en, this message translates to:
  /// **'Add Departure'**
  String get haAddDeparture;

  /// No description provided for @haEditBusLine.
  ///
  /// In en, this message translates to:
  /// **'Edit Line'**
  String get haEditBusLine;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @textInput.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textInput;

  /// No description provided for @adminScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminScreenTitle;

  /// No description provided for @adminCreateUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get adminCreateUserTitle;

  /// No description provided for @adminFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminFieldUsername;

  /// No description provided for @adminFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminFieldPassword;

  /// No description provided for @adminFieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get adminFieldConfirmPassword;

  /// No description provided for @adminCreateUserButton.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get adminCreateUserButton;

  /// No description provided for @adminValidatorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get adminValidatorPasswordMismatch;

  /// No description provided for @adminUserCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'User created successfully.'**
  String get adminUserCreateSuccess;

  /// No description provided for @adminTokenAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Token added successfully.'**
  String get adminTokenAddSuccess;

  /// No description provided for @validatorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validatorRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorConfigError.
  ///
  /// In en, this message translates to:
  /// **'Configuration error.'**
  String get errorConfigError;

  /// No description provided for @errorInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid message.'**
  String get errorInvalidMessage;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get errorUnknown;

  /// No description provided for @errorAddToken.
  ///
  /// In en, this message translates to:
  /// **'Token addition failed.'**
  String get errorAddToken;

  /// No description provided for @errorFaceTrainingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Face training successful.'**
  String get errorFaceTrainingSuccess;

  /// No description provided for @errorFaceTrainingFailed.
  ///
  /// In en, this message translates to:
  /// **'Face training failed.'**
  String get errorFaceTrainingFailed;

  /// No description provided for @errorAddCreateUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'User created successfully.'**
  String get errorAddCreateUserSuccess;

  /// No description provided for @errorAddCreateUserFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create user.'**
  String get errorAddCreateUserFailed;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized action.'**
  String get errorUnauthorized;

  /// No description provided for @errorServiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Service not available.'**
  String get errorServiceNotAvailable;

  /// No description provided for @errorFrontendUpdated.
  ///
  /// In en, this message translates to:
  /// **'Frontend successfully updated.'**
  String get errorFrontendUpdated;

  /// No description provided for @errorBackendUpdated.
  ///
  /// In en, this message translates to:
  /// **'Backend successfully updated.'**
  String get errorBackendUpdated;

  /// No description provided for @errorUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed.'**
  String get errorUpdateFailed;

  /// No description provided for @adminDeviceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get adminDeviceSettingsTitle;

  /// No description provided for @adminDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get adminDeviceName;

  /// No description provided for @adminAutoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Auto Switch'**
  String get adminAutoSwitch;

  /// No description provided for @adminAutoSwitchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Automatically switches users via FaceID, otherwise defaults to Guest. Recommended only with an active camera. Can also be used to auto-logout.'**
  String get adminAutoSwitchTooltip;

  /// No description provided for @adminApplySettings.
  ///
  /// In en, this message translates to:
  /// **'Apply Settings'**
  String get adminApplySettings;

  /// No description provided for @adminSettingsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device settings updated.'**
  String get adminSettingsSuccess;

  /// No description provided for @adminUpdateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get adminUpdateSectionTitle;

  /// No description provided for @adminCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get adminCheckForUpdates;

  /// No description provided for @adminUpdatesNotChecked.
  ///
  /// In en, this message translates to:
  /// **'No update check has been performed yet.'**
  String get adminUpdatesNotChecked;

  /// No description provided for @adminNoUpdatesFound.
  ///
  /// In en, this message translates to:
  /// **'No new updates are available.'**
  String get adminNoUpdatesFound;

  /// No description provided for @adminNoUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No update available'**
  String get adminNoUpdatesAvailable;

  /// No description provided for @adminFrontendUpdate.
  ///
  /// In en, this message translates to:
  /// **'Frontend'**
  String get adminFrontendUpdate;

  /// No description provided for @adminBackendUpdate.
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get adminBackendUpdate;

  /// No description provided for @adminTomlUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'TOML configuration'**
  String get adminTomlUploadTitle;

  /// No description provided for @adminTomlUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a TOML file from your device and send its content to the backend.'**
  String get adminTomlUploadDescription;

  /// No description provided for @adminTomlChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose TOML file'**
  String get adminTomlChooseFile;

  /// No description provided for @adminTomlNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No TOML file selected yet.'**
  String get adminTomlNoFileSelected;

  /// No description provided for @adminTomlSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected file: {fileName}'**
  String adminTomlSelectedFile(String fileName);

  /// No description provided for @adminTomlUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload config'**
  String get adminTomlUploadButton;

  /// No description provided for @adminTomlReadError.
  ///
  /// In en, this message translates to:
  /// **'The selected TOML file could not be read.'**
  String get adminTomlReadError;

  /// No description provided for @adminTomlUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration uploaded successfully.'**
  String get adminTomlUploadSuccess;

  /// No description provided for @adminTomlUploadError.
  ///
  /// In en, this message translates to:
  /// **'The TOML configuration is invalid.'**
  String get adminTomlUploadError;

  /// No description provided for @adminTomlUploadErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'The TOML configuration is invalid: {message}'**
  String adminTomlUploadErrorWithMessage(String message);

  /// No description provided for @adminTomlRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart smirror?'**
  String get adminTomlRestartTitle;

  /// No description provided for @adminTomlRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'The new configuration was saved. Restarting smirror is recommended. Do you want to restart now?'**
  String get adminTomlRestartMessage;

  /// No description provided for @adminTomlRestartYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get adminTomlRestartYes;

  /// No description provided for @syncAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get syncAvailableTitle;

  /// No description provided for @syncAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A newer view configuration is available from the connected device. Do you want to update?'**
  String get syncAvailableMessage;

  /// No description provided for @welcomeUpdateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Device update available'**
  String get welcomeUpdateAvailableTitle;

  /// No description provided for @welcomeFrontendUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A frontend update is available: {version}'**
  String welcomeFrontendUpdateAvailable(String version);

  /// No description provided for @welcomeBackendUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A backend update is available: {version}'**
  String welcomeBackendUpdateAvailable(String version);

  /// No description provided for @welcomeUpdateAvailableAction.
  ///
  /// In en, this message translates to:
  /// **'Please switch to the admin account and update the device.'**
  String get welcomeUpdateAvailableAction;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateAll.
  ///
  /// In en, this message translates to:
  /// **'Update All'**
  String get updateAll;

  /// No description provided for @haNoDashboards.
  ///
  /// In en, this message translates to:
  /// **'No dashboards yet. Create one to get started.'**
  String get haNoDashboards;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get adminNoUsers;

  /// No description provided for @adminColumnUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminColumnUser;

  /// No description provided for @adminDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminDeleteUser;

  /// No description provided for @adminDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete user?'**
  String get adminDeleteConfirmTitle;

  /// No description provided for @adminDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'User \"{name}\" will be permanently deleted. This action cannot be undone.'**
  String adminDeleteConfirmMessage(String name);

  /// No description provided for @adminDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDeleteConfirmButton;

  /// No description provided for @adminTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'API Tokens'**
  String get adminTokenTitle;

  /// No description provided for @adminTokenMissingWarning.
  ///
  /// In en, this message translates to:
  /// **'Token for {provider} is missing. Please add it in the Admin Settings.'**
  String adminTokenMissingWarning(String provider);

  /// No description provided for @adminTokenPresent.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get adminTokenPresent;

  /// No description provided for @adminTokenAbsent.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get adminTokenAbsent;

  /// No description provided for @adminTokenAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Token'**
  String get adminTokenAdd;

  /// No description provided for @adminTokenDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Token'**
  String get adminTokenDelete;

  /// No description provided for @adminTokenDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Token?'**
  String get adminTokenDeleteConfirmTitle;

  /// No description provided for @adminTokenDeleteConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this token? This cannot be undone.'**
  String get adminTokenDeleteConfirmText;

  /// No description provided for @adminTokenDeleteConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get adminTokenDeleteConfirmYes;

  /// No description provided for @adminTokenDeleteConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminTokenDeleteConfirmNo;

  /// No description provided for @adminTokenAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get adminTokenAuthorize;

  /// No description provided for @adminEditTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Token: {provider}'**
  String adminEditTokenTitle(String provider);

  /// No description provided for @adminEditTokenSave.
  ///
  /// In en, this message translates to:
  /// **'Save Token'**
  String get adminEditTokenSave;

  /// No description provided for @adminGoogleManualConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Mirror backend has no Google Client ID. Enter manually:'**
  String get adminGoogleManualConfigTitle;

  /// No description provided for @adminGoogleClientId.
  ///
  /// In en, this message translates to:
  /// **'Google Client ID'**
  String get adminGoogleClientId;

  /// No description provided for @adminGoogleClientSecret.
  ///
  /// In en, this message translates to:
  /// **'Google Client Secret (Optional)'**
  String get adminGoogleClientSecret;

  /// No description provided for @adminGoogleApplyLocal.
  ///
  /// In en, this message translates to:
  /// **'Apply Credentials Locally'**
  String get adminGoogleApplyLocal;

  /// No description provided for @adminDeleteProtectedGuest.
  ///
  /// In en, this message translates to:
  /// **'The guest account cannot be deleted.'**
  String get adminDeleteProtectedGuest;

  /// No description provided for @adminDeleteProtectedAdmin.
  ///
  /// In en, this message translates to:
  /// **'The admin account cannot be deleted.'**
  String get adminDeleteProtectedAdmin;

  /// No description provided for @adminRightsProtectedGuest.
  ///
  /// In en, this message translates to:
  /// **'The guest account cannot have any rights for safety reasons.'**
  String get adminRightsProtectedGuest;

  /// No description provided for @adminRightsProtectedAdmin.
  ///
  /// In en, this message translates to:
  /// **'The admin account always has all rights.'**
  String get adminRightsProtectedAdmin;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @biometricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometrics & Security'**
  String get biometricsTitle;

  /// No description provided for @biometricsUserEnrollment.
  ///
  /// In en, this message translates to:
  /// **'User Enrollment'**
  String get biometricsUserEnrollment;

  /// No description provided for @biometricsFaceRecognition.
  ///
  /// In en, this message translates to:
  /// **'Face Recognition'**
  String get biometricsFaceRecognition;

  /// No description provided for @biometricsFaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register facial data for current user'**
  String get biometricsFaceSubtitle;

  /// No description provided for @biometricsTrainFace.
  ///
  /// In en, this message translates to:
  /// **'Train Face'**
  String get biometricsTrainFace;

  /// No description provided for @biometricsFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometricsFingerprint;

  /// No description provided for @biometricsFingerprintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register fingerprint for current user'**
  String get biometricsFingerprintSubtitle;

  /// No description provided for @biometricsTrainFinger.
  ///
  /// In en, this message translates to:
  /// **'Train Finger'**
  String get biometricsTrainFinger;

  /// No description provided for @biometricsFaceTrainingStart.
  ///
  /// In en, this message translates to:
  /// **'Starting Face Training...'**
  String get biometricsFaceTrainingStart;

  /// No description provided for @biometricsFingerprintStart.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint training requested (waiting for backend).'**
  String get biometricsFingerprintStart;

  /// No description provided for @deviceConnection.
  ///
  /// In en, this message translates to:
  /// **'Device Connection'**
  String get deviceConnection;

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current User'**
  String get currentUser;

  /// No description provided for @changeUser.
  ///
  /// In en, this message translates to:
  /// **'Change User'**
  String get changeUser;

  /// No description provided for @changeUserLogin.
  ///
  /// In en, this message translates to:
  /// **'Change User Login'**
  String get changeUserLogin;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @loginErrorCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please check your username or password.'**
  String get loginErrorCredentials;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Please try again.'**
  String get loginErrorNetwork;

  /// No description provided for @setupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get setupAppearance;

  /// No description provided for @setupSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get setupSystem;

  /// No description provided for @setupThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get setupThemeLight;

  /// No description provided for @setupThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get setupThemeDark;

  /// No description provided for @setupThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get setupThemeSystem;

  /// No description provided for @logNoLogsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get logNoLogsAvailable;

  /// No description provided for @logTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get logTime;

  /// No description provided for @logLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get logLevel;

  /// No description provided for @logMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get logMessage;

  /// No description provided for @logRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Logs'**
  String get logRefresh;

  /// No description provided for @homeControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get homeControlsTitle;

  /// No description provided for @homeWaitingForStatus.
  ///
  /// In en, this message translates to:
  /// **'Waiting for status...'**
  String get homeWaitingForStatus;

  /// No description provided for @haConfigEntityTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure {entityId}'**
  String haConfigEntityTitle(Object entityId);

  /// No description provided for @haConfigStandardStyle.
  ///
  /// In en, this message translates to:
  /// **'Standard Style (Base/Off State)'**
  String get haConfigStandardStyle;

  /// No description provided for @haConfigDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get haConfigDisplayName;

  /// No description provided for @haConfigTriggerValue.
  ///
  /// In en, this message translates to:
  /// **'Trigger Value (>=)'**
  String get haConfigTriggerValue;

  /// No description provided for @haEntityPickerError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String haEntityPickerError(Object error);

  /// No description provided for @haSelectBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Select Background Image'**
  String get haSelectBackgroundImage;

  /// No description provided for @haBusEditLine.
  ///
  /// In en, this message translates to:
  /// **'Edit Line {num}'**
  String haBusEditLine(Object num);

  /// No description provided for @haBusAutoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Auto-Generate'**
  String get haBusAutoGenerate;

  /// No description provided for @haBusLineNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Line Number'**
  String get haBusLineNumberLabel;

  /// No description provided for @haBusFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency (minutes)'**
  String get haBusFrequency;

  /// No description provided for @haBusGenerateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Generate Schedule'**
  String get haBusGenerateSchedule;

  /// No description provided for @haBusNoRanges.
  ///
  /// In en, this message translates to:
  /// **'No ranges added yet.'**
  String get haBusNoRanges;

  /// No description provided for @haBusTimeRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String haBusTimeRangeTitle(Object start, Object end);

  /// No description provided for @haBusTimeRangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every {freq} mins'**
  String haBusTimeRangeSubtitle(Object freq);

  /// No description provided for @haBusAddTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Add Time Range'**
  String get haBusAddTimeRange;

  /// No description provided for @haBusGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get haBusGenerate;

  /// No description provided for @haBusAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get haBusAdd;

  /// No description provided for @editTextLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Text Label'**
  String get editTextLabelTitle;

  /// No description provided for @editImagePickPhotos.
  ///
  /// In en, this message translates to:
  /// **'Pick Photos'**
  String get editImagePickPhotos;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @appBackendDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'App → Backend WebSocket Demo'**
  String get appBackendDemoTitle;

  /// No description provided for @homeWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get homeWakeUp;

  /// No description provided for @homeStandBy.
  ///
  /// In en, this message translates to:
  /// **'StandBy'**
  String get homeStandBy;

  /// No description provided for @homeActivateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate User'**
  String get homeActivateUser;

  /// No description provided for @homeActivateGuest.
  ///
  /// In en, this message translates to:
  /// **'Activate Guest'**
  String get homeActivateGuest;

  /// No description provided for @homeNextTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get homeNextTheme;

  /// No description provided for @homeSystemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get homeSystemStatus;

  /// No description provided for @homeFrontend.
  ///
  /// In en, this message translates to:
  /// **'Frontend'**
  String get homeFrontend;

  /// No description provided for @homeOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get homeOn;

  /// No description provided for @homeOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get homeOff;

  /// No description provided for @homeAutoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Auto Switch'**
  String get homeAutoSwitch;

  /// No description provided for @homeActiveUserStatus.
  ///
  /// In en, this message translates to:
  /// **'Active User'**
  String get homeActiveUserStatus;

  /// No description provided for @homeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get homeNone;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @noDevicesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No devices configured.'**
  String get noDevicesConfigured;

  /// No description provided for @testResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection Successful'**
  String get testResultSuccess;

  /// No description provided for @testResultUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Connected (Requires Login)'**
  String get testResultUnauthorized;

  /// No description provided for @testResultOutdated.
  ///
  /// In en, this message translates to:
  /// **'App version too old!'**
  String get testResultOutdated;

  /// No description provided for @testResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get testResultFailed;

  /// No description provided for @upgradeRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'App Update Required'**
  String get upgradeRequiredTitle;

  /// No description provided for @upgradeRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The connected device requires a newer version of this app. Please update the app to continue.'**
  String get upgradeRequiredMessage;

  /// No description provided for @setupDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get setupDangerZone;

  /// No description provided for @setupFactoryReset.
  ///
  /// In en, this message translates to:
  /// **'Factory Reset'**
  String get setupFactoryReset;

  /// No description provided for @setupFactoryResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory Reset'**
  String get setupFactoryResetConfirmTitle;

  /// No description provided for @setupFactoryResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to completely reset the app? All local data, dashboards, and settings will be permanently deleted. This action cannot be undone.'**
  String get setupFactoryResetConfirmMessage;

  /// No description provided for @logThreadId.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get logThreadId;

  /// No description provided for @logSourceLocation.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get logSourceLocation;

  /// No description provided for @setupVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String setupVersion(String version);

  /// No description provided for @developerModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Developer mode enabled'**
  String get developerModeEnabled;

  /// No description provided for @developerModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Developer mode disabled'**
  String get developerModeDisabled;

  /// No description provided for @developerMode.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get developerMode;

  /// No description provided for @emulateHomeAssistant.
  ///
  /// In en, this message translates to:
  /// **'Emulate Home Assistant'**
  String get emulateHomeAssistant;

  /// No description provided for @emulatedConnection.
  ///
  /// In en, this message translates to:
  /// **'Emulated Connection'**
  String get emulatedConnection;

  /// No description provided for @developerLogs.
  ///
  /// In en, this message translates to:
  /// **'Developer Logs'**
  String get developerLogs;

  /// No description provided for @viewSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'View Settings'**
  String get viewSettingsTitle;

  /// No description provided for @viewMetadataTooltip.
  ///
  /// In en, this message translates to:
  /// **'View Metadata'**
  String get viewMetadataTooltip;

  /// No description provided for @viewLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get viewLanguageLabel;

  /// No description provided for @viewThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get viewThemeLabel;

  /// No description provided for @themeBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get themeBlue;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @setupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial Device Setup'**
  String get setupDialogTitle;

  /// No description provided for @setupDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Please configure your new device. Change the default name and set a secure admin password.'**
  String get setupDialogDescription;

  /// No description provided for @setupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Device successfully configured!'**
  String get setupSuccessMessage;

  /// No description provided for @setupErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update settings. Please try again.'**
  String get setupErrorMessage;

  /// No description provided for @setupAdminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Admin Password'**
  String get setupAdminPasswordLabel;

  /// No description provided for @setupAdminPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get setupAdminPasswordConfirmLabel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangeSuccess;

  /// No description provided for @passwordChangeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password.'**
  String get passwordChangeError;

  /// No description provided for @homeLedControl.
  ///
  /// In en, this message translates to:
  /// **'LED Control'**
  String get homeLedControl;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @guestFallbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Logged in as Guest. Your stored credentials might be outdated or the password was changed.'**
  String get guestFallbackMessage;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your device'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a device, connect to it, and sign in with the user data stored on that device before entering the app.'**
  String get landingSubtitle;

  /// No description provided for @landingDeviceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Connect to a device'**
  String get landingDeviceSectionTitle;

  /// No description provided for @landingDeviceSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a saved device or add a new one with its IP address and port.'**
  String get landingDeviceSectionSubtitle;

  /// No description provided for @landingLoginSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Sign in for this device'**
  String get landingLoginSectionTitle;

  /// No description provided for @landingLoginSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the credentials that belong to the selected device.'**
  String get landingLoginSectionSubtitle;

  /// No description provided for @landingNoConnectionPossible.
  ///
  /// In en, this message translates to:
  /// **'No connection to this device is possible right now. Check the device, network, IP address, and port.'**
  String get landingNoConnectionPossible;

  /// No description provided for @landingWrongCredentialsForDevice.
  ///
  /// In en, this message translates to:
  /// **'The saved credentials are wrong for this device. Please sign in again with the correct user data.'**
  String get landingWrongCredentialsForDevice;

  /// No description provided for @landingSelectDeviceFirst.
  ///
  /// In en, this message translates to:
  /// **'Select or add a device before you sign in.'**
  String get landingSelectDeviceFirst;

  /// No description provided for @landingLoginFormError.
  ///
  /// In en, this message translates to:
  /// **'Enter both username and password.'**
  String get landingLoginFormError;

  /// No description provided for @landingDeviceFormError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IP address and port.'**
  String get landingDeviceFormError;

  /// No description provided for @landingNoActiveDevice.
  ///
  /// In en, this message translates to:
  /// **'No device selected'**
  String get landingNoActiveDevice;

  /// No description provided for @landingConnectedAs.
  ///
  /// In en, this message translates to:
  /// **'Connected as {username}.'**
  String landingConnectedAs(String username);

  /// No description provided for @locationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get locationSettingsTitle;

  /// No description provided for @getCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get getCurrentLocation;

  /// No description provided for @errorFetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch current location. Make sure GPS is enabled and permissions are granted.'**
  String get errorFetchingLocation;

  /// No description provided for @locationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved successfully.'**
  String get locationSaved;

  /// No description provided for @locationConfig.
  ///
  /// In en, this message translates to:
  /// **'Location Config'**
  String get locationConfig;

  /// No description provided for @rainRadarZoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get rainRadarZoomLabel;

  /// No description provided for @rainRadarForecastHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Forecast horizon'**
  String get rainRadarForecastHoursLabel;

  /// No description provided for @widgetNameDigitalClock.
  ///
  /// In en, this message translates to:
  /// **'Digital Clock'**
  String get widgetNameDigitalClock;

  /// No description provided for @digitalClockSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Clock Settings'**
  String get digitalClockSettingsTitle;

  /// No description provided for @digitalClock24hLabel.
  ///
  /// In en, this message translates to:
  /// **'Use 24-hour format'**
  String get digitalClock24hLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
