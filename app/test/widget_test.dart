import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeher/features/map/map_screen.dart';
import 'package:safeher/l10n/generated/app_localizations.dart';

import 'support/no_network_tile_provider.dart';

void main() {
  testWidgets('app launches in Preview Mode and shows the map + panic button', (tester) async {
    // Widget tests have no real network access; injecting a no-op tile
    // provider avoids the map layer ever attempting a real HTTP request
    // (and the console noise that comes from flutter_map cleaning up a
    // failed in-flight tile fetch at teardown), rather than relying on
    // Flutter's test-only HTTP interception behaviour.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapScreen(tileProvider: NoNetworkTileProvider()),
        ),
      ),
    );
    await tester.pump(); // let the first stream events land

    expect(find.text('SafeHer'), findsOneWidget);
    expect(find.textContaining('PREVIEW MODE'), findsOneWidget);
    expect(find.text('PANIC'), findsOneWidget);
  });
}
