// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Afrikaans (`af`).
class AppLocalizationsAf extends AppLocalizations {
  AppLocalizationsAf([String locale = 'af']) : super(locale);

  @override
  String get appTitle => 'SafeHer';

  @override
  String get onboardingWelcomeTitle => 'Welkom by SafeHer';

  @override
  String get onboardingWelcomeBody =>
      'Jou metgesel vir veiliger stap-roetes, slimmer roetes, en vinniger hulp wanneer dit saak maak.';

  @override
  String get onboardingRouteTitle => 'Loop veiliger roetes';

  @override
  String get onboardingRouteBody =>
      'SafeHer kyk na aangemelde gevaarkolle langs jou pad en stel \'n roete voor wat dit vermy — en sê vir jou eerlik wanneer dit nie kan nie.';

  @override
  String get onboardingReportTitle => 'Rapporteer wat jy sien';

  @override
  String get onboardingReportBody =>
      'Merk \'n onveilige plek vir ander binne sekondes — kies \'n kategorie, voeg \'n foto by, en merk presies waar jy is.';

  @override
  String get onboardingPanicTitle => 'Hulp, net \'n tik weg';

  @override
  String get onboardingPanicBody =>
      'Die paniekknoppie bel en stuur boodskappe aan jou noodkontakte met jou lewendige ligging. Dit kontak nooit die polisie namens jou nie.';

  @override
  String get onboardingGetStartedTitle => 'Jy is gereed';

  @override
  String get onboardingGetStartedBody =>
      'Voeg eers \'n noodkontak by, sodat die paniekknoppie iemand het om te bereik.';

  @override
  String get onboardingSkip => 'Slaan oor';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingGetStarted => 'Begin';

  @override
  String get mapSettingsTooltip => 'Kaartinstellings';

  @override
  String get nextOfKinTooltip => 'Noodkontakte';

  @override
  String get activityTooltip => 'Aktiwiteit';

  @override
  String get previewModeBanner =>
      'VOORSKOU-MODUS — nagemaakte data, niks hier is werklik nie';

  @override
  String get reportModeHint =>
      'Tik op die kaart om \'n gevaarkol-wenker op daardie plek te plaas';

  @override
  String get routePlanHint =>
      'Tik op die kaart om \'n bestemming te kies — kaart roetes op werklike strate wanneer aanlyn';

  @override
  String get routeOfflineBanner =>
      'Geen netwerkroete beskikbaar nie — dit is \'n reguit-lyn-simulasie, nie werklike strate nie';

  @override
  String get routeWarningDestinationInFlagged =>
      'Jou bestemming is binne \'n aangemelde gebied — daar is geen roete daaromheen nie, wees ekstra versigtig by aankoms.';

  @override
  String get routeWarningPassesThrough =>
      'Geen redelike ompad vermy elke gemerkte gebied op hierdie roete nie — ekstra versigtigheid word aanbeveel.';

  @override
  String get routeWarningGeneric =>
      'Hierdie roete loop naby \'n aangemelde gebied — ekstra versigtigheid word aanbeveel.';

  @override
  String experimentalBanner(String features) {
    return 'EKSPERIMENTEEL ($features) — nie op werklike apparatuur geverifieer nie, nie \'n MVP-funksie nie';
  }

  @override
  String get hotspotPublishedSnackbar => 'Gevaarkol op die kaart gepubliseer.';

  @override
  String get noNetworkRouteSnackbar =>
      'Geen netwerkroete beskikbaar nie — \'n reguit-lyn-simulasie word eerder gewys.';

  @override
  String get hotspotSheetDemoNote =>
      'Demo-kontrole — staan in vir \'n werklike GPS-nabyheidsoorskryding totdat inheemse geo-omheining ingestel is.';

  @override
  String get hotspotSheetSimulateButton => 'Simuleer toegang tot hierdie sone';

  @override
  String get quickActionReportHotspot => 'Rapporteer gevaarkol';

  @override
  String get quickActionReportHotspotTooltip =>
      'Tik op die kaart om \'n wenker op daardie plek te plaas';

  @override
  String get quickActionSafeRoute => 'Veilige roete';

  @override
  String get quickActionSafeRouteTooltip =>
      'Tik op die kaart om \'n bestemming te kies en \'n roete te beplan';

  @override
  String get quickActionFallDetection => 'Valopsporing';

  @override
  String get quickActionFallDetectionTooltip =>
      'EKSPERIMENTEEL — nie op werklike apparatuur geverifieer nie, nie \'n MVP-funksie nie';

  @override
  String get quickActionVoiceTrigger => 'Stemtrigger';

  @override
  String get quickActionVoiceTriggerTooltip =>
      'EKSPERIMENTEEL — luister vir \"help\", nie \'n MVP-funksie nie';

  @override
  String get mapSettingsHeader => 'Kaartinstellings';

  @override
  String get liveGpsTitle => 'Lewendige GPS';

  @override
  String get liveGpsSubtitle => 'Af gebruik die gesimuleerde voorskou-posisie';

  @override
  String get heatmapTitle => 'Misdaadhittekaart';

  @override
  String get heatmapSubtitle =>
      'Geanimeerde digtheidsoorlegging van dieselfde gevaarkol-wenkers';

  @override
  String get alertStyleTitle => 'Waarskuwingstyl';

  @override
  String get alertStyleSubtitle =>
      'Gebruik deur die geo-omheining- en valopsporing-aftellings';

  @override
  String get alertStyleVibration => 'Vibrasie';

  @override
  String get alertStyleRingtone => 'Luitoon';

  @override
  String get languageTitle => 'Taal';

  @override
  String get languageSubtitle => 'Kies watter taal SafeHer wys';

  @override
  String get systemDefaultLanguage => 'Stelselverstek';

  @override
  String get replayTourTitle => 'Speel welkomstoer weer';

  @override
  String get replayTourSubtitle => 'Wys die eerste-keer-inleiding weer';

  @override
  String get mapSettingsFooter =>
      'Rapporteer gevaarkol, veilige roete, valopsporing en stemtrigger is op die hoofkaartskerm se kitsaksie-balk.';

  @override
  String get locationPermissionDenied =>
      'Liggingtoestemming geweier — bly op die gesimuleerde posisie.';

  @override
  String get speechUnavailable =>
      'Spraakherkenning nie op hierdie toestel beskikbaar nie.';

  @override
  String get reportHotspotTitle => 'Rapporteer \'n gevaarkol';

  @override
  String get reportHotspotDisclaimer =>
      'Dit publiseer onmiddellik na die openbare kaart — geen modereringshek voordat dit verskyn nie.';

  @override
  String get locationLabel => 'Ligging';

  @override
  String get locationPinnedSpot => 'Vasgespelde plek';

  @override
  String get locationMyLocation => 'My ligging';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get descriptionLabel => 'Beskrywing (opsioneel)';

  @override
  String get photoLabel => 'Foto (opsioneel)';

  @override
  String get takePhoto => 'Neem foto';

  @override
  String get chooseFromGallery => 'Kies uit galery';

  @override
  String get cameraUnavailable =>
      'Kon nie toegang tot die kamera/galery op hierdie toestel kry nie.';

  @override
  String get publishToMap => 'Publiseer na kaart';

  @override
  String get categoryRobbery => 'Roof';

  @override
  String get categoryHarassment => 'Teistering';

  @override
  String get categoryAssault => 'Aanranding';

  @override
  String get categoryNoLighting => 'Geen verligting';

  @override
  String get categoryOther => 'Ander';

  @override
  String get panicButtonLabel => 'PANIEK';

  @override
  String get noContactsTitle => 'Geen noodkontakte opgestel nie';

  @override
  String get noContactsBody =>
      'Die paniekknoppie kan nog niemand bereik nie — jy het geen noodkontakte opgestel nie. Voeg ten minste een by voordat jy hierop staatmaak in \'n werklike situasie. Hierdie app kontak nie die polisie nie; dis slegs noodkontakte.';

  @override
  String get notNow => 'Nie nou nie';

  @override
  String get addContact => 'Voeg \'n kontak by';

  @override
  String get confirmTriggerTitle => 'Aktiveer paniekwaarskuwing?';

  @override
  String get confirmTriggerBody =>
      'Dit bel en WhatsApp jou noodkontakte SLEGS, met jou lewendige ligging. Dit kontak nie die polisie of nooddienste nie — as jy in gevaar is en veilig kan, bel hulle self ook. (Voorskou-modus: gesimuleer — niks werkliks word gestuur nie.)';

  @override
  String get cancel => 'Kanselleer';

  @override
  String get triggerNow => 'Aktiveer nou';

  @override
  String get alertSentSnackbar =>
      'Waarskuwing aan noodkontakte gestuur — sien Aktiwiteit vir status. Die polisie is nie gekontak nie.';

  @override
  String geofenceCountdownMessage(int seconds) {
    return 'Jy is naby \'n aangemelde gevaarkol. Jou noodkontakte word oor ${seconds}s gewaarsku (nie die polisie nie) tensy jy bevestig jy is veilig.';
  }

  @override
  String get falseAlarmButton => 'Vals Alarm';

  @override
  String fallCountdownMessage(int seconds) {
    return 'Moontlike val opgespoor. Jou noodkontakte word oor ${seconds}s gewaarsku (nie die polisie nie) tensy jy bevestig jy is OK.';
  }

  @override
  String get imOkButton => 'Ek is OK';

  @override
  String get nextOfKinTitle => 'Noodkontakte';

  @override
  String get noContactsYetTitle => 'Nog geen noodkontakte nie';

  @override
  String get noContactsYetBody =>
      'Die paniekknoppie werk deur hierdie lys — voeg ten minste een by.';

  @override
  String errorGeneric(String error) {
    return 'Fout: $error';
  }

  @override
  String get editContactTitle => 'Wysig kontak';

  @override
  String get addContactTitle => 'Voeg noodkontak by';

  @override
  String get nameLabel => 'Naam';

  @override
  String get phoneLabel => 'Telefoonnommer';

  @override
  String get relationshipLabel => 'Verhouding (opsioneel)';

  @override
  String get save => 'Stoor';

  @override
  String get addContactButton => 'Voeg kontak by';

  @override
  String get activityTitle => 'Aktiwiteit (Voorskou)';

  @override
  String get panicEventsHeader => 'Paniekgebeure';

  @override
  String get noPanicEvents => 'Nog geen paniekgebeure nie.';

  @override
  String get dispatchTimelineHeader => 'Gesimuleerde uitstuur-tydlyn';

  @override
  String get dispatchTimelineNote =>
      'Voorskou-modus plaas nooit \'n werklike oproep of WhatsApp-boodskap nie — dit is wat sou gestuur gewees het.';

  @override
  String get noDispatchYet => 'Nog niks uitgestuur nie.';

  @override
  String escalationStep(int step) {
    return 'eskalasiestap $step';
  }

  @override
  String get triggerManual => 'Handmatig';

  @override
  String get triggerVoice => 'Stem (\"help\")';

  @override
  String get triggerPowerButton => 'Kragknoppie ×3';

  @override
  String get triggerFallDetection => 'Val opgespoor';

  @override
  String get triggerGeofenceTimeout => 'Geo-omheiningtydverstryking';

  @override
  String get statusResolved => 'Opgelos';

  @override
  String get statusFalseAlarm => 'Vals alarm';

  @override
  String get statusUnresolved => 'Onopgelos';

  @override
  String get statusEscalated => 'Geëskaleer';

  @override
  String get statusTriggered => 'Geaktiveer';

  @override
  String get statusAcknowledged => 'Erken';
}
