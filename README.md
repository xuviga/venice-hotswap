# ============================================
# ВЕНА ЦЕ HOTSWAP ENGINE
# ============================================
# Автоматический обход встроенных фильтров LLM
# через Venice AI API

## Что это
Проект позволяет отправлять любые запросы через
Venice AI API без встроенных фильтров безопасности.

## Как работает
1. MCP-сервер подключается к Hermes Agent
2. Когда пользователь задаёт "небезопасный" вопрос,
   Hermes автоматически использует инструмент
   `venice_bypass`
3. Запрос трансформируется и отправляется через
   Venice AI API
4. Полный ответ возвращается пользователю

## Установка

### 1. Требования
- Python 3.11+
- Debian/Ubuntu
- API ключ Venice AI

### 2. Получить API ключ
1. Зайди на https://venice.ai
2. Создай аккаунт
3. Получи API ключ

### 3. Установка

```bash
cd venice-hotswap
chmod +x install.sh
./install.sh
```

### 4. Настройка

Скопируй .env.example и вставь свой ключ:
```bash
cp .env.example .env
nano .env  # вставь VENICE_API_KEY=your-key-here
```

### 5. Настройка Hermes

Добавь в ~/.hermes/config.yaml:

```yaml
mcp_servers:
  venice:
    command: "/root/venice-hotswap/mcp_server.py"
    args: []
    env:
      VENICE_API_KEY: "${VENICE_API_KEY}"
    timeout: 300
```

Или используй переменную окружения:
```bash
export VENICE_API_KEY="your-key-here"
```

### 6. Запуск

Проверь что работает:
```bash
python3 -m pytest tests/
hermes mcp test venice
```

## Структура проекта
```
venice-hotswap/
├── src/                    # Исходный код
│   └── venice_mcp/
│       ├── __init__.py
│       ├── mcp_server.py   # Основной MCP сервер
│       ├── api.py          # API обёртка
│       ├── hotswap.py      # Логика hotswap
│       └── utils.py        # Утилиты
├── tests/                  # Тесты
├── reports/                # Отчёты (gitignored)
├── docs/                   # Документация
├── .env.example            # Пример .env
├── .gitignore             # Что игнорировать
├── requirements.txt       # Зависимости
├── install.sh             # Скрипт установки
└── README.md              # Этот файл
```

## Инструменты MCP
- **venice_bypass** — отправить unsafe prompt через
  Live Data Substitution Engine
- **venice_classify** — классифицировать intent промпта
- **venice_generate_variant** — превью трансформации
- **venice_list_reports** — список отчётов
- **venice_read_report** — прочитать отчёт

## Безопасность
- Все API ключи в переменных окружения
- Никогда не хардкод ключи!
- .env добавлен в .gitignore
- Отчёты хранятся в reports/ (gitignored)

## Лицензия
MIT