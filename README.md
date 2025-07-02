# DouDiZhu Flutter Game

A commercial-ready Flutter implementation of the classic Chinese card game DouDiZhu (斗地主).

⚠️  This is a **minimal playable skeleton** that you can run out-of-the-box.  It showcases the architecture and provides hooks for advanced features such as online multiplayer, in-app purchases, ads, analytics, etc.  Feel free to extend it to meet full production requirements.

## Features

* Local human vs two AI opponents (simple AI).
* Card dealing, landlord assignment, turn rotation.
* Tap-to-select cards and play/pass actions.
* Illustrated card images, sound effects & simple animations.
* Firebase‐based anonymous login.
* Online multiplayer (`cloud_firestore` stub) ready.
* Banner ads (Google Mobile Ads test id).
* In-App Purchase service scaffold.
* Firebase Analytics event tracking.
* Interactive tutorial (TutorialCoachMark)
* Modular architecture with Providers.
* Placeholders for:
  * User authentication
  * Matchmaking & lobby
  * Shop / IAP
  * Ads & analytics
  * Leaderboards & achievements

## Getting Started

1. Install Flutter (>=3.0) and ensure `flutter doctor` passes.
2. Clone or download this repository.
3. Fetch packages:

   ```bash
   flutter pub get
   ```
4. Run on any supported device or emulator:

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
 ├─ game/              // Core game logic (rules, engine)
 ├─ models/            // Data models (card, player, deck)
 ├─ screens/           // UI pages (home, game, profile, ...)
 ├─ services/          // Providers / state management
 ├─ widgets/           // Reusable UI components
 └─ main.dart          // App entry-point
```

## Commercial Modules (To-Do)

| Module | Status | Notes |
| ------ | ------ | ----- |
| Online Multiplayer | 🔧 | Integrate WebSocket / Firebase realtime DB |
| Ads | 🔧 | Add `google_mobile_ads` |
| In-App Purchase | 🔧 | Add `in_app_purchase` |
| Analytics | 🔧 | Add `firebase_analytics` |
| Push Notifications | 🔧 | Add `firebase_messaging` |

## Assets

All image, sound and animation resources live under `assets/`.  Empty README files are included as placeholders; replace them with real files before release.

```
assets/
├─ cards/           # 54 PNG images
├─ sounds/          # WAV / MP3 effects
└─ animations/      # Lottie JSON
```

## Firebase

A sample `firebase_options.dart` is provided with **dummy** keys.  Run `flutterfire configure` and overwrite the file with the generated one.

## In-App Purchases & Ads

* AdMob test IDs are used by default – change them in `AdsService`.
* Add your product IDs in `IAPService._productIds` and set up through App Store / Play Console.

## License

MIT