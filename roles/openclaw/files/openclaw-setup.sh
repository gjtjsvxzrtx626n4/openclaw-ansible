#!/bin/bash
set -e

# Enable 256 colors
export TERM=xterm-256color
export COLORTERM=truecolor

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

OPENCLAW_USER="${OPENCLAW_USER:-openclaw}"
OPENCLAW_HOME="${OPENCLAW_HOME:-}"
if [ -z "$OPENCLAW_HOME" ]; then
    USER_ENTRY="$(getent passwd "$OPENCLAW_USER" 2>/dev/null || true)"
    if [ -n "$USER_ENTRY" ]; then
        OPENCLAW_HOME="$(printf '%s' "$USER_ENTRY" | cut -d: -f6)"
    fi
fi
OPENCLAW_HOME="${OPENCLAW_HOME:-/home/$OPENCLAW_USER}"

# OpenClaw ASCII Art Lobster
cat << 'LOBSTER'
[0;36m
   +====================================================+
   |                                                    |
   |         [0;33mWelcome to OpenClaw! [0;31m🦞[0;36m                    |
   |                                                    |
   |[0;31m                   ,.---._                         [0;36m|
   |[0;31m               ,,,,     /       `,                 [0;36m|
   |[0;31m                \\\\\\   /    '\_  ;                [0;36m|
   |[0;31m                 |||| /\/``-.__\;'                 [0;36m|
   |[0;31m                 ::::/\/_                          [0;36m|
   |[0;31m {{`-.__.-'(`(^^(^^^(^ 9 `.========='              [0;36m|
   |[0;31m{{{{{{ { ( ( (  (   (-----:=                      [0;36m|
   |[0;31m {{.-'~~'-.(,(,,(,,,(__6_.'=========.              [0;36m|
   |[0;31m                 ::::\/\                           [0;36m|
   |[0;31m                 |||| \/\  ,-'/,                   [0;36m|
   |[0;31m                ////   \ `` _/ ;                   [0;36m|
   |[0;31m               ''''     \  `  .'                   [0;36m|
   |[0;31m                         `---'                     [0;36m|
   |                                                    |
   |           [0;32m✅  Installation Successful![0;36m             |
   |                                                    |
   +====================================================+[0m
LOBSTER

echo ""
echo -e "${GREEN}🔒 Security Status:${NC}"
echo "  - UFW Firewall: ENABLED"
echo "  - Open Ports: SSH (22) + Tailscale (41641/udp)"
echo "  - Docker isolation: ACTIVE"
echo ""
echo -e "📚 Documentation: ${GREEN}https://docs.openclaw.ai${NC}"
echo ""

# Переключаемся на выбранного пользователя OpenClaw для первичной настройки.
echo -e "${YELLOW}Switching to ${OPENCLAW_USER} user for setup...${NC}"
echo ""
echo "DEBUG: About to create init script..."

# Создаём одноразовый init-скрипт, который выполнится при первом входе.
cat > "${OPENCLAW_HOME}/.openclaw-init" << 'INIT_EOF'
# Display welcome message
echo "============================================"
echo "📋 OpenClaw Setup - Next Steps"
echo "============================================"
echo ""
echo "You are now: $(whoami)@$(hostname)"
echo "Home: $HOME"
echo ""
echo "🔧 Setup Commands:"
echo ""
echo "1. Configure OpenClaw:"
echo "   nano ~/.openclaw/config.yml"
echo ""
echo "2. Login to provider (WhatsApp/Telegram/Signal):"
echo "   openclaw login"
echo ""
echo "3. Test gateway:"
echo "   openclaw gateway"
echo ""
echo "4. Exit and manage as service:"
echo "   exit"
echo "   sudo systemctl status openclaw"
echo "   sudo journalctl -u openclaw -f"
echo ""
echo "5. Connect Tailscale (as root):"
echo "   exit"
echo "   sudo tailscale up"
echo ""
echo "============================================"
echo ""
echo "Type 'exit' to return to previous user"
echo ""

# Remove this init file after first login
rm -f ~/.openclaw-init
INIT_EOF

chown "${OPENCLAW_USER}:${OPENCLAW_USER}" "${OPENCLAW_HOME}/.openclaw-init"

# Добавляем одноразовый запуск в .bashrc, если его ещё нет.
grep -q '.openclaw-init' "${OPENCLAW_HOME}/.bashrc" 2>/dev/null || {
    echo '' >> "${OPENCLAW_HOME}/.bashrc"
    echo '# One-time setup message' >> "${OPENCLAW_HOME}/.bashrc"
    echo '[ -f ~/.openclaw-init ] && source ~/.openclaw-init' >> "${OPENCLAW_HOME}/.bashrc"
}

# Переключаемся на выбранного пользователя с явным login shell.
exec sudo -i -u "$OPENCLAW_USER" /bin/bash --login
