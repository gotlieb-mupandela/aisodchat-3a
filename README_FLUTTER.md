# AisodChat Flutter Migration

This repository now runs as a Flutter app.

## Local setup

1. Install Flutter stable and run `flutter doctor`.
2. From project root, run:
   - `flutter create . --platforms=android,ios`
   - `flutter pub get`
3. Configure `.env` values (Supabase URL and anon key).
4. Run app:
   - `flutter run`

## Build artifacts

- Android APK: `flutter build apk --release`
- Android AAB: `flutter build appbundle --release`
- iOS release (unsigned): `flutter build ios --release --no-codesign`

## GitHub Actions

Workflows live in `.github/workflows/`:

- `flutter-qa.yml`: analyze + tests
- `android-build.yml`: build APK and AAB artifacts
- `ios-build.yml`: build iOS release artifacts

## Secrets guidance

- Keep only public client keys in app env.
- Never store Supabase service role or other server secrets in mobile app code.
