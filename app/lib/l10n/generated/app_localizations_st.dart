// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Southern Sotho (`st`).
class AppLocalizationsSt extends AppLocalizations {
  AppLocalizationsSt([String locale = 'st']) : super(locale);

  @override
  String get appTitle => 'SafeHer';

  @override
  String get onboardingWelcomeTitle => 'Rea u amohela ho SafeHer';

  @override
  String get onboardingWelcomeBody =>
      'Motsamaisi wa hao bakeng sa maeto a sireletsehileng, ditsela tse bohlale, le thuso e potlakileng ha e hlokahala.';

  @override
  String get onboardingRouteTitle => 'Tsamaya ka litsela tse sireletsehileng';

  @override
  String get onboardingRouteBody =>
      'SafeHer e sheba libaka tse tlalehiloeng tse kotsi tseleng ea hao mme e etsa tlhahiso ea tsela e li qobellang — mme e u bolella ka botshepehi ha e sa khone.';

  @override
  String get onboardingReportTitle => 'Tlaleha seo u se bonang';

  @override
  String get onboardingReportBody =>
      'Tlaleha sebaka se sa sireletsehang bakeng sa ba bang ka metsotswana e mmalwa — khetha mofuta, kenya setshwantsho, mme u tshwaye hantle moo u leng teng.';

  @override
  String get onboardingPanicTitle => 'Thuso, ka ho tobetsa hanngwe feela';

  @override
  String get onboardingPanicBody =>
      'Konopo ya tshoso e letsetsa le ho romella melaetsa ho beng ba heno ka sebaka sa hao sa nnete. Ha e ka mohla e ikopanya le mapolesa boemong ba hao.';

  @override
  String get onboardingGetStartedTitle => 'O itokiselitse';

  @override
  String get onboardingGetStartedBody =>
      'Qala ka ho kenya motho eo le amaneng le eena, e le hore konopo ya tshoso e be le motho eo e ka mo fihlellang.';

  @override
  String get onboardingSkip => 'Tlola';

  @override
  String get onboardingNext => 'E latelang';

  @override
  String get onboardingGetStarted => 'Qala';

  @override
  String get mapSettingsTooltip => 'Litlhophiso tsa \'mapa';

  @override
  String get nextOfKinTooltip => 'Beng ba heno';

  @override
  String get activityTooltip => 'Mesebetsi';

  @override
  String get previewModeBanner =>
      'MOKGWA WA PONTSHO — data e etsisitsweng, ha ho letho mona le leng nnete';

  @override
  String get reportModeHint =>
      'Tobetsa \'mapeng ho beha pina ya sebaka se kotsi moo';

  @override
  String get routePlanHint =>
      'Tobetsa \'mapeng ho beha sepheo — e sebedisa literata tsa nnete ha o le inthaneteng';

  @override
  String get routeOfflineBanner =>
      'Ha ho na tsela ya marang-rang e fumanehang — ena ke tshwantshiso ya mola o otlolohileng, eseng literata tsa nnete';

  @override
  String get routeWarningDestinationInFlagged =>
      'Sepheo sa hao se ka hare ho sebaka se tlalehiloeng — ha ho na tsela e se qobellang, ela hloko haholo ha o fihla.';

  @override
  String get routeWarningPassesThrough =>
      'Ha ho tsela e utlwahalang e qobellang dibaka tsohle tse tlalehiloeng tseleng ena — ho kgothaletswa ho ela hloko haholo.';

  @override
  String get routeWarningGeneric =>
      'Tsela ena e feta haufi le sebaka se tlalehiloeng — ho kgothaletswa ho ela hloko haholo.';

  @override
  String experimentalBanner(String features) {
    return 'TSA TEKO ($features) — ha di so netefatswe ho disebediswa tsa nnete, ha se karolo ya MVP';
  }

  @override
  String get hotspotPublishedSnackbar =>
      'Sebaka se kotsi se phatlaladitswe \'mapeng.';

  @override
  String get noNetworkRouteSnackbar =>
      'Ha ho na tsela ya marang-rang e fumanehang — ho bontshwa tshwantshiso ya mola o otlolohileng ho e-na le hoo.';

  @override
  String get hotspotSheetDemoNote =>
      'Taolo ya pontsho — e emela ho fetoha ha GPS ya nnete ho fihlela tsamaiso ya nnete e kentswe.';

  @override
  String get hotspotSheetSimulateButton => 'Etsisa ho kena sebakeng sena';

  @override
  String get quickActionReportHotspot => 'Tlaleha sebaka se kotsi';

  @override
  String get quickActionReportHotspotTooltip =>
      'Tobetsa \'mapeng ho beha pina sebakeng seo';

  @override
  String get quickActionSafeRoute => 'Tsela e sireletsehileng';

  @override
  String get quickActionSafeRouteTooltip =>
      'Tobetsa \'mapeng ho beha sepheo le ho rala tsela';

  @override
  String get quickActionFallDetection => 'Ho lemoha ho wa';

  @override
  String get quickActionFallDetectionTooltip =>
      'TSA TEKO — ha di so netefatswe ho disebediswa tsa nnete, ha se karolo ya MVP';

  @override
  String get quickActionVoiceTrigger => 'Ho qala ka lentswe';

  @override
  String get quickActionVoiceTriggerTooltip =>
      'TSA TEKO — e mamela lentswe le reng \"help\", ha se karolo ya MVP';

  @override
  String get mapSettingsHeader => 'Litlhophiso tsa \'mapa';

  @override
  String get liveGpsTitle => 'GPS ya nnete';

  @override
  String get liveGpsSubtitle =>
      'Ha e kwetswe ho sebediswa boemo bo etsisitsweng';

  @override
  String get heatmapTitle => '\'Mapa wa mocheso wa botlokotsebe';

  @override
  String get heatmapSubtitle =>
      'Pontsho e tsamaisang ya boteng bo tswang lipineng tse tshwanang tsa dibaka tse kotsi';

  @override
  String get alertStyleTitle => 'Mofuta wa temoso';

  @override
  String get alertStyleSubtitle =>
      'E sebediswa ke dipalo tsa nako tsa moedi le ho lemoha ho wa';

  @override
  String get alertStyleVibration => 'Ho thothomela';

  @override
  String get alertStyleRingtone => 'Modumo wa mohala';

  @override
  String get languageTitle => 'Puo';

  @override
  String get languageSubtitle => 'Khetha puo eo SafeHer e tla e bontsha';

  @override
  String get systemDefaultLanguage => 'Taolo ya sistimi';

  @override
  String get replayTourTitle => 'Bapala hape leeto la kamohelo';

  @override
  String get replayTourSubtitle => 'Bontsha tlhahiso ya qalong hape';

  @override
  String get mapSettingsFooter =>
      'Ho tlaleha sebaka se kotsi, tsela e sireletsehileng, ho lemoha ho wa, le ho qala ka lentswe di fumaneha mola wa diketso tse potlakileng skrineng se seholo sa \'mapa.';

  @override
  String get locationPermissionDenied =>
      'Tumello ya sebaka e hanilwe — ho tswela pele ka boemo bo etsisitsweng.';

  @override
  String get speechUnavailable =>
      'Ho tsebahatswa ha lentswe ha ho fumanehe sesebediswaneng sena.';

  @override
  String get reportHotspotTitle => 'Tlaleha sebaka se kotsi';

  @override
  String get reportHotspotDisclaimer =>
      'Sena se phatlalatswa hang-hang \'mapeng wa setjhaba — ha ho na mokgwa wa tlhahlobo pele se bonahala.';

  @override
  String get locationLabel => 'Sebaka';

  @override
  String get locationPinnedSpot => 'Sebaka se behilweng';

  @override
  String get locationMyLocation => 'Sebaka sa ka';

  @override
  String get categoryLabel => 'Mofuta';

  @override
  String get descriptionLabel => 'Tlhaloso (ha e hlokahale)';

  @override
  String get photoLabel => 'Setshwantsho (ha se hlokahale)';

  @override
  String get takePhoto => 'Nka setshwantsho';

  @override
  String get chooseFromGallery => 'Khetha ho tswa ho gallery';

  @override
  String get cameraUnavailable =>
      'E sitwa ho fihlella khamera/gallery sesebediswaneng sena.';

  @override
  String get publishToMap => 'Phatlalatsa \'mapeng';

  @override
  String get categoryRobbery => 'Bosholu';

  @override
  String get categoryHarassment => 'Tlhekefetso';

  @override
  String get categoryAssault => 'Tlhaselo';

  @override
  String get categoryNoLighting => 'Ha ho bosedi';

  @override
  String get categoryOther => 'Tse ding';

  @override
  String get panicButtonLabel => 'TSHOSO';

  @override
  String get noContactsTitle => 'Ha ho batho ba tshohanyetso ba behilweng';

  @override
  String get noContactsBody =>
      'Konopo ya tshoso ha e so kgone ho fihlella motho — ha o so behe batho ba heno. Kenya bonyane a le mong pele o itshepa sena boemong ba nnete. App ena ha e ikopanye le mapolesa; ke batho ba heno feela.';

  @override
  String get notNow => 'Eseng hona jwale';

  @override
  String get addContact => 'Kenya motho';

  @override
  String get confirmTriggerTitle => 'Qala temoso ya tshoso?';

  @override
  String get confirmTriggerBody =>
      'Sena se letsetsa le ho romella WhatsApp ho batho ba heno FEELA, ka sebaka sa hao sa nnete. Ha se ikopanye le mapolesa kapa ditshebeletso tsa tshohanyetso — haeba o kotsing mme o ka kgona ka polokeho, ba letsetse le wena. (Mokgwa wa pontsho: e etsisitswe — ha ho letho la nnete le romelwang.)';

  @override
  String get cancel => 'Hlakola';

  @override
  String get triggerNow => 'Qala hona jwale';

  @override
  String get alertSentSnackbar =>
      'Temoso e rometswe ho batho ba heno — sheba Mesebetsi bakeng sa boemo. Mapolesa ha a ka a ikopanya.';

  @override
  String geofenceCountdownMessage(int seconds) {
    return 'O haufi le sebaka se tlalehiloeng e le se kotsi. Batho ba heno ba tla lemoswa (eseng mapolesa) ka metsotswana e $seconds ntle le hore o netefatse hore o bolokehile.';
  }

  @override
  String get falseAlarmButton => 'Temoso ya Leshano';

  @override
  String fallCountdownMessage(int seconds) {
    return 'Ho ka nna ha etsahala ho wa. Batho ba heno ba tla lemoswa (eseng mapolesa) ka metsotswana e $seconds ntle le hore o netefatse hore o phetse hantle.';
  }

  @override
  String get imOkButton => 'Ke phetse hantle';

  @override
  String get nextOfKinTitle => 'Beng ba heno';

  @override
  String get noContactsYetTitle =>
      'Ha ho batho ba tshohanyetso ho fihlela jwale';

  @override
  String get noContactsYetBody =>
      'Konopo ya tshoso e sebetsa ka lenane lena — kenya bonyane a le mong.';

  @override
  String errorGeneric(String error) {
    return 'Phoso: $error';
  }

  @override
  String get editContactTitle => 'Fetola motho';

  @override
  String get addContactTitle => 'Kenya motho wa leloko';

  @override
  String get nameLabel => 'Lebitso';

  @override
  String get phoneLabel => 'Nomoro ya mohala';

  @override
  String get relationshipLabel => 'Kamano (ha e hlokahale)';

  @override
  String get save => 'Boloka';

  @override
  String get addContactButton => 'Kenya motho';

  @override
  String get activityTitle => 'Mesebetsi (Pontsho)';

  @override
  String get panicEventsHeader => 'Diketsahalo tsa tshoso';

  @override
  String get noPanicEvents => 'Ha ho diketsahalo tsa tshoso ho fihlela jwale.';

  @override
  String get dispatchTimelineHeader => 'Nako ya ho romelwa e etsisitsweng';

  @override
  String get dispatchTimelineNote =>
      'Mokgwa wa pontsho ha o ka mohla o etsa mohala wa nnete kapa molaetsa wa WhatsApp — sena ke seo se neng se tla romelwa.';

  @override
  String get noDispatchYet =>
      'Ha ho letho le se le rometsweng ho fihlela jwale.';

  @override
  String escalationStep(int step) {
    return 'mohato wa ho phahamisa $step';
  }

  @override
  String get triggerManual => 'Ka letsoho';

  @override
  String get triggerVoice => 'Lentswe (\"help\")';

  @override
  String get triggerPowerButton => 'Konopo ya matla ×3';

  @override
  String get triggerFallDetection => 'Ho wa ho lemotswe';

  @override
  String get triggerGeofenceTimeout => 'Nako ya moedi e felile';

  @override
  String get statusResolved => 'E rarollotswe';

  @override
  String get statusFalseAlarm => 'Temoso ya leshano';

  @override
  String get statusUnresolved => 'Ha e so rarollwe';

  @override
  String get statusEscalated => 'E phahamisitswe';

  @override
  String get statusTriggered => 'E qadilwe';

  @override
  String get statusAcknowledged => 'E amohetswe';
}
