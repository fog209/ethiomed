# WardReady R8 / ProGuard Rules
# Flutter Dart code is compiled to native ARM — these rules protect only the
# Java/Kotlin Android-side code. Drift, Supabase, Riverpod, GoRouter are all
# Dart packages and do not need Java-side keep rules.

# ── Flutter engine ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keepclassmembers class io.flutter.** { *; }

# ── WardReady Activity and Application ───────────────────────────────────────
-keep class com.wardready.app.MainActivity { *; }
-keep class com.wardready.app.** { *; }

# ── Android framework ─────────────────────────────────────────────────────────
-keep class * extends android.app.Activity { *; }
-keep class * extends android.app.Application { *; }
-keep class * extends android.app.Service { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * extends android.content.ContentProvider { *; }

# ── Parcelable ────────────────────────────────────────────────────────────────
-keep class * implements android.os.Parcelable { *; }
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# ── Enums ─────────────────────────────────────────────────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ── Serializable ──────────────────────────────────────────────────────────────
-keep class * implements java.io.Serializable { *; }

# ── Native methods ────────────────────────────────────────────────────────────
-keepclasseswithmembernames class * {
    native <methods>;
}

# ── flutter_secure_storage (Java plugin side) ─────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }

# ── shared_preferences (Java plugin side) ─────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── Attributes needed by Flutter / OkHttp / Ktor ─────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes LineNumberTable
-keepattributes SourceFile

# ── Suppress harmless warnings ────────────────────────────────────────────────
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn com.android.org.conscrypt.**
-dontwarn sun.security.**
-dontwarn java.beans.**
-dontwarn java.lang.ClassValue

# ── Flutter deferred components (Play Core — not used by this app) ────────────
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
