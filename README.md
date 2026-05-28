# Archify Mobile App

The Archify Mobile App for capturing and digitizing IT landscape sketches during client sessions.

## ⚠️ Belangrijk

Naast `php artisan serve` moet je in een aparte terminal ook **`php artisan queue:work`** draaien in `webApi`. Zonder de queue worker blijven geüploade foto's eindeloos op `processing` staan en worden er nooit schetsen aangemaakt.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # Full-screen pages
│   ├── login_screen.dart
│   ├── project_selection_screen.dart
│   ├── camera_screen.dart
│   ├── camera_permission_screen.dart
│   ├── camera_denied_screen.dart
│   ├── photo_preview_screen.dart
│   └── upload_status_screen.dart
├── services/              # API and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── photo_service.dart
│   └── share_service.dart
├── widgets/               # Reusable UI components
│   ├── archify_logo.dart
│   ├── screen_badge.dart
│   ├── camera_preview_box.dart
│   ├── photo_preview_box.dart
│   ├── flash_toggle_button.dart
│   └── status_block.dart
├── theme/                 # Colors, text styles, theme
│   └── app_theme.dart
└── models/                # Data models
    ├── project.dart
    └── upload_stage.dart
```

## Getting Started

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for Android emulator)
- Xcode (Mac only, for iOS)

Run `flutter doctor` to verify your setup.

### 2. Install dependencies

```bash
cd mobileApp
flutter pub get
```

### 3. Set up an Android emulator

1. Open Android Studio → Device Manager
2. Create a virtual device (e.g. Pixel 8) and start it

### 4. Run the backend

In `webApi`, in two separate terminals:

```bash
php artisan serve
php artisan queue:work
```

### 5. Run the app

**Android emulator:**
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

`10.0.2.2` is the Android emulator's alias for your host machine's `localhost`.

**iOS simulator (Mac only):**
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

Default (when `--dart-define` is omitted): `http://localhost:8000/api`.

## Debugging

### Hot reload

While `flutter run` is active:

- **r** — hot reload (keeps state)
- **R** — hot restart (resets state)
- **q** — quit

### Testing on a physical device

iOS debug mode kills camera apps when you switch away — use release mode instead.

1. Find your Mac's IP:
```bash
ipconfig getifaddr en0
```

2. Start Laravel on all interfaces:
```bash
php artisan serve --host=0.0.0.0
```

3. **iOS:** build and open in Xcode:
```bash
flutter build ios --release --dart-define=API_URL=http://YOUR-IP:8000/api
open ios/Runner.xcworkspace
```
Set scheme to **Release**, select your iPhone, **Product → Run**.

3. **Android:**
   1. Enable Developer Mode on your phone (Settings → About Phone → tap Build Number 7 times)
   2. Enable USB Debugging in Developer Options
   3. Connect via USB and accept the debugging prompt on your phone
   4. Run:
   ```bash
   flutter run --dart-define=API_URL=http://YOUR-IP:8000/api
   ```

Your computer and device must be on the same Wi-Fi network.

## Tests

```bash
flutter test
```

## Useful Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter clean` | Clear build files |
| `flutter devices` | Show available devices |
| `flutter analyze` | Run linter |
| `flutter run --release` | Run in release mode |
| `flutter build apk --release` | Build Android APK |
