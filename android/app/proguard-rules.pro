# Flutter rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# AndroidX rules
-keep class androidx.** { *; }
-dontwarn androidx.**

# flutter_local_notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# rive rules
-keep class com.rive.** { *; }
-dontwarn com.rive.**

# Multidex rules
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

# Java 8+ APIs for desugaring
-keep class java.time.** { *; }
-dontwarn java.time.**
-keep class java.util.** { *; }
-dontwarn java.util.**