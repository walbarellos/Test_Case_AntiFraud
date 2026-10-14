#!/usr/bin/env bash

# ==============================================================================
# Script de Conexão: EXECUTAR NO Omarchy-Casa (Para Controlar Omarchy-Trabalho)
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}     CONEXÃO PARA Omarchy-Trabalho (EXECUTAR DE CASA)              ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""

# 1. Checagem do Tailscale local
log_step "[1/4] Verificando Tailscale local no Omarchy-Casa..."
ensure_tailscale

# 2. Testar conectividade com o Omarchy-Trabalho
log_step "[2/4] Testando conexão com Omarchy-Trabalho ($TRABALHO_IP)..."
if ping -c 2 -W 3 "$TRABALHO_IP" &>/dev/null; then
    log_success "ONLINE! Máquina Omarchy-Trabalho respondendo perfeitamente."
else
    log_warn "Aguardando ajuste de rota com Omarchy-Trabalho..."
    if ! ping -c 3 -W 5 "$TRABALHO_IP" &>/dev/null; then
        log_error "Sem resposta imediata de ping para $TRABALHO_IP."
    else
        log_success "ONLINE!"
    fi
fi

# 3. Teste do Tailscale SSH
log_step "[3/4] Testando acesso SSH..."
if ssh -o ConnectTimeout=4 -o StrictHostKeyChecking=no "walbarellos@$TRABALHO_IP" echo "SSH_OK" &>/dev/null; then
    log_success "SSH FUNCIONANDO SEM SENHA!"
else
    log_warn "SSH disponível (pode solicitar verificação ou senha: $DEFAULT_PASS)."
fi

# 4. Iniciar Conexão Remota
echo ""
echo -e "${BLUE}[4/4] Opções de Controle Remoto do Omarchy-Trabalho:${NC}"
echo -e "  1. ${GREEN}Conectar via RustDesk (Recomendado - ID: $TRABALHO_RUSTDESK_ID)${NC}"
echo -e "  2. ${CYAN}Conectar via Moonlight (Streaming 60fps - Host: $TRABALHO_IP)${NC}"
echo -e "  3. ${YELLOW}Abrir terminal SSH no Omarchy-Trabalho (walbarellos@$TRABALHO_IP)${NC}"
echo -e "  4. Sair"
echo ""

read -p "Escolha uma opção [1-4] (padrão: 1): " OPTION
OPTION=${OPTION:-1}

case "$OPTION" in
    1)
        if ! command -v rustdesk &>/dev/null; then
            log_info "Instalando RustDesk local..."
            if command -v yay &>/dev/null; then
                yay -S --needed --noconfirm rustdesk-bin
            else
                run_sudo pacman -S --needed --noconfirm rustdesk || true
            fi
        fi
        log_success "Abrindo RustDesk via IP Direto Tailscale..."
        echo -e "Conectando no IP: ${YELLOW}$TRABALHO_IP${NC} (ID Alternativo: ${YELLOW}$TRABALHO_RUSTDESK_ID${NC})"
        rustdesk --connect "$TRABALHO_IP" &>/dev/null &
        ;;
    2)
        ensure_moonlight
        log_success "Iniciando Moonlight..."
        moonlight stream "$TRABALHO_IP" "Desktop" 2>/dev/null || moonlight &
        ;;
    3)
        log_info "Conectando ao terminal do Omarchy-Trabalho..."
        if command -v sshpass &>/dev/null; then
            sshpass -p "$DEFAULT_PASS" ssh -o StrictHostKeyChecking=no "walbarellos@$TRABALHO_IP"
        else
            echo -e "Digite a senha se solicitado: ${YELLOW}$DEFAULT_PASS${NC}"
            ssh -o StrictHostKeyChecking=no "walbarellos@$TRABALHO_IP"
        fi
        ;;
    *)
        echo "Operação finalizada."
        ;;
esac

echo ""
echo -e "${BLUE}===================================================================${NC}"
echo -e "${YELLOW}LEMBRETE PARA GRAVAÇÃO DO VÍDEO (Testbirds):${NC}"
echo -e "  - Inicie a gravação no OBS Studio no Omarchy-Casa (ou filme com o celular)."
echo -e "  - Mostre a janela do RustDesk conectada no Omarchy-Trabalho."
echo -e "  - Faça as ações no Chromium remoto."
echo -e "  - Vídeo de 15 a 30 segundos é suficiente."
echo -e "${BLUE}===================================================================${NC}"
