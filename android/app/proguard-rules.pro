# Add project specific ProGuard rules here.
# Conservative rules to prevent crashes

# Flutter specific rules - keep everything Flutter related
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep plugin classes
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }
-keep class * extends io.flutter.plugin.common.MethodCallHandler { *; }

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# Keep model classes
-keep class com.lodgezify.app.models.** { *; }
-keep class com.lodgezify.app.data.** { *; }

# Keep all classes in the main package
-keep class com.lodgezify.app.** { *; }

# Conservative optimization
-dontwarn **
-dontoptimize
-dontobfuscate
