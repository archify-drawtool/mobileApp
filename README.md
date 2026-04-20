# Archify Mobile App

The Archify Mobile App for capturing and digitizing IT landscape sketches during client sessions.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # Full-screen pages
│   ├── camera_screen.dart            # Camera with live preview
│   ├── camera_permission_screen.dart # First-launch permission request
│   ├── camera_denied_screen.dart     # Shown when camera is denied
│   └── photo_preview_screen.dart     # Preview with accept/retake
├── services/              # API and business logic
│   ├── api_service.dart              # API calls (health check, photo upload)
│   └── photo_service.dart            # Photo orientation fix
├── widgets/               # Reusable UI components
│   ├── archify_logo.dart             # Logo with colored "fy"
│   ├── screen_badge.dart             # Badge in top right (CAMERA, PREVIEW)
│   ├── camera_preview_box.dart       # Camera preview with border
│   └── photo_preview_box.dart        # Photo preview with border
├── theme/                 # Colors, text styles, theme
│   └── app_theme.dart                # AppColors, AppTextStyles, AppTheme
└── models/                # Data models (future)
```

## Getting Started

### 1. Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for Android emulator, required on all platforms)
- Xcode (Mac only, for iOS simulator and physical iPhone testing)
- A code editor (IntelliJ IDEA, VS Code, or Android Studio)

### 2. Verify installation

Run this in your terminal to check if everything is set up correctly:

```bash
flutter doctor
```

All checkmarks should be green. If something is missing, follow the instructions it gives you.

### 3. Clone and install

```bash
git clone https://github.com/archify-cbyte/mobileApp.git
cd mobileApp
flutter pub get
```

`flutter pub get` installs all packages listed in `pubspec.yaml`. Similar to `npm install` in Nuxt or `composer install` in Laravel. You need to run this every time you pull new changes that added packages.

### 4. Set up an Android emulator

1. Open Android Studio
2. Go to Device Manager (phone icon in the right sidebar)
3. Click "Create Virtual Device"
4. Choose a phone (e.g. Pixel 8)
5. Select an Android version and click Finish
6. Start the emulator with the play button

### 5. Run the app

The app needs to know where the Laravel API is running. You pass this as an environment variable:

**Android emulator (Windows or Mac):**
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

Why `10.0.2.2`? The Android emulator can't use `localhost` because that points to the emulator itself. `10.0.2.2` is a special address that points to your computer.

**iOS simulator (Mac only):**
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

**With Laravel Herd:**
```bash
flutter run --dart-define=API_URL=http://webapi.test/api
```

If you don't pass `--dart-define`, the app defaults to `http://localhost:8000/api`.

### 6. Make sure the backend is running

The app connects to the Laravel API. Without it running, photo uploads won't work and you'll see "Could not connect to API". In a separate terminal:

```bash
cd webApi
php artisan serve
```

If you use Laravel Herd, the API is already running automatically.

## Debugging Guide

### Which device should I use?

| Situation | Best option |
|---|---|
| Daily development | Android emulator |
| Camera testing on Android | Android emulator (has simulated camera) |
| Camera testing on iOS | Physical iPhone in release mode |
| UI testing on iOS | iOS simulator (no camera available) |
| Testing photo upload | Android emulator with Laravel running |

For most development, use the Android emulator. It has a simulated camera, supports hot reload, and doesn't have the iOS debug limitations.

### Hot reload

While the app is running via `flutter run`, you can:

- Press **r** for hot reload (instant UI updates, keeps state)
- Press **R** for hot restart (restarts the app, resets state)
- Press **q** to quit

This is the fastest way to see your changes.

### Running on Android emulator

1. Open Android Studio → Device Manager → Start an emulator
2. Run:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

### Running on iOS simulator

1. Open the simulator:
```bash
open -a Simulator
```
2. Run:
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

Note: camera is not available in the iOS simulator. You can test the rest of the UI but not the actual camera.

### Testing on a physical iPhone

Debug mode on iOS has known limitations with camera apps — iOS kills the app when you switch away. Use release mode instead:

1. Find your Mac's IP address:
```bash
ipconfig getifaddr en0
```

2. Start Laravel so it listens on all interfaces:
```bash
php artisan serve --host=0.0.0.0
```

3. Build the app with your IP:
```bash
flutter build ios --release --dart-define=API_URL=http://YOUR-IP:8000/api
```

4. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

5. In Xcode: set scheme to **Release**, select your iPhone, then **Product → Run**

Important: your Mac and iPhone must be on the same Wi-Fi network.

Note: with a free Apple developer account, the app expires after 7 days and needs to be reinstalled.

### Testing on a physical Android device

1. Enable Developer Mode on your phone (Settings → About Phone → tap Build Number 7 times)
2. Enable USB Debugging in Developer Options
3. Connect via USB
4. Run:
```bash
flutter run --dart-define=API_URL=http://<your-mac-ip>:8000/api
```

### Common issues

| Problem | Solution |
|---|---|
| `command not found: flutter` | Flutter not in PATH, check installation |
| App shows "Could not connect to API" | Make sure Laravel is running with `php artisan serve` |
| App shows "Upload duurde te lang" | Check your network connection and if Laravel is running |
| iOS app crashes when switching apps | Normal iOS behavior, app restarts automatically |
| iOS app crashes when changing permissions | Normal iOS behavior, app restarts automatically |
| Android permission loop | Wipe app data in emulator settings and restart |
| Red screen with errors after pull | Run `flutter pub get` |
| Camera preview looks stretched | Make sure `lockCaptureOrientation` is in `_initCamera` |
| Uploaded photos are rotated | `PhotoService.fixOrientation` handles this automatically |
| `flutter run` asks to choose between macOS/Chrome | Start an Android emulator first, or use `open -a Simulator` for iOS |

## Running Tests

```bash
flutter test
```

This runs all widget and unit tests in the `test/` folder. Tests must pass before merging a PR.

## Useful Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies (run after every pull) |
| `flutter pub add <package>` | Add a new package |
| `flutter clean` | Clear build files (fixes weird build issues) |
| `flutter devices` | Show available devices |
| `flutter test` | Run all tests |
| `flutter analyze` | Run linter checks |
| `flutter run` | Run the app in debug mode |
| `flutter run --release` | Run the app in release mode |
| `flutter build ios --release` | Build iOS release (for physical iPhone) |
| `flutter build apk --release` | Build Android APK |

## Code Conventions

See `Code_Conventions.docx` for the full naming and style rules. Here are the Flutter-specific rules:

- **Files:** snake_case (`camera_screen.dart`)
- **Classes:** PascalCase (`CameraScreen`)
- **Variables and methods:** camelCase (`_initCamera`, `_isReady`)
- **Private members:** underscore prefix (`_controller`)
- **Colors:** always use `AppColors`, never hardcoded hex values
- **Text styles:** always use `AppTextStyles`, never inline styles for heading/body
- **Icons:** use `lucide_icons` package, not Material Icons
- **Fonts:** use `google_fonts` package (Syne for headings, Nunito for body)
- **Buttons:** square corners (configured globally in `AppTheme`)
- **New screens:** go in `lib/screens/`
- **Reusable UI:** go in `lib/widgets/`
- **Business logic:** go in `lib/services/`, not in screens
- **Use `const`** wherever possible
- **No commented-out code** in commits
- **Commit messages** in English
