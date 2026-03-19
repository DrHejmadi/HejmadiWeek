---
name: "TestFlight Deploy"
description: "Build, archive, and upload iOS apps to TestFlight via CLI using xcodebuild and App Store Connect API key. Use when the user wants to push a build to TestFlight, upload to App Store Connect, deploy, or distribute the app."
---

# TestFlight Deploy

Automatiseret build, archive og upload til TestFlight via kommandolinjen.

## Forudsætninger

- XcodeGen projekt med `project.yml`
- App Store Connect API key: `/Users/michaelhejmadi/private_keys/AuthKey_TY739G8578.p8`
- Key ID: `TY739G8578`
- Issuer ID: `69a6de72-2c50-47e3-e053-5b8c7c11a4d1`
- Team ID: `LB2RAFK9K9`
- Bundle ID: `com.hejmadi.HejmadiWeek`
- App ID: `6760618530`

## Workflow

### 1. Bump build number

Opdater `CURRENT_PROJECT_VERSION` i `project.yml` (increment med 1).

### 2. Regenerer Xcode projekt

```bash
xcodegen generate
```

### 3. Archive

```bash
xcodebuild -project HejmadiWeek.xcodeproj \
  -scheme HejmadiWeek \
  -destination generic/platform=iOS \
  -archivePath /tmp/HejmadiWeek.xcarchive \
  archive -quiet
```

Verificer: `ls /tmp/HejmadiWeek.xcarchive/Products/Applications/HejmadiWeek.app`

### 4. Export og upload

Opret `/tmp/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>LB2RAFK9K9</string>
</dict>
</plist>
```

Upload:

```bash
xcodebuild -exportArchive \
  -archivePath /tmp/HejmadiWeek.xcarchive \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -exportPath /tmp/HejmadiWeekExport \
  -allowProvisioningUpdates \
  -authenticationKeyPath /Users/michaelhejmadi/private_keys/AuthKey_TY739G8578.p8 \
  -authenticationKeyID TY739G8578 \
  -authenticationKeyIssuerID 69a6de72-2c50-47e3-e053-5b8c7c11a4d1
```

Forventet output: `** EXPORT SUCCEEDED **`

### 5. Git commit og push

```bash
git add -A
git commit -m "Build N: [beskrivelse]

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push origin main
```

### 6. Verificer i App Store Connect

Tjek build status: `https://appstoreconnect.apple.com/apps/6760618530/testflight/ios`

## Fejlfinding

- **"Failed to Use Accounts"**: Brug API key auth (trin 4) i stedet for Xcode GUI
- **"Provisioning profile doesn't include signing certificate"**: Brug `--allowProvisioningUpdates` med API key
- **"duplicate build"**: Bump `CURRENT_PROJECT_VERSION` i project.yml
- **Archive fejler**: Tjek at scheme og destination er korrekt med `xcodebuild -list`

## Hurtig one-liner

For at køre hele flowet:

```bash
# Bump, build, upload
NEW_BUILD=$(($(grep CURRENT_PROJECT_VERSION project.yml | tr -dc '0-9') + 1)) && \
sed -i '' "s/CURRENT_PROJECT_VERSION: \"[0-9]*\"/CURRENT_PROJECT_VERSION: \"$NEW_BUILD\"/" project.yml && \
xcodegen generate && \
xcodebuild -project HejmadiWeek.xcodeproj -scheme HejmadiWeek -destination generic/platform=iOS -archivePath /tmp/HejmadiWeek.xcarchive archive -quiet && \
xcodebuild -exportArchive -archivePath /tmp/HejmadiWeek.xcarchive -exportOptionsPlist /tmp/ExportOptions.plist -exportPath /tmp/HejmadiWeekExport -allowProvisioningUpdates -authenticationKeyPath /Users/michaelhejmadi/private_keys/AuthKey_TY739G8578.p8 -authenticationKeyID TY739G8578 -authenticationKeyIssuerID 69a6de72-2c50-47e3-e053-5b8c7c11a4d1 && \
echo "Build $NEW_BUILD uploaded to TestFlight!"
```
