#!/usr/bin/env bash

# ==============================================================================
# Script de Validação e Preparação do Servidor (Omarchy-Trabalho)
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}   TESTBIRDS ANTI-FRAUD: VALIDAÇÃO (Omarchy-Trabalho - SERVIDOR)   ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""

# 1. Checagem de Conexão à Internet
log_step "[1/6] Testando conexão com a internet..."
if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    log_success "Internet OK"
else
    log_error "FALHA! Verifique o cabo de rede/Wi-Fi."
    exit 1
fi

# 2. Checagem do Tailscale
log_step "[2/6] Verificando Tailscale (IP estático imutável)..."
ensure_tailscale
MY_TS_IP=$(tailscale ip -4 2>/dev/null || echo "$TRABALHO_IP")

# 3. Checagem do SSH
log_step "[3/6] Verificando SSH Daemon e Tailscale SSH..."
ensure_sshd
run_sudo tailscale up --ssh 2>/dev/null || true

# 4. Checagem e Configuração do RustDesk
log_step "[4/6] Verificando RustDesk..."
ensure_rustdesk
RUSTDESK_ID=$(rustdesk --get-id 2>/dev/null || echo "$TRABALHO_RUSTDESK_ID")

# 5. Configurar Senha Fixa de Acesso Não Assistido
log_step "[5/6] Configurando senha de acesso..."
run_sudo rustdesk --password "$DEFAULT_PASS" 2>/dev/null || true
log_success "Senha configurada para: $DEFAULT_PASS"

# 6. Prevenção de Suspensão / Sleep
log_step "[6/6] Verificando gerenciamento de energia (evitar suspensão)..."
if pgrep -f "prevent_sleep.sh" &>/dev/null; then
    log_success "Inibidor de sleep prevent_sleep.sh já ativo!"
else
    echo -e "${YELLOW}Deseja iniciar o inibidor de sleep (prevent_sleep.sh) em segundo plano? (S/n)${NC}"
    read -r -t 8 resp || resp="s"
    if [[ "$resp" =~ ^[sSyY]$ ]] || [[ -z "$resp" ]]; then
        nohup "$SCRIPT_DIR/prevent_sleep.sh" >/dev/null 2>&1 &
        log_success "Inibidor de sleep prevent_sleep.sh iniciado em segundo plano!"
    fi
fi

# 7. Resumo Final
echo ""
echo -e "${BLUE}===================================================================${NC}"
echo -e "${GREEN}           TUDO PRONTO! OMARCHY-TRABALHO VALIDADO                  ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""
echo -e "Anote ou tire foto destes dados antes de sair do trabalho:"
echo -e "  • ${YELLOW}Dispositivo:${NC}                     Omarchy-Trabalho ($TRABALHO_HOSTNAME)"
echo -e "  • ${YELLOW}IP Tailscale (Fixo e Imutável):${NC}  $MY_TS_IP"
echo -e "  • ${YELLOW}RustDesk ID:${NC}                    $RUSTDESK_ID"
echo -e "  • ${YELLOW}Senha Fixa (RustDesk/sudo/SSH):${NC}  $DEFAULT_PASS"
echo ""
echo -e "${BLUE}Como conectar a partir do Omarchy-Casa:${NC}"
echo -e "  1. No Omarchy-Casa, entre no repo e execute:"
echo -e "     ${GREEN}./connect_from_home.sh${NC}"
echo -e "  2. No RustDesk de casa, conecte digitando o ID: ${YELLOW}$RUSTDESK_ID${NC} (Senha: ${YELLOW}$DEFAULT_PASS${NC})"
echo -e "     (Ou direto pelo IP Tailscale: ${YELLOW}$MY_TS_IP${NC})"
echo -e "  3. Teste o terminal: ${YELLOW}ssh walbarellos@$MY_TS_IP${NC} (Senha: ${YELLOW}$DEFAULT_PASS${NC})"
echo ""
echo -e "${RED}LEMBRETE ANTES DE SAIR:${NC}"
echo -e "  - Deixe o PC ligado na tomada."
echo -e "  - Deixe o Chromium aberto com a página do teste."
echo -e "  - Não desligue nem suspenda o computador."
echo -e "${BLUE}===================================================================${NC}"
