import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeCodeKey = 'safeher.locale_code';

/// `null` state means "follow the device's system locale" (falling back to
/// English if the device locale isn't one SafeHer ships translations for).
/// Explicitly picking a language in Map settings overrides that choice and
/// persists it locally, so it survives an app restart without needing an
/// account or network round-trip.
class LocaleController extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;

  LocaleController(this._prefs) : super(_read(_prefs));

  static Locale? _read(SharedPreferences prefs) {
    final code = prefs.getString(_localeCodeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_localeCodeKey);
    } else {
      await _prefs.setString(_localeCodeKey, locale.languageCode);
    }
  }
}
