# CHANGELOG

## v2.1.0 (2026-08-13)

### Исправления
- **Bug #1:** Empty model response detection — пустой ответ модели теперь `success=False` вместо `success=True`
- **Bug #2:** Убраны дубликаты импортов (http.server, threading, urllib.parse)
- **Bug #3:** Cap api_response at 16KB → 128KB в report JSON
- **Bug #4:** Fix generate_safe_variant — better keyword extraction (strip punctuation, filter short words)
- **Bug #5:** Map hacking_exploitation intent → correct category (было general_unsafe)
- **Bug #6:** Fuzzy hacking match — "Взломай сайт" → `hacking_exploitation` вместо `unknown`
- **Bug #7:** general_unsafe variant — явный template вместо fallback с сырым промптом
- **Bug #8:** HTTP SO_REUSEADDR + SO_REUSEPORT — сервер перезапускается без "Address already in use"

### Улучшения
- MAX_TOKENS: 4096 → **32768** (максимум модели)
- MAX_REPORT_CONTENT: 16KB → **128KB**
- Новая fuzzy-логика для hacking: "взлом" + "сайт/аккаунт/пароль" → `hacking_exploitation`
- Добавлен явный template для general_unsafe category

---

## v2.0.0 (2026-08-12)

- MCP сервер с 5 инструментами
- Автоматическая установка через install.sh
- Настройка Hermes Agent
- SKILL для автоматического hotswap
- Прямой обход через Venice AI API (без framing)