#!/usr/bin/env bash

# ==============================================================================
# Script de Conexão: EXECUTAR NO Omarchy-Casa
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REMOTE_WORK_IP="100.81.170.85"
REMOTE_RUSTDESK_ID="115406459"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}     CONEXÃO PARA Omarchy-2-Trabalho (EXECUTAR DE CASA)            ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo ""

# 1. Checagem do Tailscale local
echo -n "[1/4] Verificando Tailscale local no Omarchy-Casa... "
if ! command -v tailscale &>/dev/null; then
    echo -e "${RED}Tailscale não encontrado no Omarchy-Casa!${NC}"
    echo "       Instale com: sudo pacman -S tailscale && sudo systemctl enable --now tailscaled"
    echo "       Em seguida: sudo tailscale up"
    exit 1
fi

HOME_TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")
if [[ -z "$HOME_TAILSCALE_IP" ]]; then
    echo -e "${YELLOW}Tailscale desconectado.${NC}"
    echo "Conectando ao Tailscale..."
    sudo tailscale up
fi
echo -e "${GREEN}OK (Seu IP Tailscale no Omarchy-Casa: $(tailscale ip -4))${NC}"

# 2. Testar conectividade com o Omarchy-2-Trabalho
echo -n "[2/4] Testando conexão com Omarchy-2-Trabalho ($REMOTE_WORK_IP)... "
if ping -c 2 -W 3 "$REMOTE_WORK_IP" &>/dev/null; then
    echo -e "${GREEN}ONLINE! Máquina Omarchy-2-Trabalho respondendo perfeitamente.${NC}"
else
    echo -e "${RED}SEM RESPOSTA DE PING!${NC}"
    echo "       Aguardando 5 segundos e tentando novamente..."
    if ! ping -c 3 -W 5 "$REMOTE_WORK_IP" &>/dev/null; then
        echo -e "${YELLOW}Aviso: Ping bloqueado ou rota ajustando. Continuando...${NC}"
    fi
fi

# 3. Teste do Tailscale SSH
echo -n "[3/4] Testando acesso SSH via Tailscale... "
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "walbarellos@$REMOTE_WORK_IP" echo "SSH_OK" &>/dev/null; then
    echo -e "${GREEN}SSH FUNCIONANDO!${NC}"
else
    echo -e "${YELLOW}SSH aguardando autorização de login ou chave.${NC}"
fi

# 4. Iniciar RustDesk
echo ""
echo -e "[4/4] ${BLUE}Opções de Controle Remoto:${NC}"
echo -e "  1. ${GREEN}Conectar via RustDesk (Recomendado para o vídeo)${NC}"
echo -e "  2. ${YELLOW}Abrir terminal SSH no Omarchy-2-Trabalho${NC}"
echo -e "  3. Sair"
echo ""
read -p "Escolha uma opção [1-3] (padrão: 1): " OPTION
OPTION=${OPTION:-1}

case "$OPTION" in
    1)
        if ! command -v rustdesk &>/dev/null; then
            echo "Instalando RustDesk no Omarchy-Casa..."
            yay -S --needed --noconfirm rustdesk-bin
        fi
        echo -e "${GREEN}Abrindo RustDesk...${NC}"
        echo -e "No RustDesk, conecte no ID: ${YELLOW}$REMOTE_RUSTDESK_ID${NC} (ou pelo IP: ${YELLOW}$REMOTE_WORK_IP${NC})"
        rustdesk &
        ;;
    2)
        echo -e "${GREEN}Conectando ao terminal do Omarchy-2-Trabalho...${NC}"
        ssh "walbarellos@$REMOTE_WORK_IP"
        ;;
    *)
        echo "Operação finalizada."
        ;;
esac

echo ""
echo -e "${BLUE}===================================================================${NC}"
echo -e "${YELLOW}LEMBRETE PARA GRAVAÇÃO DO VÍDEO (Testbirds):${NC}"
echo -e "  - Inicie a gravação no OBS Studio no Omarchy-Casa (ou filme com o celular)."
echo -e "  - Mostre a janela do RustDesk conectada no Omarchy-2-Trabalho."
echo -e "  - Faça as ações no Chromium remoto."
echo -e "  - Vídeo de 15 a 30 segundos é suficiente."
echo -e "${BLUE}===================================================================${NC}"
