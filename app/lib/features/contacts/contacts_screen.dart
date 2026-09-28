import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_services.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/models/emergency_contact.dart';
import '../../l10n/generated/app_localizations.dart';
import 'contact_edit_sheet.dart';

/// Next-of-kin management (FR-NOK-1): add/edit/remove and re-order the
/// priority list the panic pipeline escalates through.
///
/// FR-NOK-2 (re-authentication before viewing/editing this screen) is not
/// yet implemented — flagged here rather than faked, since a placeholder PIN
/// check would be security theatre, not the real `local_auth` biometric gate
/// the SRS specifies. Wire that before this screen ships past a demo.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final services = ref.read(appServicesProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.nextOfKinTitle)),
      body: contactsAsync.when(
        data: (contacts) {
          final sorted = [...contacts]
            ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
          if (sorted.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt, size: 48, color: SafeHerColors.violetLight),
                    const SizedBox(height: 12),
                    Text(
                      t.noContactsYetTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.noContactsYetBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final contact = sorted[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: SafeHerColors.violet,
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    contact.relationship != null
                        ? '${contact.phoneNumber} · ${contact.relationship}'
                        : contact.phoneNumber,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: index == 0
                            ? null
                            : () => _swapPriority(services, sorted, index, index - 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: index == sorted.length - 1
                            ? null
                            : () => _swapPriority(services, sorted, index, index + 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editContact(context, services, contact),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: SafeHerColors.danger),
                        onPressed: () => services.contactRepository.remove(contact.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(t.errorGeneric(e.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addContact(context, services, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _addContact(BuildContext context, AppServices services, WidgetRef ref) async {
    final result = await showContactEditSheet(context);
    if (result == null) return;

    // Read the latest snapshot straight off the provider rather than the
    // stream, since a StreamProvider always caches its most recent value.
    final current = ref.read(contactsProvider).value ?? const <EmergencyContact>[];
    await services.contactRepository.upsert(EmergencyContact(
      id: const Uuid().v4(),
      userId: services.currentUserId,
      name: result.name,
      phoneNumber: result.phoneNumber,
      priorityOrder: current.length,
      relationship: result.relationship,
    ));
  }

  Future<void> _editContact(
    BuildContext context,
    AppServices services,
    EmergencyContact contact,
  ) async {
    final result = await showContactEditSheet(
      context,
      initialName: contact.name,
      initialPhoneNumber: contact.phoneNumber,
      initialRelationship: contact.relationship,
    );
    if (result == null) return;

    await services.contactRepository.upsert(EmergencyContact(
      id: contact.id,
      userId: contact.userId,
      name: result.name,
      phoneNumber: result.phoneNumber,
      priorityOrder: contact.priorityOrder,
      relationship: result.relationship,
    ));
  }

  Future<void> _swapPriority(
    AppServices services,
    List<EmergencyContact> sorted,
    int a,
    int b,
  ) async {
    final contactA = sorted[a];
    final contactB = sorted[b];
    await services.contactRepository.upsert(EmergencyContact(
      id: contactA.id,
      userId: contactA.userId,
      name: contactA.name,
      phoneNumber: contactA.phoneNumber,
      priorityOrder: contactB.priorityOrder,
      relationship: contactA.relationship,
    ));
    await services.contactRepository.upsert(EmergencyContact(
      id: contactB.id,
      userId: contactB.userId,
      name: contactB.name,
      phoneNumber: contactB.phoneNumber,
      priorityOrder: contactA.priorityOrder,
      relationship: contactB.relationship,
    ));
  }
}
