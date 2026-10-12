[![CI](https://github.com/Shyngysd/DriveDiary/actions/workflows/ci.yml/badge.svg)](https://github.com/Shyngysd/DriveDiary/actions/workflows/ci.yml)

# DriveDiary

DriveDiary — монорепозиторий дневника смен водителя: FastAPI-сервер с JSON-хранилищем и Flutter-приложение с экраном дневного чека.

## 1. Что сделано

- Серверная доменная модель поездки с валидацией timezone-aware времени.
- JSON-хранилище с атомарной записью и идемпотентностью по `id`.
- API для поездок, сводки дня, списка дат и health-check.
- Flutter-клиент на Dio и Riverpod.
- Главный экран в стиле чека: список поездок, сводка, переключение дней, свайп, pull-to-refresh, skeleton, ошибка и форма добавления поездки.
- Локальные тесты сервера и приложения, CI с jobs `server`, `app` и `android`; web и debug APK публикуются как артефакты.

### Скриншот чека

Чек отображается на главном экране Flutter-приложения после запуска команды из раздела [Быстрый старт](#3-быстрый-старт):

![Скриншот дневного чека](docs/receipt-screenshot.png)

## 2. Требования и покрытие

| Требование задания | Где реализовано | Каким тестом покрыто |
|---|---|---|
| FastAPI-сервер и `GET /health` | `server/main.py` | `server/tests/test_health.py` |
| Доменная модель поездки | `server/models/trip.py` | `server/tests/test_trip_validation.py` |
| Сумма — положительное целое число | `server/models/trip.py` | `test_amount_must_be_positive` |
| Комиссия от `0` до `amount` | `server/models/trip.py` | `test_commission_must_be_between_zero_and_amount` |
| `payment` только `cash` или `card` | `server/models/trip.py` | `test_payment_must_be_cash_or_card` |
| `end` строго позже `start` | `server/models/trip.py`, `app/.../domain/trip_draft.dart` | `test_end_must_be_after_start`, `TripDraft validates end before start` |
| Время с обязательным смещением | `server/models/trip.py`, `app/.../domain/trip.dart` | `test_start_requires_timezone_offset`, `trips_data_test.dart` |
| День по локальной дате начала поездки | `server/services/day.py` | `test_late_trip_belongs_to_its_local_start_date` |
| Сводка дня и эталонные значения | `server/services/summary.py` | `server/tests/test_summary.py`, `app/test/widget_test.dart` |
| Пустой день, только наличные, только карта | `server/services/summary.py` | `server/tests/test_summary.py` |
| JSON-репозиторий и перезагрузка из файла | `server/repositories/json_repo.py` | `test_repository_reload_preserves_data` |
| Атомарная запись и общая блокировка по файлу | `server/repositories/json_repo.py` | параллельные тесты в `test_duplicates.py` |
| Идемпотентный POST по `id` | `server/services/trips.py`, `server/api/trips.py` | `test_post_returns_created_then_idempotent_then_conflict` |
| Гонка одинаковых POST | `server/repositories/base.py`, `server/repositories/json_repo.py` | `test_twenty_parallel_identical_adds_create_one_record` |
| Конфликт одинакового `id` с другими данными | `server/services/trips.py` | `test_parallel_changed_data_raises_conflict` |
| `GET /trips` с сортировкой по `start` | `server/api/trips.py`, `server/services/trip_api.py` | `test_list_trips_is_sorted_and_summary_is_returned` |
| `GET /summary` | `server/api/trips.py` | `test_list_trips_is_sorted_and_summary_is_returned` |
| `GET /days` по возрастанию | `server/api/trips.py`, `server/repositories/json_repo.py` | `test_days_are_sorted_and_empty_day_is_valid` |
| Единый формат ошибок `{"error": ...}` | `server/api/errors.py` | `test_validation_and_query_date_errors_use_error_envelope` |
| Seed-данные и создание рабочего файла | `server/data/seed.json`, `server/repositories/json_repo.py` | `test_seed_reference_trips_and_summary`, `test_seed_days_and_midnight_trip` |
| Ошибки сервера и безопасный 500 | `server/api/errors.py` | `test_invalid_date_has_dedicated_error_code`, `test_validation_error_contains_field_details`, `test_unhandled_exception_has_safe_500_envelope`, `test_corrupt_storage_fails_at_startup_with_path` |
| CORS для разработки | `server/main.py` | `test_health_and_cors` |
| Клиентский API-слой и typed exceptions | `app/lib/features/trips/data/` | `trips_data_test.dart`, controller/widget tests |
| Состояния loading/data/error и выбор дня | `app/.../presentation/trips_controller.dart` | `trips_controller_test.dart` |
| Параллельная загрузка списка и сводки | `TripsController._loadDate` | `trips_controller_test.dart` |
| Чек и его компоненты | `app/.../presentation/widgets/` | `widget_test.dart` |
| Форматирование денег и времени | `app/lib/core/format/formatters.dart` | `formatters_test.dart` |
| Глифы валюты в локальном fallback-шрифте | `app/assets/fonts/`, `app/lib/core/theme/app_theme.dart` | `money styles use the bundled glyph fallback` |
| Светлая и тёмная версия чека | `app/.../presentation/widgets/receipt_card.dart` | `receipt card light golden`, `receipt card dark golden keeps paper and ink colors` |
| Bottom sheet добавления поездки | `add_trip_sheet.dart`, `domain/trip_draft.dart` | `add_trip_sheet_test.dart`, `trip_draft_test.dart` |
| Повторное нажатие «Сохранить» не создаёт второй запрос | `add_trip_sheet.dart` | `double tapping save sends one request` |
| Защита состояния от устаревших ответов и повторная загрузка | `trips_controller.dart` | `stale date responses cannot replace the latest selection`, `loadInitial can be retried after GET /days fails` |

## 3. Быстрый старт

### Требования

- Python 3.12 или совместимая версия.
- Flutter 3 / Dart 3.
- Windows, macOS или Linux для локального запуска.

### Сервер — Windows PowerShell

Из корня репозитория:

```powershell
cd server
python -m pip install -r requirements-dev.txt
uvicorn main:app --reload
```

Сервер слушает `http://127.0.0.1:8000`. Начальные демонстрационные данные хранятся в `server/data/seed.json`. При первом запуске, если рабочего файла ещё нет, сервер копирует seed в `server/data/trips.json`. Рабочий файл не коммитится и добавлен в `.gitignore`; последующие изменения сохраняются только в нём. Путь можно изменить переменной `TRIPS_FILE`.

Проверка:

```powershell
Invoke-WebRequest http://127.0.0.1:8000/health
```

### Сервер — bash

```bash
cd server
python3 -m pip install -r requirements-dev.txt
uvicorn main:app --reload
```

Проверка:

```bash
curl http://127.0.0.1:8000/health
```

### Flutter Web

В отдельном терминале:

```powershell
cd app
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

Если сервер запущен на другом адресе, замените значение `API_URL`.

### Android-эмулятор

Для Android Emulator сервер на компьютере доступен через `10.0.2.2`:

```powershell
cd app
flutter pub get
flutter run -d <android-device> --dart-define=API_URL=http://10.0.2.2:8000
```

HTTP-разрешение для такого адреса включено только в debug-манифесте. Для release APK используйте HTTPS:

```powershell
flutter build apk --release --dart-define=API_URL=https://api.example.com
```

### Android-телефон по USB

Подключите телефон с включённой отладкой по USB и пробросьте порт сервера:

```powershell
adb reverse tcp:8000 tcp:8000
flutter run -d <android-device> --dart-define=API_URL=http://127.0.0.1:8000
```

### Если чёрный экран на эмуляторе

В настройках эмулятора попробуйте сменить `Graphics` на `Software` или `Hardware`, затем выполните cold boot. Для запуска Flutter без Impeller:

```powershell
flutter run -d <android-device> --no-enable-impeller --dart-define=API_URL=http://10.0.2.2:8000
```

Для web и desktop используйте `http://localhost:8000`.

### Тесты и сборка

```powershell
cd server
python -m pytest

cd ..\app
flutter analyze
flutter test
flutter build web
```

### POST `/trips` из PowerShell

```powershell
Invoke-RestMethod -Method Post http://127.0.0.1:8000/trips `
  -ContentType 'application/json' `
  -Body '{"id":"cli-1","start":"2026-10-01T08:10:00+05:00","end":"2026-10-01T08:32:00+05:00","amount":1500,"payment":"cash","commission":225}'
```

### POST `/trips` из bash

```bash
curl -X POST http://127.0.0.1:8000/trips \
  -H 'Content-Type: application/json' \
  -d '{"id":"cli-1","start":"2026-10-01T08:10:00+05:00","end":"2026-10-01T08:32:00+05:00","amount":1500,"payment":"cash","commission":225}'
```

### CI

Workflow запускается на `push` и `pull_request` и содержит jobs `server`, `app`, `android`. `server` запускает pytest на Python 3.12, `app` выполняет analyze/test/web build, `android` собирает debug APK. Jobs `app` и `android` публикуют соответственно web и APK как артефакты.

Golden-тесты запускаются локально командой `flutter test --tags golden`, а в CI исключены из-за различий рендеринга Windows/Linux.

### Проверено в этом запуске

- `Get-ChildItem docs -Force`: найдены только `docs/receipt-screenshot.png`; `docs/receipt-light.png` и `docs/receipt-dark.png` отсутствуют.
- `git log --all -- docs/receipt-light.png docs/receipt-dark.png docs/receipt-screenshot.png`: в истории есть `docs/receipt-screenshot.png`, отдельные light/dark-файлы не добавлялись.
- `git show e49e90d --stat`: подтверждено добавление golden-тегов, `app/dart_test.yaml`, обычного widget-теста и исключения golden из CI.
- `git status --short`: до текущих правок рабочее дерево было чистым.

## 4. Архитектура

### Сервер

```text
server/
├── api/             # тонкие FastAPI-роуты и обработчики ошибок
├── services/        # доменные операции, сводка, даты, API helpers
├── repositories/    # интерфейс и JSON-реализация хранилища
├── models/          # Pydantic-модели
└── tests/           # unit- и integration-тесты
```

Поток запроса:

```text
api → services → repositories
```

Роуты принимают параметры и вызывают сервисы. Репозиторий отвечает за хранение, атомарность и блокировку.

### Клиент

```text
app/lib/
├── core/
│   ├── format/      # деньги, дата и время
│   └── theme/       # Material 3 и цвета
└── features/trips/
    ├── data/        # Dio API и ApiTripsRepository
    ├── domain/      # Trip, DaySummary, TripDraft, интерфейс репозитория
    └── presentation/
        ├── trips_controller.dart
        └── widgets/
```

Поток клиента:

```text
виджеты → Riverpod-контроллер → TripsRepository → Dio API
```

### Как добавить новую функцию: «статистика за неделю»

1. Добавить серверную доменную модель, например `server/models/week_summary.py`.
2. Добавить чистую операцию расчёта в `server/services/weekly_summary.py`.
3. Расширить интерфейс репозитория только при необходимости новых данных.
4. Добавить тонкий endpoint в `server/api/`, например `GET /weekly-summary`.
5. Покрыть расчёт и endpoint тестами в `server/tests/`.
6. Добавить Dart-модель в `app/lib/features/trips/domain/`.
7. Добавить метод в `TripsRepository`, реализацию в `ApiTripsRepository` и запрос в `TripsApi`.
8. Добавить состояние/метод контроллера и отдельные UI-компоненты в `presentation/widgets/`.
9. Добавить unit-, controller- и widget-тесты.

## 5. Принятые решения

- **День поездки** — локальная дата `start` в смещении самой поездки. UTC и timezone устройства/сервера не используются для определения дня.
- **Идемпотентность** — клиент задаёт строковый `id`. Повтор с идентичными данными возвращает `200`, повтор с другими данными возвращает `409`.
- **Гонка POST** — проверка и вставка выполняются внутри репозитория под общей блокировкой для одного JSON-файла.
- **Деньги** — только `int`, без `float` и `double`.
- **Время** — передаётся как ISO 8601 со смещением. Flutter хранит локальные компоненты времени и отдельный `Duration` смещения, чтобы не потерять `+05:00`.
- **Хранилище** — JSON-файл с временным файлом и атомарным `os.replace`.
- **Состояние клиента** — один подход Riverpod через `NotifierProvider`.

## 6. API

Базовый URL по умолчанию: `http://localhost:8000`.

### Health

```bash
curl http://localhost:8000/health
```

Ответ `200`:

```json
{"status":"ok"}
```

### Список поездок

```bash
curl "http://localhost:8000/trips?date=2026-10-01"
```

Ответ `200` — массив поездок за локальный день, отсортированный по `start`.

### Сводка дня

```bash
curl "http://localhost:8000/summary?date=2026-10-01"
```

Ответ `200`:

```json
{
  "trips_count": 2,
  "revenue": 3900,
  "commission": 585,
  "net": 3315,
  "cash_total": 1500,
  "card_total": 2400
}
```

### Даты с поездками

```bash
curl http://localhost:8000/days
```

Ответ `200`:

```json
["2026-10-01","2026-10-02","2026-10-04","2026-10-05"]
```

### Добавление поездки

```bash
curl -X POST http://localhost:8000/trips \
  -H 'Content-Type: application/json' \
  -d '{"id":"cli-1","start":"2026-10-01T08:10:00+05:00","end":"2026-10-01T08:32:00+05:00","amount":1500,"payment":"cash","commission":225}'
```

Коды ответа:

- `201` — поездка создана.
- `200` — идемпотентный повтор с теми же данными.
- `409` — тот же `id`, но другие данные.
- `422` — невалидное тело или query-параметр даты.

Ошибки имеют единый формат:

```json
{
  "error": {
    "code": "duplicate_conflict",
    "message": "trip id already exists: cli-1"
  }
}
```

## 7. Что осознанно не сделано

- Редактирование и удаление поездок.
- Авторизация.
- База данных вместо JSON.

## 8. Как использовался ИИ

ИИ использовался как помощник при создании каркаса, реализации серверных и клиентских слоёв, тестов, ревью и проверки команд. Журнал запросов и действий находится в [AI_LOG.md](./AI_LOG.md).
