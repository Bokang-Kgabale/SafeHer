// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Zulu (`zu`).
class AppLocalizationsZu extends AppLocalizations {
  AppLocalizationsZu([String locale = 'zu']) : super(locale);

  @override
  String get appTitle => 'SafeHer';

  @override
  String get onboardingWelcomeTitle => 'Wamukelekile ku-SafeHer';

  @override
  String get onboardingWelcomeBody =>
      'Umngane wakho wokuhamba ngokuphepha, izindlela ezihlakaniphile, nosizo oluphuthumayo lapho kudingeka.';

  @override
  String get onboardingRouteTitle => 'Hamba ngezindlela eziphephile';

  @override
  String get onboardingRouteBody =>
      'I-SafeHer ihlola izindawo ezibikiwe njengeziyingozi endleleni yakho futhi iphakamise indlela ezigwemayo — futhi ikutshele ngokusobala uma ingakwazi.';

  @override
  String get onboardingReportTitle => 'Bika lokho okubonayo';

  @override
  String get onboardingReportBody =>
      'Phawula indawo engaphephile kwabanye ngemizuzwana embalwa — khetha uhlobo, engeza isithombe, futhi umake kanjalo lapho ukhona khona.';

  @override
  String get onboardingPanicTitle => 'Usizo, ngokuthinta kanye';

  @override
  String get onboardingPanicBody =>
      'Inkinobho yovalo iyashayela futhi ithumele umlayezo kubomndeni abaseduze ngendawo yakho yangempela. Ayikaze ixhumane namaphoyisa egameni lakho.';

  @override
  String get onboardingGetStartedTitle => 'Usukulungele';

  @override
  String get onboardingGetStartedBody =>
      'Qala ngokwengeza umuntu womndeni oseduze ohlwini, ukuze inkinobho yovalo ibe nomuntu engamfinyelela.';

  @override
  String get onboardingSkip => 'Yeqa';

  @override
  String get onboardingNext => 'Okulandelayo';

  @override
  String get onboardingGetStarted => 'Qala';

  @override
  String get mapSettingsTooltip => 'Izilungiselelo zebalazwe';

  @override
  String get nextOfKinTooltip => 'Abomndeni abaseduze';

  @override
  String get activityTooltip => 'Umsebenzi';

  @override
  String get previewModeBanner =>
      'IMODI YOKUBUKA — idatha eyenziwe, akukho lutho lapha oluyiqiniso';

  @override
  String get reportModeHint =>
      'Thepha ebalazweni ukuze ubeke uphawu lwendawo eyingozi kuleyo ndawo';

  @override
  String get routePlanHint =>
      'Thepha ebalazweni ukukhetha indawo ozoya kuyo — kuhambisana nemigwaqo yangempela uma uxhunyiwe ku-inthanethi';

  @override
  String get routeOfflineBanner =>
      'Ayikho indlela yenethiwekhi etholakalayo — lokhu ukulingisa komugqa oqondile, hhayi imigwaqo yangempela';

  @override
  String get routeWarningDestinationInFlagged =>
      'Indawo oya kuyo iphakathi endaweni ebikiwe — ayikho indlela ezungeza lokho, qaphela kakhulu lapho ufika.';

  @override
  String get routeWarningPassesThrough =>
      'Ayikho indlela ehambekayo egwema zonke izindawo ezibikiwe kule ndlela — kunconywa ukuqapha kakhulu.';

  @override
  String get routeWarningGeneric =>
      'Le ndlela idlula eduze nendawo ebikiwe — kunconywa ukuqapha kakhulu.';

  @override
  String experimentalBanner(String features) {
    return 'OKOKUHLOLA ($features) — akukaqinisekiswa kumshini wangempela, akuyona isici se-MVP';
  }

  @override
  String get hotspotPublishedSnackbar =>
      'Indawo eyingozi ishicilelwe ebalazweni.';

  @override
  String get noNetworkRouteSnackbar =>
      'Ayikho indlela yenethiwekhi etholakalayo — kubonisa ukulingisa komugqa oqondile esikhundleni salokho.';

  @override
  String get hotspotSheetDemoNote =>
      'Ukulawula kwedemo — kumelela ukuwela kweGPS yangempela kuze kufakwe uhlelo lwangempela lokuhlola izindawo.';

  @override
  String get hotspotSheetSimulateButton => 'Lingisa ukungena kule ndawo';

  @override
  String get quickActionReportHotspot => 'Bika indawo eyingozi';

  @override
  String get quickActionReportHotspotTooltip =>
      'Thepha ebalazweni ukuze ubeke uphawu kuleyo ndawo';

  @override
  String get quickActionSafeRoute => 'Indlela ephephile';

  @override
  String get quickActionSafeRouteTooltip =>
      'Thepha ebalazweni ukukhetha indawo nokuhlela indlela';

  @override
  String get quickActionFallDetection => 'Ukuthola ukuwa';

  @override
  String get quickActionFallDetectionTooltip =>
      'OKOKUHLOLA — akukaqinisekiswa kumshini wangempela, akuyona isici se-MVP';

  @override
  String get quickActionVoiceTrigger => 'Ukuvula ngezwi';

  @override
  String get quickActionVoiceTriggerTooltip =>
      'OKOKUHLOLA — ilalela igama elithi \"help\", akuyona isici se-MVP';

  @override
  String get mapSettingsHeader => 'Izilungiselelo zebalazwe';

  @override
  String get liveGpsTitle => 'I-GPS yangempela';

  @override
  String get liveGpsSubtitle => 'Uma ivaliwe kusetshenziswa indawo yokulingisa';

  @override
  String get heatmapTitle => 'Ibalazwe lobushisa bobugebengu';

  @override
  String get heatmapSubtitle =>
      'Ukubonisa okuhlangene kwezindawo ezibikiwe okunyakazayo';

  @override
  String get alertStyleTitle => 'Uhlobo lwesexwayiso';

  @override
  String get alertStyleSubtitle =>
      'Isetshenziswa ukubalwa kwesikhathi kokuzungeza nokuthola ukuwa';

  @override
  String get alertStyleVibration => 'Ukudlidliza';

  @override
  String get alertStyleRingtone => 'Umsindo wensimbi';

  @override
  String get languageTitle => 'Ulimi';

  @override
  String get languageSubtitle => 'Khetha ulimi i-SafeHer ezoluveza';

  @override
  String get systemDefaultLanguage => 'Okuzenzakalelayo kwesistimu';

  @override
  String get replayTourTitle => 'Dlala kabusha uhambo lokwamukela';

  @override
  String get replayTourSubtitle => 'Bonisa isingeniso sokuqala futhi';

  @override
  String get mapSettingsFooter =>
      'Ukubika indawo eyingozi, indlela ephephile, ukuthola ukuwa, nokuvula ngezwi kutholakala kubha lwezenzo ezisheshayo esikrinini esiyinhloko sebalazwe.';

  @override
  String get locationPermissionDenied =>
      'Imvume yendawo yenqatshiwe — kusaqhutshwa ngendawo yokulingisa.';

  @override
  String get speechUnavailable =>
      'Ukuqashelwa kwezwi akutholakali kule divayisi.';

  @override
  String get reportHotspotTitle => 'Bika indawo eyingozi';

  @override
  String get reportHotspotDisclaimer =>
      'Lokhu kushicilelwa ngokushesha ebalazweni lomphakathi — akukho sigaba sokuhlolwa ngaphambi kokuba kuvele.';

  @override
  String get locationLabel => 'Indawo';

  @override
  String get locationPinnedSpot => 'Indawo ebekiwe';

  @override
  String get locationMyLocation => 'Indawo yami';

  @override
  String get categoryLabel => 'Uhlobo';

  @override
  String get descriptionLabel => 'Incazelo (akuphoqelekile)';

  @override
  String get photoLabel => 'Isithombe (akuphoqelekile)';

  @override
  String get takePhoto => 'Thatha isithombe';

  @override
  String get chooseFromGallery => 'Khetha kwigalari';

  @override
  String get cameraUnavailable =>
      'Ayikwazanga ukufinyelela ikhamera/igalari kule divayisi.';

  @override
  String get publishToMap => 'Shicilela ebalazweni';

  @override
  String get categoryRobbery => 'Ukugebenga';

  @override
  String get categoryHarassment => 'Ukuhlukumeza';

  @override
  String get categoryAssault => 'Ukuhlaselwa';

  @override
  String get categoryNoLighting => 'Akukho ukukhanya';

  @override
  String get categoryOther => 'Okunye';

  @override
  String get panicButtonLabel => 'OVALO';

  @override
  String get noContactsTitle => 'Abekho abomndeni abaseduze ababekiwe';

  @override
  String get noContactsBody =>
      'Inkinobho yovalo ayikwazi ukufinyelela muntu okwamanje — awukabeki abomndeni abaseduze. Engeza okungenani oyedwa ngaphambi kokuthembela kulokhu esimweni sangempela. Le app ayixhumani namaphoyisa; kungabomndeni abaseduze kuphela.';

  @override
  String get notNow => 'Hhayi manje';

  @override
  String get addContact => 'Engeza umuntu';

  @override
  String get confirmTriggerTitle => 'Vula isexwayiso sovalo?';

  @override
  String get confirmTriggerBody =>
      'Lokhu kushayela futhi kuthumele i-WhatsApp KUPHELA kubomndeni abaseduze, kanye nendawo yakho yangempela. Akuxhumani namaphoyisa noma izinsizakalo eziphuthumayo — uma usengozini futhi ungakwazi ngokuphepha, bashayele nawe. (Imodi yokubuka: kulingisiwe — akukho okwangempela okuthunyelwayo.)';

  @override
  String get cancel => 'Khansela';

  @override
  String get triggerNow => 'Vula manje';

  @override
  String get alertSentSnackbar =>
      'Isexwayiso sithunyelwe kubomndeni abaseduze — bheka Umsebenzi ukuze ubone isimo. Amaphoyisa awaxhunyiwe.';

  @override
  String geofenceCountdownMessage(int seconds) {
    return 'Useduze nendawo ebikiwe njengeyingozi. Abomndeni bakho abaseduze bazoxwayiswa (hhayi amaphoyisa) emzuzwini engu-$seconds ngaphandle kokuthi uqinisekise ukuthi uphephile.';
  }

  @override
  String get falseAlarmButton => 'Isexwayiso Esingamanga';

  @override
  String fallCountdownMessage(int seconds) {
    return 'Kubonakala sengathi uwile. Abomndeni bakho abaseduze bazoxwayiswa (hhayi amaphoyisa) emzuzwini engu-$seconds ngaphandle kokuthi uqinisekise ukuthi ulungile.';
  }

  @override
  String get imOkButton => 'Ngilungile';

  @override
  String get nextOfKinTitle => 'Abomndeni abaseduze';

  @override
  String get noContactsYetTitle => 'Abekho abomndeni abaseduze okwamanje';

  @override
  String get noContactsYetBody =>
      'Inkinobho yovalo isebenza ngalolu hlu — engeza okungenani oyedwa.';

  @override
  String errorGeneric(String error) {
    return 'Iphutha: $error';
  }

  @override
  String get editContactTitle => 'Hlela umuntu';

  @override
  String get addContactTitle => 'Engeza umuntu womndeni oseduze';

  @override
  String get nameLabel => 'Igama';

  @override
  String get phoneLabel => 'Inombolo yocingo';

  @override
  String get relationshipLabel => 'Ubudlelwane (akuphoqelekile)';

  @override
  String get save => 'Londoloza';

  @override
  String get addContactButton => 'Engeza umuntu';

  @override
  String get activityTitle => 'Umsebenzi (Ukubuka)';

  @override
  String get panicEventsHeader => 'Izigameko zovalo';

  @override
  String get noPanicEvents => 'Azikho izigameko zovalo okwamanje.';

  @override
  String get dispatchTimelineHeader =>
      'Uhlelo lwesikhathi lokuthunyelwa okulingisiwe';

  @override
  String get dispatchTimelineNote =>
      'Imodi yokubuka ayikaze ifake ucingo lwangempela noma umlayezo we-WhatsApp — lokhu yikho okwakuzothunyelwa.';

  @override
  String get noDispatchYet => 'Akukho okuthunyelwe okwamanje.';

  @override
  String escalationStep(int step) {
    return 'isinyathelo sokukhulisa $step';
  }

  @override
  String get triggerManual => 'Ngesandla';

  @override
  String get triggerVoice => 'Izwi (\"help\")';

  @override
  String get triggerPowerButton => 'Inkinobho yamandla ×3';

  @override
  String get triggerFallDetection => 'Ukuwa kutholiwe';

  @override
  String get triggerGeofenceTimeout => 'Isikhathi sokuzungeza siphelile';

  @override
  String get statusResolved => 'Kuxazululiwe';

  @override
  String get statusFalseAlarm => 'Isexwayiso esingamanga';

  @override
  String get statusUnresolved => 'Akukaxazululwa';

  @override
  String get statusEscalated => 'Kukhulisiwe';

  @override
  String get statusTriggered => 'Kuvuliwe';

  @override
  String get statusAcknowledged => 'Kwamukelwe';
}
