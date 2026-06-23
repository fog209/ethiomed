# EthioMed — AI Agent Rules

## Tech Stack
Flutter + Dart · Supabase · Drift + SQLite · Riverpod · Chapa · Firebase (Phase 4 ONLY)

## Commands
flutter run · flutter build apk --release · flutter analyze · dart format . · flutter test · flutter pub get

## Folder Structure
lib/ main.dart · app/ · features/auth/ articles/ flashcards/ payment/ · shared/models/ services/ widgets/ · database/

## Strict Rules
- Riverpod for ALL state. NEVER setState in business logic.
- Drift for ALL local DB. NEVER raw SQLite.
- flutter_secure_storage for JWT. NEVER SharedPreferences for secrets.
- dio for ALL HTTP. NEVER raw http package.
- ALL Supabase calls: try/catch with PostgrestException.
- NEVER print(). Use debugPrint() only.
- NEVER hardcode API keys. Use AppConfig class.
- NEVER use ! operator unless certain. Use ?. and ?? instead.
- ALWAYS const constructors where possible.
- ALWAYS check context.mounted after await before using BuildContext.

## ABSOLUTE DO NOTS
Do NOT touch /generated folders · Do NOT add packages without asking ·
Do NOT change pubspec.yaml without instruction · Do NOT delete files without confirmation ·
Do NOT change Supabase schema without confirmation · Do NOT add Firebase before Phase 4 ·
Do NOT expose Supabase keys · Do NOT skip error handling · Do NOT use dynamic type

## Error Handling (always use this pattern)
try {
  final result = await supabase.from('table').select();
  return result;
} on PostgrestException catch (e) {
  debugPrint('DB error: ${e.message}');
  throw AppException(e.message);
} catch (e) {
  debugPrint('Error: $e');
  throw AppException('Something went wrong');
}
# WardReady — Coding Agent Instructions

## Project
Flutter Android app. Path: C:\Users\TestUser\ethiomed\
Flutter: C:\flutter\bin\flutter.bat

## Rules (MANDATORY — not optional)
- Riverpod ALL state. NEVER setState in business logic.
- Drift ALL local DB. NEVER raw SQLite.
- flutter_secure_storage for secrets. NEVER SharedPreferences for secrets.
- dio ALL HTTP. NEVER raw http package.
- ALL Supabase calls: try/catch with PostgrestException FIRST, then catch (e).
- NEVER print() — debugPrint() only.
- NEVER use ! unless certain non-null. Use ?. and ?? everywhere else.
- ALWAYS const constructors where possible.
- ALWAYS context.mounted check after every await in a Widget.
- Do NOT touch *.g.dart files — ever.
- Do NOT add Firebase.
- Do NOT change pubspec.yaml.
- Do NOT use Navigator.push/pop — use context.go() / context.pop() via GoRouter.
- dispose() must ONLY call controller.dispose(), subscription.cancel(), focusNode.dispose().

## After every task
1. Run: C:\flutter\bin\flutter.bat analyze
2. Zero errors required before reporting done.
3. If task touched app_database.dart: run dart run build_runner build --delete-conflicting-outputs FIRST.

## Never rerun these (already done)
- SM-2 wiring, Learning Radar, High-Yield toggle, Streak bars, Unit tests

## Colors
Navy: #1A237E | Gold: #F9A825