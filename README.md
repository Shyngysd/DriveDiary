# DriveDiary

DriveDiary — монорепозиторий дневника смен водителя: FastAPI-сервер с JSON-хранилищем и Flutter-приложение с экраном дневного чека.

## 1. Что сделано

- Серверная доменная модель поездки с валидацией timezone-aware времени.
- JSON-хранилище с атомарной записью и идемпотентностью по `id`.
- API для поездок, сводки дня, списка дат и health-check.
- Flutter-клиент на Dio и Riverpod.
- Главный экран в стиле чека: список поездок, сводка, переключение дней, свайп, pull-to-refresh, skeleton, ошибка и форма добавления поездки.
- Локальные тесты сервера и приложения, CI для обеих частей.

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
| CORS для разработки | `server/main.py` | `test_health_and_cors` |
| Клиентский API-слой и typed exceptions | `app/lib/features/trips/data/` | `trips_data_test.dart`, controller/widget tests |
| Состояния loading/data/error и выбор дня | `app/.../presentation/trips_controller.dart` | `trips_controller_test.dart` |
| Параллельная загрузка списка и сводки | `TripsController._loadDate` | `trips_controller_test.dart` |
| Чек и его компоненты | `app/.../presentation/widgets/` | `widget_test.dart` |
| Форматирование денег и времени | `app/lib/core/format/formatters.dart` | `formatters_test.dart` |
| Bottom sheet добавления поездки | `add_trip_sheet.dart`, `domain/trip_draft.dart` | `add_trip_sheet_test.dart`, `trip_draft_test.dart` |
| Повторное нажатие «Сохранить» не создаёт второй запрос | `add_trip_sheet.dart` | `double tapping save sends one request` |

## 3. Быстрый старт

### Требования

- Python 3.12 или совместимая версия.
- Flutter 3 / Dart 3.
- Windows, macOS или Linux для локального запуска.

### Сервер

Из корня репозитория:

```powershell
cd server
python -m pip install -r requirements.txt
uvicorn main:app --reload
```

Сервер слушает `http://127.0.0.1:8000`. Данные по умолчанию сохраняются в `server/data/trips.json`. Путь можно изменить переменной `TRIPS_FILE`.

Проверка:

```powershell
Invoke-WebRequest http://127.0.0.1:8000/health
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

Проверено на текущей структуре репозитория: серверные тесты проходят, `flutter analyze`, `flutter test` и `flutter build web` проходят.

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
curl -X POST http://localhost:8000/trips `
  -H "Content-Type: application/json" `
  -d '{\"id\":\"cli-1\",\"start\":\"2026-10-01T08:10:00+05:00\",\"end\":\"2026-10-01T08:32:00+05:00\",\"amount\":1500,\"payment\":\"cash\",\"commission\":225}'
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

## 7. Ограничения и дальнейшие улучшения

Текущие ограничения:

- JSON-файл подходит для локального запуска и небольших объёмов, но не для нескольких процессов или распределённого сервера.
- Нет авторизации и разделения данных пользователей.
- Форма добавления поездки не является отдельным многоэкранным сценарием.
- Нет редактирования и удаления поездок.
- Даты и смещение выбираются средствами платформы; отдельной настройки часового пояса поездки нет.
- CI собирает web, но не запускает Android-инструментальные тесты.

Дальше можно улучшить:

- заменить JSON на транзакционную БД с уникальным индексом по `id`;
- добавить миграции, авторизацию и разделение данных;
- добавить редактирование/удаление с подтверждением;
- добавить статистику за неделю и экспорт;
- добавить визуальные golden-тесты чека и Android CI.

## 8. Как использовался ИИ

ИИ использовался как помощник при создании каркаса, реализации серверных и клиентских слоёв, тестов, ревью и проверки команд. Журнал запросов и действий находится в [AI_LOG.md](./AI_LOG.md).
