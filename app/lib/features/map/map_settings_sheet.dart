import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/services/alert_feedback_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import 'map_toggle_actions.dart';

/// Consolidates the map's toggles into one bottom sheet rather than an
/// ever-growing row of app-bar icons — each row here rebuilds independently
/// via Riverpod, so toggling one doesn't close the sheet or lose the others'
/// state, unlike a standard `PopupMenuButton`.
void showMapSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const MapSettingsSheet(),
  );
}

/// `null` represents "follow the device's system locale."
const _supportedLocales = <Locale?>[null, Locale('en'), Locale('af'), Locale('zu'), Locale('st')];

String _languageName(AppLocalizations t, Locale? locale) => switch (locale?.languageCode) {
      null => t.systemDefaultLanguage,
      'en' => 'English',
      'af' => 'Afrikaans',
      'zu' => 'isiZulu',
      'st' => 'Sesotho',
      _ => locale!.languageCode,
    };

/// A settings row whose control sits on its own full-width line below the
/// title/subtitle, rather than squeezed into a ListTile's `trailing` slot —
/// see the doc comment where this is used for why that matters once labels
/// are translated into languages longer than English.
class _SettingsBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget control;

  const _SettingsBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SafeHerColors.violet),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          control,
        ],
      ),
    );
  }
}

class MapSettingsSheet extends ConsumerWidget {
  const MapSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiveGps = ref.watch(useLiveGpsProvider);
    final showHeatmap = ref.watch(showHeatmapProvider);
    final alertStyle = ref.watch(alertStyleProvider);
    final locale = ref.watch(localeControllerProvider);
    final t = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.tune, color: SafeHerColors.violet),
                const SizedBox(width: 8),
                Text(t.mapSettingsHeader,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(t.liveGpsTitle),
            subtitle: Text(t.liveGpsSubtitle),
            secondary: Icon(isLiveGps ? Icons.gps_fixed : Icons.gps_off),
            value: isLiveGps,
            onChanged: (_) => toggleLiveGps(context, ref, isLiveGps),
          ),
          SwitchListTile(
            title: Text(t.heatmapTitle),
            subtitle: Text(t.heatmapSubtitle),
            secondary: const Icon(Icons.local_fire_department),
            value: showHeatmap,
            onChanged: (v) => ref.read(showHeatmapProvider.notifier).state = v,
          ),
          // A trailing control sharing one row with title/subtitle text
          // works fine in English, but Afrikaans/isiZulu/Sesotho translations
          // run noticeably longer — cramming both into a ListTile's fixed
          // trailing slot squeezed the label column down to a sliver,
          // wrapping it one character per line. Stacking the control on its
          // own full-width row below the label is robust to that regardless
          // of how verbose a given language's translation is.
          _SettingsBlock(
            icon: alertStyle == AlertStyle.vibration ? Icons.vibration : Icons.notifications_active,
            title: t.alertStyleTitle,
            subtitle: t.alertStyleSubtitle,
            control: SegmentedButton<AlertStyle>(
              segments: [
                ButtonSegment(
                  value: AlertStyle.vibration,
                  icon: const Icon(Icons.vibration),
                  label: Text(t.alertStyleVibration),
                ),
                ButtonSegment(
                  value: AlertStyle.ringtone,
                  icon: const Icon(Icons.notifications_active),
                  label: Text(t.alertStyleRingtone),
                ),
              ],
              selected: {alertStyle},
              onSelectionChanged: (selection) =>
                  ref.read(alertStyleProvider.notifier).state = selection.first,
            ),
          ),
          _SettingsBlock(
            icon: Icons.translate,
            title: t.languageTitle,
            subtitle: t.languageSubtitle,
            control: SizedBox(
              width: double.infinity,
              child: DropdownButton<Locale?>(
                value: locale,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: _supportedLocales
                    .map((l) => DropdownMenuItem(value: l, child: Text(_languageName(t, l))))
                    .toList(),
                onChanged: (selected) =>
                    ref.read(localeControllerProvider.notifier).setLocale(selected),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(t.replayTourTitle),
            subtitle: Text(t.replayTourSubtitle),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(onboardingSeenControllerProvider.notifier).replay();
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              t.mapSettingsFooter,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
