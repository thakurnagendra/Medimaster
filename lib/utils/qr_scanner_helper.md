# QR Code Scanner Configuration Guide

## Problem: "A problem occurred configuring project ':qr_code_scanner'"

This error typically occurs when there's a mismatch between the Android Gradle plugin version and the QR scanner plugin requirements.

## How to Fix:

### 1. Check Android Gradle Plugin Version

In your `android/build.gradle` file, ensure you have the correct Gradle plugin version:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.4' // Try version 7.0.4 or 4.2.2
    }
}
```

### 2. Update Gradle Wrapper Properties

In your `android/gradle/wrapper/gradle-wrapper.properties` file, update the Gradle version:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.4-all.zip
```

### 3. Add Camera Permissions in AndroidManifest.xml

In `android/app/src/main/AndroidManifest.xml`, add the following permissions:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

### 4. Configure iOS

In your `ios/Runner/Info.plist`, add:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

### 5. Run Flutter Clean

Execute these commands in your terminal:

```bash
flutter clean
flutter pub get
```

### 6. Alternative: Use a Different QR Scanner Package

If the issue persists, consider using an alternative package like `mobile_scanner` or `barcode_scan2`.

```yaml
# In pubspec.yaml
dependencies:
  mobile_scanner: ^3.5.5
  # OR
  barcode_scan2: ^4.2.4
```

## Potential Issues:

1. **Kotlin Version**: Ensure Kotlin version is compatible (in android/build.gradle):
   ```gradle
   ext.kotlin_version = '1.7.10'
   ```

2. **minSdkVersion**: Set the minimum SDK version in android/app/build.gradle:
   ```gradle
   defaultConfig {
       minSdkVersion 21
   }
   ```

3. **Compatibility**: The qr_code_scanner package might not be fully compatible with the latest Flutter versions. Consider switching to a more actively maintained package if issues persist. 