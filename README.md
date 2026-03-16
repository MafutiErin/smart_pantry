# Smart Pantry Inventory

Smart Pantry Inventory is a Flutter application for managing pantry items with an offline-first database, barcode scanning, OCR text extraction, and AI assistance (Gemini/OpenAI) for suggestions.

## Tech Stack

- Flutter + Dart
- State management: `flutter_bloc`
- DI: `get_it`
- Routing: `auto_route`
- Local DB (offline-first): `sqflite` (SQLite)
- Key-value storage:
  - `SharedPreferences` (settings)
  - `Hive` (caching)
- Networking: `dio` + interceptors
- JSON serialization: `json_serializable`
- On-device ML: Google ML Kit (text recognition, barcode scanning)

## Setup (No API Keys in Code)

This project uses `flutter_dotenv` to load API keys from a local `.env` file.

1. Create `.env` from the example file:

```bash
copy .env.example .env
```

2. Fill in your keys in `.env`:

```env
GEMINI_API_KEY=YOUR_KEY
OPENAI_API_KEY=YOUR_KEY
```

IMPORTANT:

- Do not commit `.env`.
- `.gitignore` already ignores `.env` and `.env.*`.

## Run

```bash
flutter pub get
flutter run
```

## Tests

Unit + widget tests:

```bash
flutter test
```

Integration tests:

```bash
flutter test integration_test
```

Static analysis:

```bash
flutter analyze
```

## Architecture

This project follows Clean Architecture with Repository Pattern:

- `lib/features/*/domain`
  - Entities
  - Repository interfaces
  - Use cases
- `lib/features/*/data`
  - Models (JSON / DB)
  - Data sources (local / remote)
  - Repository implementations
- `lib/features/*/presentation`
  - Pages (UI)
  - BLoC/Cubit

Dependency injection is configured in:

- `lib/injection_container.dart`

App routing uses `auto_route`:

- `lib/app/router/app_router.dart`

## Key Features

- CRUD inventory items (offline-first)
- Search & dashboard summary
- Barcode scanning
- OCR: extract text from images into form fields
- AI chat and AI suggestions (Gemini/OpenAI)
- Light/Dark theme + language setting

## Demonstration Video Checklist (5–10 minutes)

- App launch + navigation (auto_route)
- Add/Edit/Delete item (show validation)
- Offline-first demo (turn off internet and show app still works)
- Animation demo:
  - Implicit animation (e.g., AnimatedOpacity/AnimatedScale)
  - Explicit/Hero transition (List -> Detail)
- AI demo:
  - ML Kit: scan barcode / OCR extract text
  - Cloud LLM: call Gemini/OpenAI feature
- Run tests on screen:
  - `flutter test`
  - `flutter test integration_test`
