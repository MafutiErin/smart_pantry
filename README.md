# Smart Pantry Inventory

แอป Flutter สำหรับจัดการวัตถุดิบ/ของในครัวแบบ **offline-first** พร้อมฟีเจอร์สแกนบาร์โค้ด, OCR (ML Kit) และ AI Assistant (Gemini/OpenAI)

## Tech Stack (สรุป)

- Flutter + Dart
- State Management: `flutter_bloc`
- Dependency Injection: `get_it`
- Routing: `auto_route`
- Local Database (Offline-first): `sqflite` (SQLite)
- Key-Value Storage:
  - `SharedPreferences` (settings)
  - `Hive` (caching)
- Networking: `dio` + interceptors
- JSON Serialization: `json_serializable`
- On-device ML: Google ML Kit (Text Recognition / Barcode)

## วิธีรันโปรเจกต์ (Run)

1) ติดตั้ง dependencies

```bash
flutter pub get
```

2) รันแอป

```bash
flutter run
```

หมายเหตุ: ถ้าใช้ Emulator/Device ให้แน่ใจว่าเปิดอุปกรณ์ไว้ก่อน

## ตั้งค่า API Key แบบปลอดภัย (No API Keys in Code)

โปรเจกต์นี้ใช้ `flutter_dotenv` โหลดค่า API key จากไฟล์ `.env` (ไม่ผูกติดใน source code)

1) สร้างไฟล์ `.env` จากตัวอย่าง

```bash
copy .env.example .env
```

2) ใส่ค่า key ลงใน `.env`

```env
GEMINI_API_KEY=YOUR_KEY
OPENAI_API_KEY=YOUR_KEY
```

ข้อสำคัญ:

- ห้าม commit `.env` ขึ้น GitHub
- `.gitignore` ได้ ignore `.env` และ `.env.*` ไว้แล้ว

## การรัน Tests

Unit + Widget tests:

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

## Architecture ที่ใช้

โปรเจกต์ใช้แนวทาง **Clean Architecture + Repository Pattern** และแยกชั้นงานชัดเจน

### โครงสร้างหลัก

- `lib/features/*/presentation`
  - UI Pages
  - BLoC/Cubit (จัดการ state)
- `lib/features/*/domain`
  - Entities
  - Repository interfaces
  - Use cases (business logic)
- `lib/features/*/data`
  - Models (JSON/DB)
  - Data sources (Local/Remote)
  - Repository implementations

### Dependency Injection

- `lib/injection_container.dart`

### Routing (auto_route)

- `lib/app/router/app_router.dart`

## ฟีเจอร์หลัก

- จัดการรายการของในคลัง (CRUD) แบบ offline-first
- Search & dashboard summary
- Barcode scanning
- OCR ช่วยกรอกข้อมูลจากฉลาก/รูป (ML Kit)
- AI Chat / AI Suggestions (Gemini/OpenAI)
- Light/Dark theme + ตั้งค่าภาษา
