# iOS Release Guide for Lodgezify v1.0.0

## 📱 App Information
- **App Name**: Lodgezify
- **Version**: 1.0.0 (Build 1)
- **Bundle ID**: com.lodgezify.app
- **Platform**: iOS
- **Minimum iOS Version**: iOS 12.0+

## 🚀 Pre-Release Checklist

### 1. App Store Connect Setup
- [ ] Create app record in App Store Connect
- [ ] Set up app information, description, and metadata
- [ ] Upload app screenshots (required sizes: 6.7", 6.5", 5.5", 12.9", 11")
- [ ] Set up app categories and keywords
- [ ] Configure app pricing and availability

### 2. Build Configuration
- [x] Version set to 1.0.0+1
- [x] Bundle identifier configured
- [x] App display name set to "Lodgezify"
- [x] iOS deployment target set to 12.0+

### 3. Required Assets
- [ ] App icon (1024x1024px)
- [ ] Launch screen
- [ ] App screenshots for all required device sizes
- [ ] App description and keywords

## 🔨 Build Process

### Option 1: Using Build Script (macOS only)
```bash
# Make script executable
chmod +x build_ios.sh

# Run the build script
./build_ios.sh
```

### Option 2: Manual Build (macOS only)
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Open Xcode project
open ios/Runner.xcworkspace
```

### Option 3: Windows/Linux Users
**iOS builds require macOS with Xcode. Options:**
1. **Use a Mac**: Access a Mac computer with Xcode installed
2. **Cloud Build Services**: 
   - Codemagic (recommended for Flutter)
   - GitHub Actions with macOS runners
   - Bitrise
   - AppCenter
3. **Virtual Mac**: Use cloud Mac services like MacStadium

## 📦 Upload to App Store Connect

### Method 1: Using Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device (arm64)" as destination
3. Go to **Product > Archive**
4. Once archived, click **"Distribute App"**
5. Choose **"App Store Connect"**
6. Follow the upload wizard

### Method 2: Using Transporter App
1. Download Transporter from Mac App Store
2. Open Transporter
3. Drag the `.ipa` file to Transporter
4. Click "Deliver" to upload

### Method 3: Using Command Line (altool)
```bash
# Upload using altool
altool --upload-app \
  -f build/ios/iphoneos/Runner.app \
  -u your_apple_id@example.com \
  -p your_app_specific_password
```

## 📋 Post-Upload Steps

1. **Wait for Processing**: Apple will process your build (usually 10-60 minutes)
2. **TestFlight**: Upload will automatically create a TestFlight build
3. **App Review**: Submit for App Store review
4. **Release**: Once approved, release to App Store

## ☁️ Cloud Build Services (Windows/Linux Users)

### Codemagic (Recommended)
1. **Setup**: Connect your GitHub repository to Codemagic
2. **Configuration**: Use the provided `codemagic.yaml` (create if needed)
3. **Build**: Automatic builds on every commit
4. **Upload**: Direct upload to App Store Connect

### GitHub Actions
```yaml
# .github/workflows/ios.yml
name: iOS Build
on: push
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release
```

### AppCenter
1. **Setup**: Create project in AppCenter
2. **Connect**: Link your repository
3. **Build**: Configure iOS build settings
4. **Distribute**: Upload to App Store Connect

## 🔧 Troubleshooting

### Common Issues:
- **Code signing errors**: Ensure proper certificates and provisioning profiles
- **Build failures**: Check iOS deployment target and dependencies
- **Upload failures**: Verify bundle ID matches App Store Connect
- **Windows/Linux**: Use cloud build services or access a Mac

### Build Commands (macOS only):
```bash
# Clean build
flutter clean && flutter pub get

# Check dependencies
flutter doctor

# Open Xcode
open ios/Runner.xcworkspace
```

## 📱 App Store Connect Requirements

### Required Information:
- App name and subtitle
- App description (up to 4000 characters)
- Keywords (up to 100 characters)
- Support URL
- Marketing URL (optional)
- Privacy Policy URL (required for apps that collect data)

### Screenshots Required:
- iPhone 6.7" (iPhone 14 Pro Max): 1290 x 2796 pixels
- iPhone 6.5" (iPhone 11 Pro Max): 1242 x 2688 pixels  
- iPhone 5.5" (iPhone 8 Plus): 1242 x 2208 pixels
- iPad Pro 12.9": 2048 x 2732 pixels
- iPad Pro 11": 1668 x 2388 pixels

## 🎯 Release Timeline

1. **Build & Upload**: 1-2 hours
2. **Apple Processing**: 10-60 minutes
3. **TestFlight Testing**: 1-7 days (optional)
4. **App Review**: 24-48 hours
5. **App Store Release**: Immediate after approval

## 📞 Support

For technical issues:
- Check Flutter documentation
- Review Apple Developer Guidelines
- Contact Apple Developer Support

---
**Version**: 1.0.0  
**Last Updated**: October 2025  
**Build**: 1
