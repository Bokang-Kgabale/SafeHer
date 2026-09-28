import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_en.dart';
import 'app_localizations_st.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('af'),
    Locale('en'),
    Locale('st'),
    Locale('zu'),
  ];

  /// App name, shown as the OS task title and app-bar title.
  ///
  /// In en, this message translates to:
  /// **'SafeHer'**
  String get appTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SafeHer'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your companion for safer walks, smarter routes, and faster help when it matters.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk safer routes'**
  String get onboardingRouteTitle;

  /// No description provided for @onboardingRouteBody.
  ///
  /// In en, this message translates to:
  /// **'SafeHer checks reported hotspots along your path and suggests a route around them — and tells you plainly when it can\'t.'**
  String get onboardingRouteBody;

  /// No description provided for @onboardingReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report what you see'**
  String get onboardingReportTitle;

  /// No description provided for @onboardingReportBody.
  ///
  /// In en, this message translates to:
  /// **'Flag an unsafe spot for others in seconds — pick a category, add a photo, and pin exactly where you are.'**
  String get onboardingReportBody;

  /// No description provided for @onboardingPanicTitle.
  ///
  /// In en, this message translates to:
  /// **'Help, one tap away'**
  String get onboardingPanicTitle;

  /// No description provided for @onboardingPanicBody.
  ///
  /// In en, this message translates to:
  /// **'The panic button calls and messages your next of kin with your live location. It never contacts police on your behalf.'**
  String get onboardingPanicBody;

  /// No description provided for @onboardingGetStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready'**
  String get onboardingGetStartedTitle;

  /// No description provided for @onboardingGetStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Add a next-of-kin contact first, so the panic button has someone to reach.'**
  String get onboardingGetStartedBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @mapSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Map settings'**
  String get mapSettingsTooltip;

  /// No description provided for @nextOfKinTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next of kin'**
  String get nextOfKinTooltip;

  /// No description provided for @activityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTooltip;

  /// No description provided for @previewModeBanner.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW MODE — mock data, nothing here is real'**
  String get previewModeBanner;

  /// No description provided for @reportModeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a hotspot pin at that location'**
  String get reportModeHint;

  /// No description provided for @routePlanHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set a destination — routes onto real streets when online'**
  String get routePlanHint;

  /// No description provided for @routeOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'No network route available — this is a straight-line simulation, not real streets'**
  String get routeOfflineBanner;

  /// No description provided for @routeWarningDestinationInFlagged.
  ///
  /// In en, this message translates to:
  /// **'Your destination is inside a reported area — there is no route around that, take extra care on arrival.'**
  String get routeWarningDestinationInFlagged;

  /// No description provided for @routeWarningPassesThrough.
  ///
  /// In en, this message translates to:
  /// **'No reasonable detour avoids every flagged area on this route — extra caution advised.'**
  String get routeWarningPassesThrough;

  /// No description provided for @routeWarningGeneric.
  ///
  /// In en, this message translates to:
  /// **'This route passes near a reported area — extra caution advised.'**
  String get routeWarningGeneric;

  /// No description provided for @experimentalBanner.
  ///
  /// In en, this message translates to:
  /// **'EXPERIMENTAL ({features}) — unverified on real hardware, not an MVP feature'**
  String experimentalBanner(String features);

  /// No description provided for @hotspotPublishedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Hotspot published to the map.'**
  String get hotspotPublishedSnackbar;

  /// No description provided for @noNetworkRouteSnackbar.
  ///
  /// In en, this message translates to:
  /// **'No network route available — showing a straight-line simulation instead.'**
  String get noNetworkRouteSnackbar;

  /// No description provided for @hotspotSheetDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo control — stands in for a real GPS proximity crossing until native geofencing is wired in.'**
  String get hotspotSheetDemoNote;

  /// No description provided for @hotspotSheetSimulateButton.
  ///
  /// In en, this message translates to:
  /// **'Simulate entering this zone'**
  String get hotspotSheetSimulateButton;

  /// No description provided for @quickActionReportHotspot.
  ///
  /// In en, this message translates to:
  /// **'Report hotspot'**
  String get quickActionReportHotspot;

  /// No description provided for @quickActionReportHotspotTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin at that location'**
  String get quickActionReportHotspotTooltip;

  /// No description provided for @quickActionSafeRoute.
  ///
  /// In en, this message translates to:
  /// **'Safe route'**
  String get quickActionSafeRoute;

  /// No description provided for @quickActionSafeRouteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set a destination and plan a route'**
  String get quickActionSafeRouteTooltip;

  /// No description provided for @quickActionFallDetection.
  ///
  /// In en, this message translates to:
  /// **'Fall detection'**
  String get quickActionFallDetection;

  /// No description provided for @quickActionFallDetectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'EXPERIMENTAL — unverified on real hardware, not an MVP feature'**
  String get quickActionFallDetectionTooltip;

  /// No description provided for @quickActionVoiceTrigger.
  ///
  /// In en, this message translates to:
  /// **'Voice trigger'**
  String get quickActionVoiceTrigger;

  /// No description provided for @quickActionVoiceTriggerTooltip.
  ///
  /// In en, this message translates to:
  /// **'EXPERIMENTAL — listens for \"help\", not an MVP feature'**
  String get quickActionVoiceTriggerTooltip;

  /// No description provided for @mapSettingsHeader.
  ///
  /// In en, this message translates to:
  /// **'Map settings'**
  String get mapSettingsHeader;

  /// No description provided for @liveGpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live GPS'**
  String get liveGpsTitle;

  /// No description provided for @liveGpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off uses the simulated Preview position'**
  String get liveGpsSubtitle;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Crime heatmap'**
  String get heatmapTitle;

  /// No description provided for @heatmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Animated density overlay from the same hotspot pins'**
  String get heatmapSubtitle;

  /// No description provided for @alertStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert style'**
  String get alertStyleTitle;

  /// No description provided for @alertStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used by the geofence and fall-detection countdowns'**
  String get alertStyleSubtitle;

  /// No description provided for @alertStyleVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get alertStyleVibration;

  /// No description provided for @alertStyleRingtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get alertStyleRingtone;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which language SafeHer displays'**
  String get languageSubtitle;

  /// No description provided for @systemDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefaultLanguage;

  /// No description provided for @replayTourTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay welcome tour'**
  String get replayTourTitle;

  /// No description provided for @replayTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the first-run introduction again'**
  String get replayTourSubtitle;

  /// No description provided for @mapSettingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Report hotspot, safe route, fall detection, and voice trigger are on the main map screen\'s quick-actions bar.'**
  String get mapSettingsFooter;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied — staying on the simulated position.'**
  String get locationPermissionDenied;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition unavailable on this device.'**
  String get speechUnavailable;

  /// No description provided for @reportHotspotTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a hotspot'**
  String get reportHotspotTitle;

  /// No description provided for @reportHotspotDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This publishes immediately to the public map — no moderation gate before it appears.'**
  String get reportHotspotDisclaimer;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationPinnedSpot.
  ///
  /// In en, this message translates to:
  /// **'Pinned spot'**
  String get locationPinnedSpot;

  /// No description provided for @locationMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get locationMyLocation;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get photoLabel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t access the camera/gallery on this device.'**
  String get cameraUnavailable;

  /// No description provided for @publishToMap.
  ///
  /// In en, this message translates to:
  /// **'Publish to map'**
  String get publishToMap;

  /// No description provided for @categoryRobbery.
  ///
  /// In en, this message translates to:
  /// **'Robbery'**
  String get categoryRobbery;

  /// No description provided for @categoryHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get categoryHarassment;

  /// No description provided for @categoryAssault.
  ///
  /// In en, this message translates to:
  /// **'Assault'**
  String get categoryAssault;

  /// No description provided for @categoryNoLighting.
  ///
  /// In en, this message translates to:
  /// **'No lighting'**
  String get categoryNoLighting;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @panicButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'PANIC'**
  String get panicButtonLabel;

  /// No description provided for @noContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts configured'**
  String get noContactsTitle;

  /// No description provided for @noContactsBody.
  ///
  /// In en, this message translates to:
  /// **'The panic button can\'t reach anyone yet — you have no next-of-kin contacts set up. Add at least one before you rely on this in a real situation. This app does not contact police; it\'s next-of-kin only.'**
  String get noContactsBody;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add a contact'**
  String get addContact;

  /// No description provided for @confirmTriggerTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger panic alert?'**
  String get confirmTriggerTitle;

  /// No description provided for @confirmTriggerBody.
  ///
  /// In en, this message translates to:
  /// **'This calls and WhatsApps your next of kin ONLY, with your live location. It does not contact police or emergency services — if you\'re in danger and safely can, call them yourself too. (Preview Mode: simulated — nothing real is sent.)'**
  String get confirmTriggerBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @triggerNow.
  ///
  /// In en, this message translates to:
  /// **'Trigger now'**
  String get triggerNow;

  /// No description provided for @alertSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Alert sent to next of kin — see Activity for status. Police were not contacted.'**
  String get alertSentSnackbar;

  /// No description provided for @geofenceCountdownMessage.
  ///
  /// In en, this message translates to:
  /// **'You are near a reported hotspot. Alerting your next of kin (not police) in {seconds}s unless you confirm you are safe.'**
  String geofenceCountdownMessage(int seconds);

  /// No description provided for @falseAlarmButton.
  ///
  /// In en, this message translates to:
  /// **'False Alarm'**
  String get falseAlarmButton;

  /// No description provided for @fallCountdownMessage.
  ///
  /// In en, this message translates to:
  /// **'Possible fall detected. Alerting your next of kin (not police) in {seconds}s unless you confirm you\'re OK.'**
  String fallCountdownMessage(int seconds);

  /// No description provided for @imOkButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m OK'**
  String get imOkButton;

  /// No description provided for @nextOfKinTitle.
  ///
  /// In en, this message translates to:
  /// **'Next of kin'**
  String get nextOfKinTitle;

  /// No description provided for @noContactsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts yet'**
  String get noContactsYetTitle;

  /// No description provided for @noContactsYetBody.
  ///
  /// In en, this message translates to:
  /// **'The panic button escalates through this list — add at least one.'**
  String get noContactsYetBody;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @editContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContactTitle;

  /// No description provided for @addContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add next-of-kin contact'**
  String get addContactTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @relationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship (optional)'**
  String get relationshipLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addContactButton.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContactButton;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity (Preview)'**
  String get activityTitle;

  /// No description provided for @panicEventsHeader.
  ///
  /// In en, this message translates to:
  /// **'Panic events'**
  String get panicEventsHeader;

  /// No description provided for @noPanicEvents.
  ///
  /// In en, this message translates to:
  /// **'No panic events yet.'**
  String get noPanicEvents;

  /// No description provided for @dispatchTimelineHeader.
  ///
  /// In en, this message translates to:
  /// **'Simulated dispatch timeline'**
  String get dispatchTimelineHeader;

  /// No description provided for @dispatchTimelineNote.
  ///
  /// In en, this message translates to:
  /// **'Preview Mode never places a real call or WhatsApp message — this is what would have been sent.'**
  String get dispatchTimelineNote;

  /// No description provided for @noDispatchYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing dispatched yet.'**
  String get noDispatchYet;

  /// No description provided for @escalationStep.
  ///
  /// In en, this message translates to:
  /// **'escalation step {step}'**
  String escalationStep(int step);

  /// No description provided for @triggerManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get triggerManual;

  /// No description provided for @triggerVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice (\"help\")'**
  String get triggerVoice;

  /// No description provided for @triggerPowerButton.
  ///
  /// In en, this message translates to:
  /// **'Power button ×3'**
  String get triggerPowerButton;

  /// No description provided for @triggerFallDetection.
  ///
  /// In en, this message translates to:
  /// **'Fall detected'**
  String get triggerFallDetection;

  /// No description provided for @triggerGeofenceTimeout.
  ///
  /// In en, this message translates to:
  /// **'Geofence timeout'**
  String get triggerGeofenceTimeout;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False alarm'**
  String get statusFalseAlarm;

  /// No description provided for @statusUnresolved.
  ///
  /// In en, this message translates to:
  /// **'Unresolved'**
  String get statusUnresolved;

  /// No description provided for @statusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get statusEscalated;

  /// No description provided for @statusTriggered.
  ///
  /// In en, this message translates to:
  /// **'Triggered'**
  String get statusTriggered;

  /// No description provided for @statusAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get statusAcknowledged;
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
      <String>['af', 'en', 'st', 'zu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'en':
      return AppLocalizationsEn();
    case 'st':
      return AppLocalizationsSt();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
