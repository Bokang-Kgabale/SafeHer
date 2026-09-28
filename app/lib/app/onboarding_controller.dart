import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingSeenKey = 'safeher.onboarding_seen';

/// Whether the first-run onboarding flow has already been shown — persisted
/// so it appears exactly once per install, not on every cold start.
class OnboardingController extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingController(this._prefs) : super(_prefs.getBool(_onboardingSeenKey) ?? false);

  Future<void> markSeen() async {
    state = true;
    await _prefs.setBool(_onboardingSeenKey, true);
  }

  /// In-memory only — deliberately does not touch the persisted flag, so if
  /// the app is killed mid-replay without finishing, the next cold start
  /// still goes straight to the map rather than re-showing the tour
  /// unprompted. [markSeen] re-persists `true` once the replay is finished
  /// (or skipped) the same way the first run does.
  void replay() => state = false;
}
