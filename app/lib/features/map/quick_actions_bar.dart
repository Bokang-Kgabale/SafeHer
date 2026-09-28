import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import 'map_toggle_actions.dart';

/// Always-visible row of the map's main mode toggles — reporting a hotspot,
/// planning a safe route, fall detection, and the voice trigger.
///
/// This exists because real-device testing showed the previous discovery
/// paths didn't work for an actual user: hotspot reporting was long-press
/// only (nobody finds a long-press gesture on their own), and fall
/// detection/voice trigger were one level deep in a settings sheet behind a
/// small "tune" icon. Putting all four directly on the main screen, always
/// visible, is the fix — secondary/cosmetic settings (live GPS, heatmap,
/// alert style) stay in the settings sheet, but anything a tester actually
/// needs to find and use during a real walk-test does not.
class QuickActionsBar extends ConsumerWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportMode = ref.watch(reportModeProvider);
    final routePlanMode = ref.watch(routePlanModeProvider);
    final isFallDetectionEnabled = ref.watch(fallDetectionEnabledProvider);
    final isVoiceTriggerEnabled = ref.watch(voiceTriggerEnabledProvider);
    final t = AppLocalizations.of(context);

    return Container(
      color: SafeHerColors.surfaceTint,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _AnimatedChip(
              selected: reportMode,
              child: FilterChip(
                avatar: Icon(Icons.add_location_alt, size: 18, color: reportMode ? Colors.white : SafeHerColors.magenta),
                label: Text(t.quickActionReportHotspot),
                tooltip: t.quickActionReportHotspotTooltip,
                selected: reportMode,
                selectedColor: SafeHerColors.magenta,
                checkmarkColor: Colors.white,
                onSelected: (_) => toggleReportMode(ref, reportMode),
              ),
            ),
            const SizedBox(width: 8),
            _AnimatedChip(
              selected: routePlanMode,
              child: FilterChip(
                avatar: Icon(Icons.alt_route, size: 18, color: routePlanMode ? Colors.white : SafeHerColors.violet),
                label: Text(t.quickActionSafeRoute),
                tooltip: t.quickActionSafeRouteTooltip,
                selected: routePlanMode,
                selectedColor: SafeHerColors.violet,
                checkmarkColor: Colors.white,
                onSelected: (_) => toggleRoutePlanMode(ref, routePlanMode),
              ),
            ),
            const SizedBox(width: 8),
            _AnimatedChip(
              selected: isFallDetectionEnabled,
              child: FilterChip(
                avatar: Icon(Icons.sensors, size: 18, color: isFallDetectionEnabled ? Colors.black87 : SafeHerColors.warning),
                label: Text(t.quickActionFallDetection),
                tooltip: t.quickActionFallDetectionTooltip,
                selected: isFallDetectionEnabled,
                selectedColor: Colors.amber.shade200,
                onSelected: (_) => toggleFallDetection(ref, isFallDetectionEnabled),
              ),
            ),
            const SizedBox(width: 8),
            _AnimatedChip(
              selected: isVoiceTriggerEnabled,
              child: FilterChip(
                avatar: Icon(Icons.mic, size: 18, color: isVoiceTriggerEnabled ? Colors.black87 : SafeHerColors.warning),
                label: Text(t.quickActionVoiceTrigger),
                tooltip: t.quickActionVoiceTriggerTooltip,
                selected: isVoiceTriggerEnabled,
                selectedColor: Colors.amber.shade200,
                onSelected: (_) => toggleVoiceTrigger(context, ref, isVoiceTriggerEnabled),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A faint scale "pop" when a quick-action toggles on — reinforces the state
/// change beyond just the chip's own color swap, without being distracting
/// when several chips exist side by side.
class _AnimatedChip extends StatelessWidget {
  final bool selected;
  final Widget child;

  const _AnimatedChip({required this.selected, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
