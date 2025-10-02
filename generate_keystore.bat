@echo off
echo Creating Lodgezify Release Keystore...
echo.

REM Create the keystore directory if it doesn't exist
if not exist "android\app" mkdir "android\app"

REM Generate the keystore
keytool -genkey -v -keystore android\app\lodgezify-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lodgezify-key -storepass lodgezify123 -keypass lodgezify123 -dname "CN=Lodgezify, OU=Development, O=Lodgezify Inc, L=New York, S=NY, C=US"

echo.
echo Keystore created successfully!
echo.
echo IMPORTANT: Update android/key.properties with your actual passwords:
echo storePassword=lodgezify123
echo keyPassword=lodgezify123
echo keyAlias=lodgezify-key
echo storeFile=../app/lodgezify-release-key.jks
echo.
echo Keep this keystore file safe - you'll need it for all future updates!
echo.
pause
