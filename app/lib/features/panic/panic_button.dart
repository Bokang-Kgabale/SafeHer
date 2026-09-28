import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/panic_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../contacts/contacts_screen.dart';

/// Always-reachable manual trigger (FR-PANIC-2). Requires a confirm step so an
/// accidental tap doesn't fire a real (simulated, in Preview Mode) escalation.
///
/// Per SRS v1.2 §2.8 (moderator-driven scope correction): this must never
/// imply police/emergency-services contact (FR-PANIC-8), and must warn
/// *before* triggering if there's nobody to actually escalate to (FR-PANIC-9)
/// — a panic layer that fails silently is worse than no panic layer at all.
class PanicButton extends ConsumerWidget {
  const PanicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.red.shade700,
      foregroundColor: Colors.white,
      icon: const _PulsingIcon(icon: Icons.emergency_share),
      label: Text(AppLocalizations.of(context).panicButtonLabel),
      onPressed: () => _handlePress(context, ref),
    );
  }

  Future<void> _handlePress(BuildContext context, WidgetRef ref) async {
    final contacts = ref.read(contactsProvider).value ?? const [];
    if (contacts.isEmpty) {
      await _warnNoContacts(context);
      return;
    }
    await _confirmAndTrigger(context, ref);
  }

  Future<void> _warnNoContacts(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final goToContacts = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.noContactsTitle),
        content: Text(t.noContactsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.addContact),
          ),
        ],
      ),
    );
    if (goToContacts == true && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactsScreen()));
    }
  }

  Future<void> _confirmAndTrigger(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.confirmTriggerTitle),
        content: Text(t.confirmTriggerBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.triggerNow),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final services = ref.read(appServicesProvider);
    await services.panicController.trigger(PanicTrigger.manual);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.alertSentSnackbar)),
      );
    }
  }
}

/// A slow, subtle "breathing" scale on just the icon (not the whole button,
/// so the tappable area never visibly shifts) — reinforces that this is the
/// one control that's always live and worth noticing, without being as
/// distracting as pulsing the entire FAB would be.
class _PulsingIcon extends StatefulWidget {
  final IconData icon;

  const _PulsingIcon({required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(widget.icon),
    );
  }
}
