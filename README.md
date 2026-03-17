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
