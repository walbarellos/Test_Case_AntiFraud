#!/usr/bin/env bash

# ==============================================================================
# Script de Conexão: EXECUTAR NO Omarchy-Trabalho (Para Controlar Omarchy-Casa)
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}   CONEXÃO PARA Omarchy-Casa (EXECUTAR DO TRABALHO - O INVERSO)    ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""

# 1. Checagem do Tailscale local (Trabalho)
log_step "[1/4] Verificando Tailscale no Omarchy-Trabalho..."
ensure_tailscale

# 2. Testar conectividade com o Omarchy-Casa
log_step "[2/4] Testando conexão com Omarchy-Casa ($CASA_IP)..."
if ping -c 2 -W 3 "$CASA_IP" &>/dev/null; then
    log_success "ONLINE! Máquina Omarchy-Casa respondendo perfeitamente ($CASA_IP)."
else
    log_warn "Tentando novamente contato com Omarchy-Casa..."
    if ! ping -c 3 -W 5 "$CASA_IP" &>/dev/null; then
        log_error "Sem resposta imediata de ping para $CASA_IP."
        log_warn "Continuando... O túnel pode estar ajustando as rotas."
    else
        log_success "ONLINE após ajuste de rota!"
    fi
fi

# 3. Teste do SSH
log_step "[3/4] Testando conectividade SSH com Casa..."
if ssh -o ConnectTimeout=4 -o StrictHostKeyChecking=no "walbarellos@$CASA_IP" echo "SSH_OK" &>/dev/null; then
    log_success "SSH acessível sem senha / chave autorizada!"
elif nc -z -w 2 "$CASA_IP" 22 2>/dev/null || bash -c "timeout 2 bash -c '</dev/tcp/$CASA_IP/22'" 2>/dev/null; then
    log_success "Porta SSH 22 aberta! (Senha: $DEFAULT_PASS)"
else
    log_warn "Porta SSH não respondeu no timeout (o túnel Tailscale pode usar SSH embutido)."
fi

# 4. Escolha do método de conexão
echo ""
echo -e "${BLUE}[4/4] Opções de Controle Remoto do Omarchy-Casa:${NC}"
echo -e "  1. ${GREEN}Conectar via RustDesk (Recomendado - ID: $CASA_RUSTDESK_ID | Senha: $DEFAULT_PASS)${NC}"
echo -e "  2. ${CYAN}Conectar via Moonlight (Streaming 60fps - Host: $CASA_IP)${NC}"
echo -e "  3. ${YELLOW}Abrir terminal SSH no Omarchy-Casa (walbarellos@$CASA_IP)${NC}"
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
        log_success "Iniciando RustDesk e conectando no Omarchy-Casa via IP Direto Tailscale..."
        echo -e "  • ${YELLOW}IP Direto Tailscale:${NC}  $CASA_IP"
        echo -e "  • ${YELLOW}ID Alternativo:${NC}       $CASA_RUSTDESK_ID"
        echo -e "  • ${YELLOW}Senha:${NC}                $DEFAULT_PASS"
        echo ""
        rustdesk --connect "$CASA_IP" &>/dev/null &
        ;;
    2)
        ensure_moonlight
        log_success "Iniciando Moonlight..."
        echo -e "  • Conecte no IP de Casa: ${YELLOW}$CASA_IP${NC}"
        moonlight stream "$CASA_IP" "Desktop" 2>/dev/null || moonlight &
        ;;
    3)
        log_info "Conectando via SSH ao Omarchy-Casa..."
        if command -v sshpass &>/dev/null; then
            sshpass -p "$DEFAULT_PASS" ssh -o StrictHostKeyChecking=no "walbarellos@$CASA_IP"
        else
            echo -e "Digite a senha se solicitado: ${YELLOW}$DEFAULT_PASS${NC}"
            ssh -o StrictHostKeyChecking=no "walbarellos@$CASA_IP"
        fi
        ;;
    *)
        echo "Operação finalizada."
        ;;
esac

echo ""
echo -e "${BLUE}===================================================================${NC}"
echo -e "${YELLOW}LEMBRETE PARA GRAVAÇÃO DO VÍDEO (Testbirds):${NC}"
echo -e "  - Inicie a gravação no Omarchy-Trabalho (OBS Studio ou filme com o celular)."
echo -e "  - Mostre a janela do RustDesk/Moonlight conectada no Omarchy-Casa."
echo -e "  - Realize as ações solicitadas no Chromium de Casa."
echo -e "  - Vídeo de 15 a 30 segundos é suficiente."
echo -e "${BLUE}===================================================================${NC}"
