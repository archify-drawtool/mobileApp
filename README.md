# Archify Mobile App

The Archify Mobile App for capturing and digitizing IT landscape sketches.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # Full-screen pages
├── services/              # API and business logic
├── widgets/               # Reusable UI components
├── theme/                 # Colors, text styles, theme
└── models/                # Data models
```

## Getting Started

### 1. Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for Android emulator)
- Xcode (Mac only, for iOS simulator)

### 2. Verify installation

```bash
flutter doctor
```

### 3. Clone and install

```bash
git clone https://github.com/archify-cbyte/mobileApp.git
cd mobileApp
flutter pub get
```

`flutter pub get` installs all packages listed in `pubspec.yaml`. Similar to `npm install` in Nuxt or `composer install` in Laravel.

### 4. Run the app

Choose the command for your setup:

**Android emulator (Windows or Mac):**
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

**iOS simulator (Mac only):**
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

**With Laravel Herd:**
```bash
flutter run --dart-define=API_URL=http://webapi.test/api
```

## Debugging Guide

### Which device should I use?

| Situation | Best option |
|---|---|
| Daily development | Android emulator |
| Camera testing on Android | Android emulator (has simulated camera) |
| Camera testing on iOS | Physical iPhone in release mode |
| UI testing on iOS | iOS simulator (no camera available) |

### Android emulator

1. Open Android Studio → Device Manager → Start an emulator
2. Run:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

### iOS simulator

1. Open the simulator:
```bash
open -a Simulator
```
2. Run:
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

Note: camera is not available in the iOS simulator.

### Physical iPhone

Debug mode on iOS has known limitations with camera apps. Use release mode:

```bash
flutter build ios --release
open ios/Runner.xcworkspace
```

In Xcode: set scheme to Release, select your iPhone, then Product → Run.

Note: iOS restarts the app when you change camera permissions in Settings. This is normal iOS behavior.

### Physical Android device

1. Enable Developer Mode on your phone
2. Connect via USB
3. Run:
```bash
flutter run --dart-define=API_URL=http://<your-mac-ip>:8000/api
```

## Running Tests

```bash
flutter test
```

## Useful Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter pub add <package>` | Add a package |
| `flutter clean` | Clear build files |
| `flutter devices` | Show available devices |
| `flutter test` | Run all tests |
| `flutter analyze` | Run linter checks |

## Common Issues

| Problem | Solution |
|---|---|
| `command not found: flutter` | Flutter not in PATH, check installation |
| App shows "Could not connect to API" | Make sure Laravel is running with `php artisan serve` |
| iOS app crashes when switching apps | Normal behavior, app restarts automatically |
| Android permission loop | Wipe app data in emulator settings and restart |
| Red screen with errors after pull | Run `flutter pub get` |

## Code Conventions

See `Code_Conventions.docx` for naming and style rules. All colors must use `AppColors`, all text styles must use `AppTextStyles`.
