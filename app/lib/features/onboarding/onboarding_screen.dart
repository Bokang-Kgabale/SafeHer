import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';

class _OnboardingPageData {
  final String? asset;
  final IconData? icon;
  final Color accent;
  final String title;
  final String body;

  const _OnboardingPageData({
    this.asset,
    this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });
}

/// First-run welcome flow (FR-ONB): a short, skippable walkthrough of the
/// app's three pillars — safe routing, community hotspot reports, and the
/// panic escalation — shown exactly once (see [OnboardingController]).
///
/// This exists because none of those three features explain themselves from
/// the map screen alone: a first-time user dropped straight onto a map full
/// of colored pins and mode toggles has no way to know what a "safe route"
/// detour means, that reporting publishes instantly with no moderation, or
/// — most importantly, given FR-PANIC-8 — that the panic button reaches
/// next of kin only and never police.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_OnboardingPageData> _pages(AppLocalizations t) => [
        _OnboardingPageData(
          asset: 'assets/branding/logo.png',
          accent: SafeHerColors.violet,
          title: t.onboardingWelcomeTitle,
          body: t.onboardingWelcomeBody,
        ),
        _OnboardingPageData(
          icon: Icons.alt_route,
          accent: SafeHerColors.safe,
          title: t.onboardingRouteTitle,
          body: t.onboardingRouteBody,
        ),
        _OnboardingPageData(
          icon: Icons.add_location_alt,
          accent: SafeHerColors.magenta,
          title: t.onboardingReportTitle,
          body: t.onboardingReportBody,
        ),
        _OnboardingPageData(
          icon: Icons.emergency_share,
          accent: SafeHerColors.panic,
          title: t.onboardingPanicTitle,
          body: t.onboardingPanicBody,
        ),
        _OnboardingPageData(
          icon: Icons.check_circle,
          accent: SafeHerColors.violetDark,
          title: t.onboardingGetStartedTitle,
          body: t.onboardingGetStartedBody,
        ),
      ];

  void _finish() => ref.read(onboardingSeenControllerProvider.notifier).markSeen();

  void _next(int pageCount) {
    if (_page.round() == pageCount - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = _pages(t);
    final isLastPage = _page.round() == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isLastPage ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: isLastPage ? null : _finish,
                  child: Text(t.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final delta = (index - _page).clamp(-1.0, 1.0);
                  return Opacity(
                    opacity: 1 - delta.abs(),
                    child: Transform.translate(
                      offset: Offset(delta * 40, 0),
                      child: _OnboardingPage(data: pages[index]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  final isActive = index == _page.round();
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? SafeHerColors.violet : SafeHerColors.violet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _next(pages.length),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isLastPage ? t.onboardingGetStarted : t.onboardingNext,
                      key: ValueKey(isLastPage),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: 0.85 + (0.15 * value),
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            ),
            child: data.asset != null
                ? Image.asset(data.asset!, width: 180, height: 180)
                : Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(data.icon, size: 64, color: data.accent),
                  ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
