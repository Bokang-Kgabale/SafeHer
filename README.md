# SafeHer

A mobile safety app that turns the crime knowledge women already carry — the street avoided after dark, the shortcut abandoned since something happened to a friend — into a shared, live map. Women pin the areas they know to be dangerous; anyone nearby can see those hotspots and be routed around them. As a user approaches a flagged area, her phone vibrates and gives her a 60-second window to stand the alert down — if she doesn't, it escalates on its own, sending her live location to the people she trusts. Getting help never requires unlocking the phone: a spoken word, a fall, or a tap of the panic button all fire the same response.

Built originally for Bloemfontein, South Africa — but the underlying problem (no shared record of danger, no fast quiet way to get help) isn't unique to one city.

## Open source, on purpose

**This project is MIT-licensed and open to any developer, anywhere, who wants to use this technology to make someone safer.** That includes adapting it for a different city, a different country, a different at-risk group, or a completely different use case this codebase hasn't imagined yet. Fork it, strip it down, rebuild the UI, translate it, point it at a different backend — the only ask is that you keep the license notice and, if people's safety depends on your fork, take the same care with the panic and location-handling code that this project tries to (see [Contributing](#contributing) and [Security & responsible use](#security--responsible-use) below).

See [`LICENSE`](../LICENSE) for the full text.

## What it actually does

Full detail lives in [`SafeHer_App_Detailed_Overview.md`](../SafeHer_App_Detailed_Overview.md) and the requirements spec in [`SafeHer_SRS.md`](../SafeHer_SRS.md). In short:

- **Hotspot map** — drop a pin, pick a category, it publishes immediately to everyone nearby.
- **Geofence alerts** — a background check (no continuous GPS polling) that vibrates the phone and starts a 60-second countdown as you approach a marked spot.
- **Panic pipeline** — one outcome (call/WhatsApp your next-of-kin, in priority order), four ways to trigger it: a manual button, an on-device voice listener for the word "help," fall detection via the accelerometer, and (planned) a power-button triple-press.
- **Next-of-kin management** — a prioritised contact list, gated by re-authentication so a partner with casual phone access can't view or edit it.
- **Preview Mode** — the entire app is explorable with zero account, zero permissions, and zero real data, using a seeded mock dataset. This is also the easiest way to try the app locally (see below).
- **Safer routing, moderation, notifications, and paid/institutional tiers** — specified in the SRS as the product roadmap; see the honesty note below for what's actually built today.

### What's real vs. planned, honestly

This project treats the panic pipeline and location data as safety-critical, not a feature checklist — a capability that hasn't been tested on real hardware doesn't get claimed as working, however complete the code looks. If you're deciding what to build on:

| Tier | What's in it |
|---|---|
| **Built and demoable today** | Hotspot map + reporting, geofence alert + 60s countdown, manual panic button → next-of-kin, next-of-kin management, Preview Mode |
| **Built, not yet trusted** | Voice trigger, fall detection — present in the code, off by default, not verified on real hardware yet |
| **Specified, not built** | Power-button trigger, route planning around hotspots, moderation tooling, push notifications, subscriptions/payments, the web dashboard |

## Project structure

```
lib/
  core/        Framework-agnostic domain logic: models, repository interfaces,
               controllers (panic, geofence), algorithms (fall detection, routing)
  data/
    preview/   In-memory mock implementations of every repository — what the
               app runs on by default, so it works with zero setup
    firebase/  Firestore-backed implementations of the same interfaces
               (scaffolded, not wired in yet — see below)
    device/    Real device sensors (GPS via geolocator)
    routing/   OSRM-based route calculation
  features/    UI screens (map, panic, contacts, activity, onboarding)
  app/         Wires everything together (see app_services.dart) and holds
               cross-cutting app state (theme, locale, providers)
  l10n/        Translations — English, Afrikaans, isiZulu, Sesotho
test/          Unit tests for the safety-critical core (panic, geofencing,
               fall detection, routing)
```

Every data dependency (hotspots, contacts, panic events, location) is defined as an interface in `core/`, with a mock (`preview/`) and a real (`firebase/` or `device/`) implementation behind it. `app/app_services.dart` is the single place that decides which implementation gets used — this is deliberate, so switching from mock to real backend is a small, focused change rather than a rewrite.

## Tech stack

- **Flutter** (Android is the primary target — reliable background power-button interception isn't available on iOS)
- **Riverpod** for state management, **go_router** for navigation
- **flutter_map** for map rendering (same package intended for a future Flutter Web dashboard)
- **Firebase** (Firestore, Auth) — scaffolded in `data/firebase/`, **not active by default**
- **OSRM** for route calculation
- On-device **speech_to_text** for the voice trigger, **sensors_plus** for fall detection, **vibration** for alerts
- **flutter_localizations** — English, Afrikaans, isiZulu, Sesotho

## Getting started

You do not need a Firebase project, an API key, or any account to run this app — it boots straight into Preview Mode with realistic seeded data.

```bash
flutter pub get
flutter run
```

That's it. You'll be running the same mock-data build used for demos and Play Store review.

### Wiring up a real backend

The Firestore-backed repositories already exist in `lib/data/firebase/` but are **not** wired into `AppServices` by default — calling `Firebase.initializeApp()` without your own generated config would just crash the app on startup. To activate a real backend against your own Firebase project, follow the step-by-step guide in [`lib/data/firebase/README.md`](lib/data/firebase/README.md), which covers `flutterfire configure`, swapping the repository implementations, deploying Firestore security rules, and enabling App Check before any real user data touches it.

### Running tests

```bash
flutter test
```

The test suite focuses on the safety-critical core: the panic controller, geofence alerting, fall detection, and route planning.

## Documentation

- [`SafeHer_SRS.md`](../SafeHer_SRS.md) — the full software requirements spec, including the MVP scope correction and security/privacy constraints
- [`SafeHer_App_Detailed_Overview.md`](../SafeHer_App_Detailed_Overview.md) — a complete, plain-language feature reference
- [`SafeHer_API_Research.md`](../SafeHer_API_Research.md) — research behind the external services this project integrates or considered

## Contributing

Contributions are welcome — especially from anyone adapting this for a different community, city, or country. A few things worth knowing before you dive in:

- **The panic pipeline and location handling are treated as safety-critical.** Any change touching `core/controllers/panic_controller.dart`, geofencing, or authentication should get a closer read than a typical UI change — a bug here doesn't just look bad, it can mean someone doesn't get help.
- **Don't claim a capability that hasn't been proven on real hardware.** If you build out the voice trigger or fall detection further, keep it behind an "experimental, not verified" label until it's actually tested in the field — that's not bureaucracy, it's the one rule this project treats as non-negotiable.
- **Follow the existing interface pattern.** New data sources should implement the relevant `core/repositories/*` interface with a Preview (mock) counterpart, the same way `firebase/` mirrors `preview/` today — it keeps the app runnable with zero setup for anyone who clones it.
- Open an issue to discuss anything non-trivial before a large PR — especially anything that changes the panic escalation behaviour, since that's the one path this project can't afford to get wrong.

## Security & responsible use

This app is designed around a few non-negotiable rules, regardless of who forks it:

- **Never imply an automatic police/emergency-services dispatch that doesn't exist.** A panic trigger that silently fails to reach anyone is worse than no app at all — every panic surface must state plainly who it actually reaches.
- **Location data is opt-in and minimal.** Live location should only ever be visible to a user's chosen contacts, only during an active alert — never persistent tracking.
- **Voice processing stays on-device.** If you extend the voice trigger, raw audio should never leave the phone.
- **Abuse-case thinking is part of the spec, not an afterthought** — e.g. the UI never reveals to someone else holding the phone that a panic event is in progress, and the next-of-kin list requires re-authentication to view or edit.

If you find a security or privacy issue, please report it privately (e.g. via a GitHub security advisory on your fork, or directly to a maintainer) rather than opening a public issue, given the safety-critical nature of this app's data.

## License

MIT — see [`LICENSE`](../LICENSE). Use it, fork it, build on it, and if it helps someone stay safer somewhere else in the world, that's the whole point.
