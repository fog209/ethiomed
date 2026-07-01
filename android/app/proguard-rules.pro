-keep class io.requery.** { *; }
-keep class androidx.sqlite.** { *; }
-keep @androidx.room.Database class * { *; }
-keepclassmembers class * extends drift.** { *; }
-dontwarn drift.**

# Riverpod generated classes (code-gen uses $ prefix)
-keep class *$$** { *; }
-keep class riverpod.** { *; }

# GoRouter (compiled routes)
-keep class go_router.** { *; }

# Supabase client (PostgREST, auth, realtime)
-keep class supabase.** { *; }
-keep class gotrue.** { *; }
-keep class postgrest.** { *; }
-keep class realtime.** { *; }
-keep class storage.** { *; }
-keep class functions_client.** { *; }