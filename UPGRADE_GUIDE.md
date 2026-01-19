# Bitmap Package - Upgrade Guide

## Version 1.0.1 - Flutter 3.32.5 Compatibility

This version has been upgraded to support Flutter 3.32.5 and the latest build tools.

### What's Changed

#### Flutter & Dart
- ✅ Dart SDK: `>=3.6.0 <4.0.0` (was `>=3.1.0 <4.0.0`)
- ✅ Flutter: `>=3.27.0` (was `>=3.13.9`)
- ✅ FFI package: `^2.2.0` (was `^2.1.0`)

#### Android Build Tools
- ✅ Android Gradle Plugin: `8.9.1` (was `8.1.3`)
- ✅ Gradle: `8.11.1` (was `7.5`)
- ✅ Kotlin: `2.1.0` (was `1.9.0`)
- ✅ Compile SDK: `35` (was `33`)
- ✅ Min SDK: `24` (was `16`)
- ✅ Target SDK: `35`
- ✅ Java: `17` (was `8`)

#### Performance Improvements
- ✅ Enabled Gradle configuration cache
- ✅ Enabled parallel builds
- ✅ Enabled Gradle build caching
- ✅ Optimized JVM arguments
- ✅ Enabled R8 full mode
- ✅ Enabled non-transitive R class

### Breaking Changes

⚠️ **Minimum SDK Version**: The minimum Android SDK has been increased from 16 to 24. This affects devices running Android 6.0 (Marshmallow) and below.

⚠️ **Java Version**: Projects must now use Java 17 (was Java 8).

### Migration Steps

#### 1. Update Your Project's Gradle Files

**`android/build.gradle`:**
```gradle
buildscript {
    ext.kotlin_version = '2.1.0'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.9.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**`android/settings.gradle`:**
```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.9.1" apply false
}
```

**`android/gradle/wrapper/gradle-wrapper.properties`:**
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-all.zip
```

**`android/app/build.gradle`:**
```gradle
android {
    namespace "your.package.name"
    compileSdk 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    defaultConfig {
        minSdk 24
        targetSdk 35
    }
}
```

**`android/gradle.properties`:**
```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
android.enableR8.fullMode=true
android.nonTransitiveRClass=true
android.defaults.buildfeatures.buildconfig=true
```

#### 2. Update pubspec.yaml

```yaml
environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.0"

dependencies:
  bitmap:
    git:
      url: https://github.com/guptan404/bitmap.git
      ref: main
```

#### 3. Clean and Rebuild

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter build apk
```

### Compatibility Matrix

| Bitmap Version | Flutter Version | Dart SDK | Android Gradle Plugin | Gradle | Kotlin | Min SDK |
|----------------|-----------------|----------|----------------------|--------|---------|---------|
| 1.0.1          | ≥3.27.0        | ≥3.6.0   | 8.9.1                | 8.11.1 | 2.1.0   | 24      |
| 1.0.0          | ≥3.13.9        | ≥3.1.0   | 8.1.3                | 7.5    | 1.9.0   | 16      |

### Troubleshooting

#### Build Fails with "Unsupported class file major version"
**Solution**: Ensure you're using Java 17. Check with:
```bash
java -version
```

#### Gradle sync fails
**Solution**: Delete `.gradle` folders and run:
```bash
cd android
./gradlew clean
./gradlew --stop
cd ..
flutter clean
flutter pub get
```

#### Configuration cache problems
**Solution**: If you encounter configuration cache issues, you can disable it temporarily:
```properties
# In gradle.properties
org.gradle.configuration-cache=false
```

#### Out of memory errors
**Solution**: Increase heap size in `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx6G -XX:MaxMetaspaceSize=2G
```

### Testing

After upgrading, test the following:

1. ✅ Image brightness adjustments
2. ✅ Image contrast adjustments  
3. ✅ Color adjustments (saturation, exposure)
4. ✅ Image resize operations
5. ✅ Image flip operations
6. ✅ Image crop operations
7. ✅ Image rotation operations
8. ✅ RGB overlay operations

### Support

If you encounter any issues:
1. Check this upgrade guide
2. Review the example app in the `example/` directory
3. Report issues on GitHub: https://github.com/guptan404/bitmap/issues

### Additional Resources

- [Flutter 3.27+ Release Notes](https://docs.flutter.dev/release/release-notes)
- [Android Gradle Plugin 8.9 Release Notes](https://developer.android.com/build/releases/gradle-plugin)
- [Kotlin 2.1 What's New](https://kotlinlang.org/docs/whatsnew21.html)
- [Gradle 8.11 Release Notes](https://docs.gradle.org/8.11.1/release-notes.html)
