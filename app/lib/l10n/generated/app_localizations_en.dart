// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SafeHer';

  @override
  String get onboardingWelcomeTitle => 'Welcome to SafeHer';

  @override
  String get onboardingWelcomeBody =>
      'Your companion for safer walks, smarter routes, and faster help when it matters.';

  @override
  String get onboardingRouteTitle => 'Walk safer routes';

  @override
  String get onboardingRouteBody =>
      'SafeHer checks reported hotspots along your path and suggests a route around them — and tells you plainly when it can\'t.';

  @override
  String get onboardingReportTitle => 'Report what you see';

  @override
  String get onboardingReportBody =>
      'Flag an unsafe spot for others in seconds — pick a category, add a photo, and pin exactly where you are.';

  @override
  String get onboardingPanicTitle => 'Help, one tap away';

  @override
  String get onboardingPanicBody =>
      'The panic button calls and messages your next of kin with your live location. It never contacts police on your behalf.';

  @override
  String get onboardingGetStartedTitle => 'You\'re ready';

  @override
  String get onboardingGetStartedBody =>
      'Add a next-of-kin contact first, so the panic button has someone to reach.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get mapSettingsTooltip => 'Map settings';

  @override
  String get nextOfKinTooltip => 'Next of kin';

  @override
  String get activityTooltip => 'Activity';

  @override
  String get previewModeBanner =>
      'PREVIEW MODE — mock data, nothing here is real';

  @override
  String get reportModeHint =>
      'Tap the map to drop a hotspot pin at that location';

  @override
  String get routePlanHint =>
      'Tap the map to set a destination — routes onto real streets when online';

  @override
  String get routeOfflineBanner =>
      'No network route available — this is a straight-line simulation, not real streets';

  @override
  String get routeWarningDestinationInFlagged =>
      'Your destination is inside a reported area — there is no route around that, take extra care on arrival.';

  @override
  String get routeWarningPassesThrough =>
      'No reasonable detour avoids every flagged area on this route — extra caution advised.';

  @override
  String get routeWarningGeneric =>
      'This route passes near a reported area — extra caution advised.';

  @override
  String experimentalBanner(String features) {
    return 'EXPERIMENTAL ($features) — unverified on real hardware, not an MVP feature';
  }

  @override
  String get hotspotPublishedSnackbar => 'Hotspot published to the map.';

  @override
  String get noNetworkRouteSnackbar =>
      'No network route available — showing a straight-line simulation instead.';

  @override
  String get hotspotSheetDemoNote =>
      'Demo control — stands in for a real GPS proximity crossing until native geofencing is wired in.';

  @override
  String get hotspotSheetSimulateButton => 'Simulate entering this zone';

  @override
  String get quickActionReportHotspot => 'Report hotspot';

  @override
  String get quickActionReportHotspotTooltip =>
      'Tap the map to drop a pin at that location';

  @override
  String get quickActionSafeRoute => 'Safe route';

  @override
  String get quickActionSafeRouteTooltip =>
      'Tap the map to set a destination and plan a route';

  @override
  String get quickActionFallDetection => 'Fall detection';

  @override
  String get quickActionFallDetectionTooltip =>
      'EXPERIMENTAL — unverified on real hardware, not an MVP feature';

  @override
  String get quickActionVoiceTrigger => 'Voice trigger';

  @override
  String get quickActionVoiceTriggerTooltip =>
      'EXPERIMENTAL — listens for \"help\", not an MVP feature';

  @override
  String get mapSettingsHeader => 'Map settings';

  @override
  String get liveGpsTitle => 'Live GPS';

  @override
  String get liveGpsSubtitle => 'Off uses the simulated Preview position';

  @override
  String get heatmapTitle => 'Crime heatmap';

  @override
  String get heatmapSubtitle =>
      'Animated density overlay from the same hotspot pins';

  @override
  String get alertStyleTitle => 'Alert style';

  @override
  String get alertStyleSubtitle =>
      'Used by the geofence and fall-detection countdowns';

  @override
  String get alertStyleVibration => 'Vibration';

  @override
  String get alertStyleRingtone => 'Ringtone';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose which language SafeHer displays';

  @override
  String get systemDefaultLanguage => 'System default';

  @override
  String get replayTourTitle => 'Replay welcome tour';

  @override
  String get replayTourSubtitle => 'Show the first-run introduction again';

  @override
  String get mapSettingsFooter =>
      'Report hotspot, safe route, fall detection, and voice trigger are on the main map screen\'s quick-actions bar.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied — staying on the simulated position.';

  @override
  String get speechUnavailable =>
      'Speech recognition unavailable on this device.';

  @override
  String get reportHotspotTitle => 'Report a hotspot';

  @override
  String get reportHotspotDisclaimer =>
      'This publishes immediately to the public map — no moderation gate before it appears.';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationPinnedSpot => 'Pinned spot';

  @override
  String get locationMyLocation => 'My location';

  @override
  String get categoryLabel => 'Category';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get photoLabel => 'Photo (optional)';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get cameraUnavailable =>
      'Couldn\'t access the camera/gallery on this device.';

  @override
  String get publishToMap => 'Publish to map';

  @override
  String get categoryRobbery => 'Robbery';

  @override
  String get categoryHarassment => 'Harassment';

  @override
  String get categoryAssault => 'Assault';

  @override
  String get categoryNoLighting => 'No lighting';

  @override
  String get categoryOther => 'Other';

  @override
  String get panicButtonLabel => 'PANIC';

  @override
  String get noContactsTitle => 'No emergency contacts configured';

  @override
  String get noContactsBody =>
      'The panic button can\'t reach anyone yet — you have no next-of-kin contacts set up. Add at least one before you rely on this in a real situation. This app does not contact police; it\'s next-of-kin only.';

  @override
  String get notNow => 'Not now';

  @override
  String get addContact => 'Add a contact';

  @override
  String get confirmTriggerTitle => 'Trigger panic alert?';

  @override
  String get confirmTriggerBody =>
      'This calls and WhatsApps your next of kin ONLY, with your live location. It does not contact police or emergency services — if you\'re in danger and safely can, call them yourself too. (Preview Mode: simulated — nothing real is sent.)';

  @override
  String get cancel => 'Cancel';

  @override
  String get triggerNow => 'Trigger now';

  @override
  String get alertSentSnackbar =>
      'Alert sent to next of kin — see Activity for status. Police were not contacted.';

  @override
  String geofenceCountdownMessage(int seconds) {
    return 'You are near a reported hotspot. Alerting your next of kin (not police) in ${seconds}s unless you confirm you are safe.';
  }

  @override
  String get falseAlarmButton => 'False Alarm';

  @override
  String fallCountdownMessage(int seconds) {
    return 'Possible fall detected. Alerting your next of kin (not police) in ${seconds}s unless you confirm you\'re OK.';
  }

  @override
  String get imOkButton => 'I\'m OK';

  @override
  String get nextOfKinTitle => 'Next of kin';

  @override
  String get noContactsYetTitle => 'No emergency contacts yet';

  @override
  String get noContactsYetBody =>
      'The panic button escalates through this list — add at least one.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get editContactTitle => 'Edit contact';

  @override
  String get addContactTitle => 'Add next-of-kin contact';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get relationshipLabel => 'Relationship (optional)';

  @override
  String get save => 'Save';

  @override
  String get addContactButton => 'Add contact';

  @override
  String get activityTitle => 'Activity (Preview)';

  @override
  String get panicEventsHeader => 'Panic events';

  @override
  String get noPanicEvents => 'No panic events yet.';

  @override
  String get dispatchTimelineHeader => 'Simulated dispatch timeline';

  @override
  String get dispatchTimelineNote =>
      'Preview Mode never places a real call or WhatsApp message — this is what would have been sent.';

  @override
  String get noDispatchYet => 'Nothing dispatched yet.';

  @override
  String escalationStep(int step) {
    return 'escalation step $step';
  }

  @override
  String get triggerManual => 'Manual';

  @override
  String get triggerVoice => 'Voice (\"help\")';

  @override
  String get triggerPowerButton => 'Power button ×3';

  @override
  String get triggerFallDetection => 'Fall detected';

  @override
  String get triggerGeofenceTimeout => 'Geofence timeout';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusFalseAlarm => 'False alarm';

  @override
  String get statusUnresolved => 'Unresolved';

  @override
  String get statusEscalated => 'Escalated';

  @override
  String get statusTriggered => 'Triggered';

  @override
  String get statusAcknowledged => 'Acknowledged';
}
