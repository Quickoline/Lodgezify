#!/bin/bash

# iOS Build Script for Lodgezify v1.0.0
# This script builds the iOS app for App Store Connect (First Release)

echo "🚀 Starting iOS build process for Lodgezify v1.0.0 (First Release)..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS app for release
echo "🔨 Building iOS app for release..."
echo "⚠️  Note: iOS builds require macOS with Xcode installed"
echo "📱 Opening Xcode project for manual build..."
open ios/Runner.xcworkspace

echo "✅ Flutter dependencies ready!"
echo "📱 Xcode project opened for manual build"
echo ""
echo "📋 Next steps in Xcode:"
echo "1. Select 'Any iOS Device (arm64)' as the destination"
echo "2. Go to Product > Archive"
echo "3. Once archived, click 'Distribute App'"
echo "4. Choose 'App Store Connect'"
echo "5. Follow the upload process"
echo ""
echo "🔧 Alternative: Use Transporter app or altool command line"
echo "   altool --upload-app -f build/ios/iphoneos/Runner.app -u your_apple_id -p your_app_specific_password"
echo ""
echo "⚠️  Note: iOS builds require macOS with Xcode installed"
echo "💡 For Windows/Linux: Use a Mac or cloud build service like Codemagic"
