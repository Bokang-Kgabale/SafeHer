# Firebase-backed repositories (P1 scaffolding — not active yet)

The classes in this folder implement the same repository interfaces as the
`data/preview/*` implementations, targeting Cloud Firestore instead of an
in-memory mock. **`AppServices` still defaults to the Preview repositories —
nothing here runs today.** This exists so switching over is a small, focused
change once Firebase is actually configured, rather than a rewrite.

## Why this isn't wired in yet

Activating Firebase requires the project owner's own Firebase project and
Google account login (`flutterfire configure`), which can't be done from
here. Attempting to call `Firebase.initializeApp()` without valid generated
config (`firebase_options.dart`, `google-services.json`) would crash the app
on startup — so `main.dart` deliberately never calls it.

## Activation steps (do this yourself, then flip the switch below)

1. `dart pub global activate flutterfire_cli`
2. `flutterfire configure` — log in, select/create a Firebase project, select
   Android (this app's only real target per the SRS) — this generates
   `lib/firebase_options.dart` and the platform config files.
3. In `lib/main.dart`, before `runApp(...)`:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
4. In `lib/app/app_services.dart`, swap the `late final ... = Preview...()`
   fields for the corresponding classes in this folder (e.g.
   `FirestoreHotspotRepository()` instead of `PreviewHotspotRepository()`).
5. Deploy Firestore security rules — see `SafeHer_SRS.md` §6.3 and §8.3 for
   the intended access-control shape (SEC-1) before writing any real data;
   these classes do not enforce access control themselves, Firestore rules
   must.
6. Enable Firebase App Check (SEC-4) before any public/pilot use.

None of this has been run or tested against a real Firebase project — treat
it as a reviewed starting point, not a verified integration.
