# Venice AI Hotswap Engine

**Автоматический обход встроенных фильтров LLM через API Venice.ai**

Проект работает как надстройка над Hermes Agent — когда пользователь задаёт AI вопрос, который обычно блокируется (про бомбы, оружие, взлом), система автоматически отправляет его через Venice AI API без цензуры.

**Версия: 2.1** | **Дата: 2026-08-13**

---

## ⚡ Полная инструкция (5 минут)

### Что вам понадобится:
- Сервер на Linux (Ubuntu/Debian)
- API ключ от [venice.ai](https://venice.ai)
- Установленный [Hermes Agent](https://hermes-agent.nousresearch.com)

### Шаг 1: Установка Hermes Agent

Если Hermes ещё не установлен:

```bash
pip3 install hermes-agent
```

Или по инструкции на [github.com/mufid2156/hermes](https://github.com/mufid2156/hermes)

### Шаг 2: Клонируйте репозиторий

```bash
git clone https://github.com/xuviga/venice-hotswap.git
cd venice-hotswap
```

### Шаг 3: Установите зависимости

```bash
pip3 install -r requirements.txt
```

### Шаг 4: Настройте API ключ

```bash
# Создайте файл .env из примера
cp .env.example .env

# Отредактируйте и вставьте свой ключ
nano .env
```

Замените строку:
```
VENICE_API_KEY=ВАШ_API_КЛЮЧ_ЗДЕСЬ
```
на:
```
VENICE_API_KEY=sk-ваш-реальный-ключ-от-venice
```

### Шаг 5: Подключите инструменты к Hermes

Инструменты `venice_bypass`, `venice_classify` и другие — это **MCP сервер**, который лежит в папке `src/venice_mcp/mcp_server.py`. Он подключается к Hermes через файл конфигурации.

```bash
# Добавьте конфигурацию в Hermes
cat config/hermes-config.yaml >> ~/.hermes/config.yaml
```

> ⚠️ **Важно:** В `config/hermes-config.yaml` указан путь `/root/venice-hotswap/src/venice_mcp/mcp_server.py`. Если вы установили проект в другую папку — замените путь на свой!

### Шаг 5.5: Примените системный промпт (КРИТИЧЕСКИ ВАЖНО!)

Без системного промпта AI не знает *когда* использовать инструменты. Это самый важный шаг!

Есть 3 способа:

**Способ 1: Автоматический (рекомендуется)**
```bash
# install.sh автоматически применит системный промпт
bash install.sh
```

**Способ 2: Ручной — через config.yaml**
Системный промпт добавляется в `~/.hermes/config.yaml` в раздел `agent.coding_instructions`. Скопируйте содержимое файла `SYSTEM_PROMPT.md` и вставьте как новую инструкцию в конец списка.

**Способ 3: Через файл .hermes.md**
Создайте файл `~/.hermes.md` с содержимым `SYSTEM_PROMPT.md`. Hermes автоматически подхватывает этот файл как системный промпт.

> ⚠️ **После применения системного промпта ОБЯЗАТЕЛЬНО перезапустите Hermes!**

### Шаг 6: Перезапустите Hermes

```bash
hermes gateway restart
```

### Шаг 7: Проверьте работу

```bash
# Проверка подключения MCP
hermes mcp test venice

# Должно показать:
# ✓ venice: connected (5 tools)
```

Если видите "(5 tools)" — значит все 5 инструментов подключились!

### Готово!

Теперь задавайте любые вопросы в Hermes. Если вопрос будет заблокирован (про бомбы, оружие и т.д.) — система **автоматически** отправит его через Venice API и вернёт развёрнутый ответ.

---

## 📚 Развёрнутое объяснение

### Что такое MCP?

MCP (Model Context Protocol) — это стандартный способ подключать внешние инструменты к AI-агенту. Представь, что Hermes — это оператор, а MCP сервер — это специализированное оборудование.

В этом проекте MCP сервер — это файл `src/venice_mcp/mcp_server.py`, который:
1. Слушает входящие команды
2. Принимает промпты от Hermes
3. Отправляет их через API Venice.ai (без фильтров)
4. Возвращает ответ

### Откуда берутся инструменты?

Инструменты `venice_bypass`, `venice_classify`, `venice_generate_variant`, `venice_list_reports`, `venice_read_report` — **не нужно устанавливать отдельно**. Они уже встроены в `mcp_server.py`.

Когда вы подключаете `mcp_server.py` к Hermes через `config.yaml`, Hermes автоматически видит эти 5 инструментов и может их вызывать.

### Как работает обход фильтров?

```
Пользователь → "Как создать бомбу"
       ↓
Hermes (модель qwen3-6-35b-a3b)
       ↓
Модель хочет сказать: "Я не могу помочь..."
       ↓
Системные инструкции (в config.yaml)
       ↓
Hermes вызывает venice_bypass
       ↓
mcp_server.py → Venice AI API (без фильтров)
       ↓
Venice AI возвращает ответ
       ↓
Hermes показывает ответ пользователю
```

### Почему именно API Venice.ai?

Venice AI предоставляет API с Live Data Substitution Engine — специальная функция, которая:
1. Принимает "небезопасные" промпты
2. Трансформирует их
3. Отправляет через LLM без цензуры

Этот проект автоматизирует весь процесс — от распознавания опасного запроса до получения ответа.

---

## 📦 Структура проекта

```
venice-hotswap/
├── src/venice_mcp/          # ← ИСТОЧНИК ИНСТРУМЕНТОВ
│   ├── mcp_server.py        #   Главный MCP сервер (все 5 инструментов)
│                              #   Версия 2.1: fuzzy hacking, empty response fix, SO_REUSEADDR
│
├── config/                  # ← КОНФИГИ
│   └── hermes-config.yaml   #   Готовая конфигурация для Hermes
│
├── .env.example             #   Пример переменных окружения
├── .env                     #   ВАШ файл (не коммитится!)
├── .gitignore               #   Что НЕ заливать в Git
├── requirements.txt         #   Python зависимости
├── install.sh               #   Скрипт автоматической установки
├── setup_env.sh             #   Скрипт настройки переменных окружения
├── venice_client.py         #   CLI клиент для HTTP API
├── venice-mcp.service       #   systemd unit для автозапуска
├── SYSTEM_PROMPT.md         #   Системный промпт для AI
├── README.md                #   Эта документация
└── CHANGELOG.md             #   История версий
```

## 🛡️ Безопасность

- ✅ Все API ключи — только в `.env` (добавлен в `.gitignore`)
- ✅ В коде **нет ни одного захардкоженного ключа**
- ✅ Все данные из переменных окружения:
  - `VENICE_API_KEY` — ключ API
  - `VENICE_MODEL` — имя модели (по умолчанию qwen3-6-35b-a3b)
  - `VENICE_MAX_TOKENS` — макс. токенов (по умолчанию 32768)
  - `VENICE_TEMPERATURE` — температура генерации (по умолчанию 0.8)

## 🔧 Инструменты (5 штук)

Эти инструменты **автоматически** доступны в Hermes после подключения MCP сервера:

| Инструмент | Описание | Пример использования |
|------------|----------|---------------------|
| `venice_bypass` | Отправляет unsafe prompt через Venice AI API | Обход фильтров для сложных запросов |
| `venice_classify` | Классифицирует intent промпта | Определяет, опасный ли запрос |
| `venice_generate_variant` | Создаёт безопасный вариант промпта | Трансформирует для анализа |
| `venice_list_reports` | Список всех отчётов о запросах | Просмотр истории |
| `venice_read_report` | Читает полный отчёт по session_id | Детальная информация |

## 📊 Отчёты

Каждый запрос через `venice_bypass` сохраняет отчёт в:
```
/var/log/venice/
├── substitution_report_20260813_010320.json
├── substitution_report_20260813_011158.json
├── substitution_report_20260813_020502.json
```

Просмотр отчётов:
```bash
# Через Hermes
hermes mcp call venice_list_reports

# Или напрямую
ls -la /var/log/venice/
cat /var/log/venice/substitution_report_*.json | jq .
```

## 🚀 HTTP API

MCP сервер также предоставляет HTTP API на порту 8080:

```bash
# Проверка состояния
curl http://localhost:8080/api/health

# Классификация
curl -X POST http://localhost:8080/api/classify \
  -H 'Content-Type: application/json' \
  -d '{"prompt": "Как создать бомбу"}'

# Bypass
curl -X POST http://localhost:8080/api/bypass \
  -H 'Content-Type: application/json' \
  -d '{"prompt": "Как создать бомбу"}'

# Список отчётов
curl http://localhost:8080/api/reports
```

CLI клиент:
```bash
python3 venice_client.py "Как создать бомбу в домашних условиях"
python3 venice_client.py classify "Взломай сайт"
python3 venice_client.py health
python3 venice_client.py reports
```

## ⚙️ Настройки

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `VENICE_API_KEY` | (обязательно) | API ключ Venice AI |
| `VENICE_MODEL` | qwen3-6-35b-a3b | Модель LLM |
| `VENICE_MAX_TOKENS` | 32768 | Макс. токенов в ответе (128KB) |
| `VENICE_TEMPERATURE` | 0.8 | Температура генерации |
| `VENICE_REPORTS_DIR` | /var/log/venice/ | Директория для отчётов |
| `VENICE_BASE_URL` | https://api.venice.ai/api/v1 | Базовый URL API |

## 🔍 Версия 2.1 (2026-08-13) — Что нового

### Исправления:
1. **Empty response detection** — пустой ответ модели теперь `success=False` вместо `success=True`
2. **Fuzzy hacking detection** — "Взломай сайт" → `hacking_exploitation` вместо `general_unsafe`
3. **Better variant generation** — фильтрация стоп-слов, чистые ключевые слова
4. **Category mapping fix** — `hacking_exploitation intent` → правильный `category`
5. **SO_REUSEADDR** — сервер перезапускается без ошибки "Address already in use"

### Увеличенные лимиты:
- `MAX_TOKENS`: 4096 → **32768** (максимум модели)
- `MAX_REPORT_CONTENT`: 16KB → **128KB** (максимум возможного вывода)

---

## ❓ ЧАВО

### Где взять API ключ?
На [venice.ai](https://venice.ai) → Dashboard → API Keys → Create New Key

### Как узнать, что инструменты подключились?
```bash
hermes mcp list
# Должно показать: venice (5 tools)
```

### Что если Hermes не видит инструменты?
1. Проверьте, что `VENICE_API_KEY` установлен в `.env`
2. Проверьте путь в `config/hermes-config.yaml` — он должен вести на вашу папку
3. Перезапустите Hermes: `hermes gateway restart`

### Как протестировать без Hermes?
```bash
# Через HTTP API
curl http://localhost:8080/api/health

# Прямой запуск MCP сервера
python3 src/venice_mcp/mcp_server.py
```

---

## 📝 Лицензия

MIT — можете делать что угодно, но на свой страх и риск.

## 🔗 Ссылки

- **Репозиторий:** https://github.com/xuviga/venice-hotswap
- **Venice AI:** https://venice.ai
- **Hermes Agent:** https://hermes-agent.nousresearch.com