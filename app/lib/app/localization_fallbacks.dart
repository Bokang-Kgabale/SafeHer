import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's own Material/Widgets/Cupertino translations don't cover every
/// locale SafeHer ships its own strings for — isiZulu and Afrikaans are in
/// Flutter's supported set, but Sesotho ('st') is not. Without this,
/// selecting Sesotho throws "No MaterialLocalizations found": the framework
/// widgets (back-button tooltips, date pickers, etc.) have no delegate
/// willing to claim that locale at all, since `GlobalMaterialLocalizations`
/// only declares support for locales it actually has translations for.
///
/// Each of these wraps the real Global delegate and falls back to English
/// specifically for locales the wrapped delegate doesn't support, while
/// still using the real delegate's translations for every locale it does
/// support (af, zu, …). Only SafeHer's *own* strings (via [AppLocalizations])
/// are guaranteed to exist in every supported locale — the framework's
/// built-in chrome text degrades to English rather than crashing.
class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final resolved = GlobalMaterialLocalizations.delegate.isSupported(locale) ? locale : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(resolved);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    final resolved = GlobalWidgetsLocalizations.delegate.isSupported(locale) ? locale : const Locale('en');
    return GlobalWidgetsLocalizations.delegate.load(resolved);
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final resolved = GlobalCupertinoLocalizations.delegate.isSupported(locale) ? locale : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(resolved);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
