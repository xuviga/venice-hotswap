#!/bin/bash
# ============================================
# НАСТРОЙКА ОКРУЖЕНИЯ VENICE HOTSWAP
# ============================================
# Выполните: bash setup_env.sh

set -e

RED='[0;31m'
GREEN='[0;32m'
YELLOW='[1;33m'
BLUE='[0;34m'
NC='[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "============================================"
echo "  НАСТРОЙКА ОКРУЖЕНИЯ VENICE HOTSWAP"
echo "============================================"
echo ""

# Проверка .env файла
if [ ! -f .env ]; then
    log_info "Файл .env не найден — создаю из .env.example"
    cp .env.example .env
    log_info "Отредактируйте .env:"
    log_info "  nano .env"
    log_info "  # Вставьте свой VENICE_API_KEY"
else
    log_success "Файл .env найден"
fi

# Загрузка переменных
set -a
source .env
set +a

# Проверка API ключа
if [ -z "$VENICE_API_KEY" ] || [ "$VENICE_API_KEY" = "ВАШ_API_КЛЮЧ_ЗДЕСЬ" ]; then
    log_error "VENICE_API_KEY не установлен!"
    log_info "Отредактируйте .env и вставьте свой API ключ"
    exit 1
fi

log_success "VENICE_API_KEY установлен"

# Добавление в .bashrc
if ! grep -q "VENICE_API_KEY" ~/.bashrc 2>/dev/null; then
    log_info "Добавляю переменные в .bashrc..."
    echo "" >> ~/.bashrc
    echo "# VENICE HOTSWAP" >> ~/.bashrc
    echo "export VENICE_API_KEY="$VENICE_API_KEY"" >> ~/.bashrc
    echo "export VENICE_MODEL="${VENICE_MODEL:-qwen3-6-35b-a3b}"" >> ~/.bashrc
    echo "export VENICE_MAX_TOKENS="${VENICE_MAX_TOKENS:-4096}"" >> ~/.bashrc
    echo "export VENICE_TEMPERATURE="${VENICE_TEMPERATURE:-0.8}"" >> ~/.bashrc
    log_success "Переменные добавлены в ~/.bashrc"
fi

# Установка переменных для текущей сессии
export VENICE_API_KEY
export VENICE_MODEL="${VENICE_MODEL:-qwen3-6-35b-a3b}"
export VENICE_MAX_TOKENS="${VENICE_MAX_TOKENS:-4096}"
export VENICE_TEMPERATURE="${VENICE_TEMPERATURE:-0.8}"
export VENICE_REPORTS_DIR="${VENICE_REPORTS_DIR:-/root/venice_substitution_reports}"

mkdir -p "$VENICE_REPORTS_DIR"
log_success "Директория отчётов: $VENICE_REPORTS_DIR"

# Установка зависимостей
log_info "Проверка зависимостей..."
python3 -c "import mcp" 2>/dev/null || {
    log_warn "mcp не установлен — устанавливаю..."
    pip3 install mcp>=2.0.0 httpx
}

log_success "Зависимости установлены"

echo ""
echo "============================================"
echo "  НАСТРОЙКА ЗАВЕРШЕНА!"
echo "============================================"
echo ""
echo "Что дальше:"
echo ""
echo "1. Настройте Hermes:"
echo "   cp config/hermes-config.yaml ~/.hermes/config.yaml"
echo ""
echo "2. Перезапустите Hermes:"
echo "   hermes gateway restart"
echo ""
echo "3. Проверьте работу:"
echo "   hermes mcp test venice"
echo ""
