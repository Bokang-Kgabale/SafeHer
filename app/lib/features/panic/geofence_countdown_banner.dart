import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// The FR-GEO-3 "False Alarm" countdown surface. Shown whenever
/// [geofenceUiControllerProvider] reports an active alert for any hotspot.
///
/// Per SRS v1.2 §2.8/FR-PANIC-8: must state plainly, right here, that
/// escalation reaches next of kin only — never police.
class GeofenceCountdownBanner extends ConsumerWidget {
  const GeofenceCountdownBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(geofenceUiControllerProvider);

    // AnimatedSize (rather than the widget simply appearing/disappearing
    // from its parent Column) makes a countdown that's about to escalate to
    // next of kin read as a deliberate event grabbing attention, not a
    // layout glitch — worth the extra ceremony given what it's warning about.
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: alert == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: Colors.orange.shade800,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.vibration, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).geofenceCountdownMessage(alert.secondsRemaining),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange.shade900),
                        onPressed: () => ref
                            .read(geofenceUiControllerProvider.notifier)
                            .falseAlarm(alert.hotspotId),
                        child: Text(AppLocalizations.of(context).falseAlarmButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
