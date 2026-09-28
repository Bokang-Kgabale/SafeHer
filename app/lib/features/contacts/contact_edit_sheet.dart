import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Bottom sheet for adding/editing a single next-of-kin contact (FR-NOK-1).
Future<({String name, String phoneNumber, String? relationship})?> showContactEditSheet(
  BuildContext context, {
  String? initialName,
  String? initialPhoneNumber,
  String? initialRelationship,
}) {
  final nameController = TextEditingController(text: initialName);
  final phoneController = TextEditingController(text: initialPhoneNumber);
  final relationshipController = TextEditingController(text: initialRelationship);
  final isEditing = initialName != null;

  return showModalBottomSheet<({String name, String phoneNumber, String? relationship})>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final t = AppLocalizations.of(context);
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEditing ? t.editContactTitle : t.addContactTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: t.nameLabel, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: t.phoneLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: InputDecoration(
                labelText: t.relationshipLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop((
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    relationship: relationshipController.text.trim().isEmpty
                        ? null
                        : relationshipController.text.trim(),
                  ));
                },
                child: Text(isEditing ? t.save : t.addContactButton),
              ),
            ),
          ],
        ),
      );
    },
  );
}
