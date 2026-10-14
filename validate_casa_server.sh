#!/usr/bin/env bash

# ==============================================================================
# Script de Validação e Preparação do Servidor (Omarchy-Casa)
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}   TESTBIRDS ANTI-FRAUD: VALIDAÇÃO (Omarchy-Casa - SERVIDOR)       ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""

# 1. Checagem de Conexão à Internet
log_step "[1/6] Testando conexão com a internet..."
if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    log_success "Internet OK"
else
    log_error "FALHA na internet! Verifique a conexão de rede."
    exit 1
fi

# 2. Checagem do Tailscale
log_step "[2/6] Verificando Tailscale (IP estático imutável)..."
ensure_tailscale
MY_TS_IP=$(tailscale ip -4 2>/dev/null || echo "")

# 3. Checagem do OpenSSH
log_step "[3/6] Verificando SSH daemon..."
ensure_sshd

# 4. Checagem e Configuração do RustDesk
log_step "[4/6] Verificando e ativando RustDesk..."
ensure_rustdesk
RUST_ID=$(rustdesk --get-id 2>/dev/null || echo "$CASA_RUSTDESK_ID")

# 5. Checagem e Configuração do Sunshine (Moonlight Host)
log_step "[5/6] Verificando Sunshine (Host 60fps)..."
ensure_sunshine

# 6. Gerenciamento de Energia e Suspensão
log_step "[6/6] Verificando prevenção de suspensão / sleep..."
if pgrep -f "prevent_sleep.sh" &>/dev/null; then
    log_success "Inibidor prevent_sleep.sh já está em execução!"
else
    echo -e "${YELLOW}Deseja iniciar o inibidor de sleep (prevent_sleep.sh) em segundo plano agora? (S/n)${NC}"
    read -r -t 8 resp || resp="s"
    if [[ "$resp" =~ ^[sSyY]$ ]] || [[ -z "$resp" ]]; then
        nohup "$SCRIPT_DIR/prevent_sleep.sh" >/dev/null 2>&1 &
        log_success "Inibidor de sleep iniciado em segundo plano!"
    fi
fi

# 7. Resumo Final
echo ""
echo -e "${BLUE}===================================================================${NC}"
echo -e "${GREEN}       TUDO PRONTO! OMARCHY-CASA PREPARADO COMO SERVIDOR           ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""
echo -e "Anote ou tire foto destes dados antes de ir para o trabalho:"
echo -e "  • ${YELLOW}Dispositivo:${NC}                     Omarchy-Casa ($CASA_HOSTNAME)"
echo -e "  • ${YELLOW}IP Tailscale (Fixo):${NC}             $MY_TS_IP"
echo -e "  • ${YELLOW}RustDesk ID:${NC}                     $RUST_ID"
echo -e "  • ${YELLOW}Senha Fixa (RustDesk/sudo/SSH):${NC}  $DEFAULT_PASS"
echo -e "  • ${YELLOW}Sunshine Web UI:${NC}                 https://localhost:47990/"
echo ""
echo -e "${BLUE}Como conectar a partir do Omarchy-Trabalho:${NC}"
echo -e "  1. No trabalho, entre no repo e execute:"
echo -e "     ${GREEN}./connect_from_work.sh${NC}"
echo -e "  2. Ou use direto o RustDesk no ID: ${YELLOW}$RUST_ID${NC} (Senha: ${YELLOW}$DEFAULT_PASS${NC})"
echo -e "  3. Ou terminal direto: ${YELLOW}ssh walbarellos@$MY_TS_IP${NC} (Senha: ${YELLOW}$DEFAULT_PASS${NC})"
echo ""
echo -e "${RED}CHECKLIST ANTES DE SAIR DE CASA:${NC}"
echo -e "  [✔] PC ligado na tomada"
echo -e "  [✔] Chromium aberto com a aba do teste do banco"
echo -e "  [✔] Não desligar nem suspender"
echo -e "${BLUE}===================================================================${NC}"
