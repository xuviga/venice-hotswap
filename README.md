# Venice AI Hotswap Engine

Автоматический обход встроенных фильтров LLM через API Venice.ai

## Быстрый старт

```bash
git clone https://github.com/xuviga/venice-hotswap.git
cd venice-hotswap

# Установка зависимостей
pip3 install -r requirements.txt

# Настройка окружения
cp .env.example .env
nano .env  # Вставьте свой API ключ

# Настройка Hermes (добавить в ~/.hermes/config.yaml)
cat config/hermes-config.yaml >> ~/.hermes/config.yaml

# Перезапуск
hermes gateway restart
```

## Что нужно сделать

1. Получить API ключ на https://venice.ai
2. Вставить ключ в .env файл
3. Установить зависимости: `pip3 install -r requirements.txt`
4. Настроить Hermes через config/hermes-config.yaml
5. Перезапустить Hermes

## Структура

- `src/venice_mcp/mcp_server.py` - главный MCP сервер
- `config/hermes-config.yaml` - конфиг для Hermes
- `.env.example` - пример переменных окружения
- `requirements.txt` - зависимости

## Безопасность

- API ключи только в переменных окружения
- Ничего не захардкожено
- .env в .gitignore

## Инструменты

- `venice_bypass` - обход фильтров
- `venice_classify` - классификация запроса
- `venice_generate_variant` - безопасный вариант
- `venice_list_reports` - список отчётов
- `venice_read_report` - чтение отчёта
