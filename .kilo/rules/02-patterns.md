\# Coding Patterns

\- NEVER use setState in business logic; use Riverpod.

\- NEVER use ! operator; use ?. and ?? instead.

\- ALWAYS check context.mounted after await.

\- ALWAYS wrap Supabase calls in try/catch (PostgrestException).

\- NEVER modify \*.g.dart files.

\## Device Interaction (fdb)

\- After editing UI files, run: fdb reload

\- To verify UI changes: fdb screenshot

\- Device ID: SOAYYD7HEE65QKY5

\- Hot restart (when state is broken): fdb restart

