# Release Guide

## Build APK

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

Output: `build\app\outputs\flutter-apk\app-release.apk`

## Signing (Production)

1. Place `key.jks` in `android/app/`
2. Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=key.jks
```
3. Uncomment the signing config in `android/app/build.gradle.kts` under `release`
4. Run `flutter build apk --release`

## Versioning

Update `version` in `pubspec.yaml`:
```
version: 1.0.0+1
         ^^^^^ ^
         |     +-- build number (Android)
         +-------- version name
```

## Notes

- Requires Developer Mode enabled on Windows (symlink support)
- Gradle transform cache issues on Windows: `org.gradle.internal.transform.parallel=false` in `android/gradle.properties`
- `flutter_local_notifications` v22+ requires core library desugaring in `android/app/build.gradle.kts`
