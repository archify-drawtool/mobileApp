# Archify Mobile App

The Archify Mobile App



# Setup
## Prerequisites

Make sure you have the following installed:
- Flutter
- Android Studio (for Android emulation)
- Xcode (only on Mac, for iOS emulation)

After installing, verify your setup:
```bash
flutter doctor
```


## Running the app

### Windows (Android emulator)
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

### Mac

**iOS simulator:**
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

**iOS fysiek apparaat:**
```bash
flutter run --dart-define=API_URL=http://<jouw-ip>:8000/api
```

**Android emulator:**
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

### Met Laravel Herd
```bash
flutter run --dart-define=API_URL=http://webapi.test/api
```












# Debugging Guide

### Which device to use?

| Situation | Best option |
|---|---|
| Daily development | Android emulator |
| Camera testing on Android | Android emulator (has simulated camera) |
| Camera testing on iOS | Physical iPhone in release mode |
| UI testing on iOS | iOS simulator (no camera available) |

### Running on Android emulator

1. Open Android Studio → Device Manager → Start an emulator
2. Run the app:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

### Running on iOS simulator

1. Open the simulator:
```bash
open -a Simulator
```
2. Run the app:
```bash
flutter run --dart-define=API_URL=http://localhost:8000/api
```

Note: Camera is not available in the iOS simulator.

### Testing on a physical iPhone

Debug mode on iOS has known limitations with camera apps. Use release mode:
```bash
flutter build ios --release
open ios/Runner.xcworkspace
```

In Xcode: set scheme to Release, select your iPhone, then Product → Run.

Note: iOS will restart the app when you change camera permissions in Settings. This is normal iOS behavior.

### Testing on a physical Android device

1. Enable Developer Mode on your phone
2. Connect via USB
3. Run:
```bash
flutter run --dart-define=API_URL=http://<your-mac-ip>:8000/api
```

### Common issues

| Problem | Solution |
|---|---|
| `command not found: flutter` | Flutter not in PATH, check installation |
| App shows "Could not connect to API" | Make sure Laravel is running with `php artisan serve` |
| iOS app crashes when switching apps | Normal behavior, app restarts automatically |
| Android permission loop | Wipe app data in emulator settings and restart |
| Red screen with errors after pull | Run `flutter pub get` |
