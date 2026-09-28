import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/models/panic_event.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shows the simulated dispatch timeline (FR-PREV-3) and current panic event
/// status — this is what makes the panic pipeline's escalation logic visible
/// during a demo instead of happening invisibly in the background.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dispatchLog = ref.watch(simulatedDispatchLogProvider);
    final panicEvents = ref.watch(panicEventsProvider);
    final timeFormat = DateFormat('HH:mm:ss');
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.activityTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.panicEventsHeader, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          panicEvents.when(
            data: (events) => events.isEmpty
                ? Text(t.noPanicEvents, style: const TextStyle(color: Colors.black54))
                : Column(
                    children: events.reversed.map((event) {
                      return Card(
                        child: ListTile(
                          leading: Icon(_iconForStatus(event.status), color: _colorForStatus(event.status)),
                          title: Text(
                            '${_triggerLabel(t, event.triggerType)} — ${_statusLabel(t, event.status)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${timeFormat.format(event.timestamp)} · '
                            '${t.escalationStep(event.escalationIndex + 1)}',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text(t.errorGeneric(e.toString())),
          ),
          const SizedBox(height: 24),
          Text(t.dispatchTimelineHeader, style: Theme.of(context).textTheme.titleMedium),
          Text(
            t.dispatchTimelineNote,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          dispatchLog.when(
            data: (entries) => entries.isEmpty
                ? Text(t.noDispatchYet, style: const TextStyle(color: Colors.black54))
                : Column(
                    children: entries.reversed.map((entry) {
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            entry.channel == 'call' ? Icons.call : Icons.chat,
                            color: SafeHerColors.violet,
                          ),
                          title: Text(entry.summary),
                          subtitle: Text('${timeFormat.format(entry.at)} · ${entry.contactName}'),
                        ),
                      );
                    }).toList(),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text(t.errorGeneric(e.toString())),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus(PanicStatus status) {
    switch (status) {
      case PanicStatus.resolved:
        return Icons.check_circle;
      case PanicStatus.falseAlarm:
        return Icons.cancel;
      case PanicStatus.unresolved:
        return Icons.error;
      case PanicStatus.escalated:
      case PanicStatus.triggered:
      case PanicStatus.acknowledged:
        return Icons.hourglass_top;
    }
  }

  Color _colorForStatus(PanicStatus status) {
    switch (status) {
      case PanicStatus.resolved:
        return SafeHerColors.safe;
      case PanicStatus.falseAlarm:
        return Colors.black45;
      case PanicStatus.unresolved:
        return SafeHerColors.danger;
      case PanicStatus.escalated:
      case PanicStatus.triggered:
      case PanicStatus.acknowledged:
        return SafeHerColors.warning;
    }
  }

  String _statusLabel(AppLocalizations t, PanicStatus status) {
    switch (status) {
      case PanicStatus.resolved:
        return t.statusResolved;
      case PanicStatus.falseAlarm:
        return t.statusFalseAlarm;
      case PanicStatus.unresolved:
        return t.statusUnresolved;
      case PanicStatus.escalated:
        return t.statusEscalated;
      case PanicStatus.triggered:
        return t.statusTriggered;
      case PanicStatus.acknowledged:
        return t.statusAcknowledged;
    }
  }

  String _triggerLabel(AppLocalizations t, PanicTrigger trigger) {
    switch (trigger) {
      case PanicTrigger.manual:
        return t.triggerManual;
      case PanicTrigger.voice:
        return t.triggerVoice;
      case PanicTrigger.powerButton:
        return t.triggerPowerButton;
      case PanicTrigger.fallDetection:
        return t.triggerFallDetection;
      case PanicTrigger.geofenceTimeout:
        return t.triggerGeofenceTimeout;
    }
  }
}
