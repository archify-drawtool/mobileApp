# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                                       # Install dependencies (run after every pull)
flutter analyze                                                       # Lint
flutter test                                                          # Run all tests
flutter test test/services/api_service_test.dart                      # Run a single test file

# Android emulator (10.0.2.2 = host machine from emulator)
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api --dart-define=WEB_APP_URL=http://10.0.2.2:3000

# iOS simulator
flutter run --dart-define=API_URL=http://localhost:8000/api --dart-define=WEB_APP_URL=http://localhost:3000

# Physical device — use machine LAN IP, start Laravel with --host=0.0.0.0
flutter run --dart-define=API_URL=http://YOUR-IP:8000/api --dart-define=WEB_APP_URL=http://YOUR-IP:3000
```

| dart-define | Default | Used by |
|-------------|---------|---------|
| `API_URL` | `http://localhost:8000/api` | All API calls (`ApiService.baseUrl`) |
| `WEB_APP_URL` | `http://localhost:3000` | Share-sheet URL built by `ShareService` (`/projecten/{p}/schetsen/{s}`) |

iOS debug mode has known camera limitations — use release mode for camera testing on a physical iPhone.

## Architecture

The app is portrait-locked (set in `main.dart`). All UI logic lives in `lib/screens/`, all business logic in `lib/services/`. Screens never call `http` directly.

### Navigation flow

```
AuthGate (checks SharedPreferences for token)
 ├─ no token  → LoginScreen
 │             └─ on success → CameraPermissionScreen (first launch only)
 │                              └─ on grant   → CameraScreen
 │                                 on deny    → CameraDeniedScreen
 └─ has token → CameraPermissionScreen / CameraScreen

CameraScreen
 ├─ capture       → PhotoPreviewScreen
 ├─ gallery pick  → PhotoPreviewScreen (via image_picker)
 │
 └─ PhotoPreviewScreen
     ├─ retake → back to CameraScreen
     └─ accept → ProjectSelectionScreen
                  └─ POST /photos/upload  → UploadStatusScreen(photoId, projectId)
                                              ├─ share → opens native share sheet (ShareService)
                                              └─ done  → pop to root (CameraScreen)
```

`AuthGate.logoutAndRedirect()` is the canonical way to handle session expiry — it clears the token and pushes back to `LoginScreen`. Call it whenever any service returns `unauthorized: true`.

### Upload status polling

`UploadStatusScreen` is the two-stage async UI shown after a successful upload. It polls `GET /api/photos/{photoId}/status` until the photo is `completed` or `failed`. Polling parameters (private constants on the State class):

| Constant | Value | Meaning |
|----------|-------|---------|
| `_uploadedHold` | 1500 ms | Hold on the "uploaded" stage before switching to "processing" (UX pacing) |
| `_pollInterval` | 1500 ms | Delay between successive status polls |
| `_pollTimeout` | 90 s | Total time before the screen gives up and shows a "duurt langer dan verwacht" error |

The screen tracks four `UploadStage` values (`uploaded` / `processing` / `completed` / `failed`, defined in `lib/models/upload_stage.dart`). On `completed` it shows nodes/edges counts and a `Schets delen` button that calls `ShareService.shareSketch(...)`.

### Service layer

| Service | Responsibility |
|---------|---------------|
| `ApiService` | All HTTP calls. Constructor accepts injectable `http.Client` and `AuthService` for tests. Returns `Map<String, dynamic>` with `success`, `message`, and optional `unauthorized` keys. Includes `uploadPhoto`, `getPhotoStatus`, `login`, `getProjects`, `createProject`. |
| `AuthService` | Wraps `SharedPreferences` for the `auth_token` key. Plain-text storage. |
| `PhotoService` | `fixOrientation()` reads EXIF, rotates the image, resizes to max 1920 px, re-encodes as JPEG 85 %. `cleanupFixedPhoto()` deletes the temp `_fixed.jpg`. |
| `ShareService` | Wraps `share_plus`. Builds `${WEB_APP_URL}/projecten/{projectId}/schetsen/{sketchId}` and opens the native share sheet. Caller passes a `Rect` for the iPad popover origin. |

`ApiService` uses graduated timeouts: 10 s for login/projects, 30 s for upload. It catches `SocketException` and `TimeoutException` separately and returns Dutch user-facing messages.

### CameraScreen lifecycle

`CameraScreen` implements `WidgetsBindingObserver` and pauses/disposes the `CameraController` on `inactive`/`paused`, then reinitialises on `resumed`. Touching this without preserving the lifecycle hooks will leak the camera handle on backgrounding.

### Theme

`lib/theme/app_theme.dart` defines:
- `AppColors.magenta` = `#E5097F` (primary), `darkNavy` = `#0D0A1F` (background), `grey` = `#A0A0A8`
- `AppTextStyles.heading` (Syne, 22, w700, white) and `body` (Nunito, 14, grey) — both via `google_fonts`
- Global theme: square buttons (0 radius, no shadow), white text fields with 1.5 px magenta focus border, Material 3

Always use these tokens. Icons come from `lucide_icons`, never `Icons.*` from Material.

### Tests

`test/` mirrors `lib/`. API tests use `MockClient` from `package:http/testing.dart`; auth tests call `SharedPreferences.setMockInitialValues({})` in `setUp`. Imports must use the `package:archify_app/...` form (enforced by `analysis_options.yaml`).
