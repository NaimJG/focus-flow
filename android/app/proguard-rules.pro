## Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

## Isar
-keep class dev.isar.** { *; }
-keepclassmembers class * {
    @dev.isar.isar.annotation.* <fields>;
}
