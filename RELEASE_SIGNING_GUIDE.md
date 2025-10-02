# Lodgezify Release Signing Guide

## 🔐 Production Signing Setup

### Step 1: Generate Release Keystore
Run the provided script to create your production keystore:

```bash
# Windows
generate_keystore.bat

# Or manually with keytool
keytool -genkey -v -keystore android/app/lodgezify-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lodgezify-key
```

### Step 2: Update Key Properties
Edit `android/key.properties` with your actual credentials:

```properties
storePassword=your_actual_store_password
keyPassword=your_actual_key_password  
keyAlias=lodgezify-key
storeFile=../app/lodgezify-release-key.jks
```

### Step 3: Secure Your Keystore
- **BACKUP**: Store `lodgezify-release-key.jks` in a secure location
- **PASSWORD**: Remember your passwords - you'll need them for all future updates
- **VERSION CONTROL**: Never commit the keystore or key.properties to git

## 📱 Building Release Versions

### For Testing (Debug Signing)
```bash
flutter build apk --release
flutter build appbundle --release
```

### For Production (Release Signing)
```bash
flutter build apk --release
flutter build appbundle --release
```

## 🚀 Play Store Deployment

### First Release
1. Upload the AAB file to Play Console
2. Complete store listing
3. Submit for review

### Future Updates
1. Increment version in `pubspec.yaml`
2. Build new AAB with same keystore
3. Upload to Play Console
4. The same keystore must be used for all updates

## ⚠️ Important Notes

### Keystore Security
- **LOSE IT = LOSE APP**: If you lose the keystore, you cannot update your app
- **BACKUP**: Store multiple copies in secure locations
- **PASSWORDS**: Write down passwords in a secure password manager

### Version Management
- Update `version` in `pubspec.yaml` for each release
- Use semantic versioning: `1.0.0+1` (version+build)
- Build number must increase for each release

### File Locations
- **Keystore**: `android/app/lodgezify-release-key.jks`
- **Key Config**: `android/key.properties`
- **APK Output**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB Output**: `build/app/outputs/bundle/release/app-release.aab`

## 🔄 Update Process

For each new version:
1. Update version in `pubspec.yaml`
2. Make code changes
3. Test thoroughly
4. Build with: `flutter build appbundle --release`
5. Upload new AAB to Play Console
6. Use the SAME keystore for all updates

## 🛡️ Security Best Practices

1. **Never share** the keystore file
2. **Use strong passwords** for keystore and key
3. **Backup securely** - multiple encrypted copies
4. **Version control** - add keystore files to .gitignore
5. **Team access** - only trusted developers should have keystore access

## 📋 Checklist for Each Release

- [ ] Version updated in pubspec.yaml
- [ ] Code changes tested
- [ ] Keystore available and accessible
- [ ] key.properties configured correctly
- [ ] AAB built successfully
- [ ] AAB uploaded to Play Console
- [ ] Release notes prepared
- [ ] Keystore backed up securely
