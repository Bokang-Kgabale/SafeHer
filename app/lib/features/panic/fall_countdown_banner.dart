import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// FR-PANIC-5's cancellable confirmation countdown. Shown whenever
/// [fallDetectionControllerProvider] reports a confirmed fall candidate.
///
/// Per SRS v1.2 §2.8/FR-PANIC-8: must state plainly that escalation reaches
/// next of kin only — never police.
class FallCountdownBanner extends ConsumerWidget {
  const FallCountdownBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(fallDetectionControllerProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: alert == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: Colors.red.shade900,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.personal_injury, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).fallCountdownMessage(alert.secondsRemaining),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
                        onPressed: () => ref.read(fallDetectionControllerProvider.notifier).confirmOk(),
                        child: Text(AppLocalizations.of(context).imOkButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
