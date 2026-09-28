import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/map/map_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../l10n/generated/app_localizations.dart';
import 'localization_fallbacks.dart';
import 'providers.dart';
import 'theme.dart';

class SafeHerApp extends ConsumerWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp(
      title: 'SafeHer',
      debugShowCheckedModeBanner: false,
      theme: buildSafeHerTheme(),
      locale: locale,
      // Not `AppLocalizations.localizationsDelegates` — that list includes
      // the plain `GlobalMaterialLocalizations.delegate` etc., which don't
      // support every locale SafeHer's own translations cover (Sesotho has
      // no Flutter-shipped Material/Widgets/Cupertino translation at all).
      // The fallback delegates wrap those and degrade to English for the
      // framework's own chrome text on an unsupported locale instead of
      // throwing "No MaterialLocalizations found".
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _RootGate(),
    );
  }
}

/// `MaterialApp.home` is only consulted once, when its Navigator builds the
/// initial route — changing the value on a later rebuild does NOT swap
/// what's already on the stack, since the existing route keeps the builder
/// closure it was created with. Gating on a stable widget here instead (that
/// internally swaps its own child) sidesteps that, since it's an ordinary
/// widget rebuild inside the same route rather than an attempt to rebuild
/// the route itself.
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(onboardingSeenControllerProvider);
    return hasSeenOnboarding ? const MapScreen() : const OnboardingScreen();
  }
}
