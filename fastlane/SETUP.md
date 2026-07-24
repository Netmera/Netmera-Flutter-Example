# Fastlane Setup

## Prerequisites

### 1. Install dependencies

```bash
bundle install
bundle exec fastlane install_plugins
```

### 2. Secret files (gitignored — already present in this working tree)

These are already present in this working tree. If any are missing (fresh clone, new machine),
here's what each is and how to obtain it:

**`fastlane/.env`**
Environment variables for all sensitive configuration:

```bash
APPLE_ID=your.email@netmera.com
APPLE_TEAM_ID=XXXXXXXXXX         # Apple Developer Portal Team ID
ITC_TEAM_ID=XXXXXXXXX            # App Store Connect Team ID
ASC_KEY_ID=XXXXXXXXXX            # App Store Connect API Key ID
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
MATCH_PASSWORD=                  # Passphrase for certs repo encryption
MATCH_GIT_URL=git@github.com:Netmera/netmera-ios-certs.git
```

**`fastlane/Netmera_Auth_Key.p8`**
App Store Connect API key used for TestFlight upload.
Ask a team member or re-download from App Store Connect → Users & Access → Integrations → App Store Connect API.

**`fastlane/netmera-cross-examples-firebase-adminsdk.json`**
Firebase service account used for Android App Distribution authentication.
Ask a team member or download from Firebase Console → `netmera-cross-examples` → Project Settings → Service Accounts → Generate new private key.

### 3. SSH access

Make sure your SSH key has access to the certs repo defined in `MATCH_GIT_URL`.
Run once to confirm the fingerprint:

```bash
ssh -T git@github.com
```

### 4. First-time match setup for this app's bundle IDs

`match` here covers three bundle IDs:
`com.netmera.demo.flutter`, `com.netmera.demo.flutter.nse`, `com.netmera.demo.flutter.nce`.

If the App IDs aren't registered yet in the Apple Developer Portal (Certificates, Identifiers &
Profiles → Identifiers), register them first. Then run once to generate and store profiles for
them in the shared certs repo:

```bash
bundle exec fastlane match appstore
```

(`DEVELOPMENT_TEAM` is already set at the project level and confirmed via `xcodebuild
-showBuildSettings` to resolve correctly for `Runner` and both extension targets — no per-target
fix needed.)

---

## Usage

```bash
# iOS → TestFlight
bundle exec fastlane ios release

# Android → Firebase App Distribution
bundle exec fastlane android release

# With release notes
bundle exec fastlane ios release notes:"3.2.0-beta03 release"
bundle exec fastlane android release notes:"3.2.0-beta03 release"
```

---

## Version number logic

Version is read automatically from `netmera_flutter_sdk` in `pubspec.yaml`:

| pubspec.yaml | iOS Version | iOS Build | Android versionName | Android versionCode |
|---|---|---|---|---|
| `3.2.0-beta03` | `3.2.0` | `3` | `3.2.0-beta03` | `1` |
| `3.2.0-alpha01` | `3.2.0` | `1` | `3.2.0-alpha01` | `1` |
| `3.2.0` | `3.2.0` | `1` | `3.2.0` | `1` |

---

## Available Actions

### `ios release`

```sh
bundle exec fastlane ios release
```

Syncs provisioning profiles (match), runs `flutter pub get` and `pod install`, bumps the
version/build on `Runner.xcodeproj`, builds an IPA, and uploads it to TestFlight.

### `android release`

```sh
bundle exec fastlane android release
```

Updates `versionName`/`versionCode` in `android/app/build.gradle`, runs `flutter pub get`, builds
a release APK, and uploads it to Firebase App Distribution → `netmera-testers` group.
