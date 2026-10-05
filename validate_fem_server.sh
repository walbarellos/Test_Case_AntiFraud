#!/usr/bin/env bash

# ==============================================================================
# Script de Validação e Preparação do Servidor na FEM
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   TESTBIRDS ANTI-FRAUD: VALIDAÇÃO DO SERVIDOR (FEM)  ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# 1. Checagem de Conexão à Internet
echo -n "[1/6] Testando conexão com a internet... "
if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHA! Verifique o cabo de rede/Wi-Fi.${NC}"
    exit 1
fi

# 2. Checagem do Tailscale
echo -n "[2/6] Verificando Tailscale (IP estático contra troca de IPs)... "
if ! command -v tailscale &>/dev/null; then
    echo -e "${RED}Tailscale não encontrado! Instale com 'sudo pacman -S tailscale'.${NC}"
    exit 1
fi

TAILSCALE_STATUS=$(tailscale status 2>&1 || true)
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")

if [[ -n "$TAILSCALE_IP" ]]; then
    echo -e "${GREEN}ATIVO ($TAILSCALE_IP)${NC}"
else
    echo -e "${YELLOW}Tailscale desconectado. Conectando...${NC}"
    sudo tailscale up --ssh
    TAILSCALE_IP=$(tailscale ip -4)
    echo -e "${GREEN}Conectado! IP: $TAILSCALE_IP${NC}"
fi

# 3. Checagem do Tailscale SSH
echo -n "[3/6] Verificando Tailscale SSH (acesso remoto de emergência)... "
if tailscale status --json 2>/dev/null | grep -q "https://tailscale.com/cap/ssh"; then
    echo -e "${GREEN}HABILITADO${NC}"
else
    echo -e "${YELLOW}Não ativado. Ativando agora...${NC}"
    sudo tailscale up --ssh
    echo -e "${GREEN}Tailscale SSH ativado!${NC}"
fi

# 4. Checagem e Configuração do RustDesk
echo -n "[4/6] Verificando RustDesk... "
if ! command -v rustdesk &>/dev/null; then
    echo -e "${RED}RustDesk não encontrado! Instale com 'yay -S rustdesk-bin'.${NC}"
    exit 1
fi

RUSTDESK_ID=$(rustdesk --get-id 2>/dev/null || echo "Desconhecido")
echo -e "${GREEN}INSTALADO (ID: $RUSTDESK_ID)${NC}"

# Garantir serviço do RustDesk habilitado
if ! systemctl is-active --quiet rustdesk; then
    echo "       Iniciando serviço systemd do RustDesk..."
    sudo systemctl enable --now rustdesk 2>/dev/null || true
fi

# 5. Configurar Senha Fixa de Acesso Não Assistido
echo ""
echo -e "${YELLOW}Deseja definir/atualizar a senha de acesso não assistido do RustDesk agora? (s/N)${NC}"
read -r -t 10 resp || resp="n"
if [[ "$resp" =~ ^[sSyY]$ ]]; then
    read -sp "Digite a senha fixa que deseja usar para conectar de casa: " PASSWD
    echo ""
    if [[ -n "$PASSWD" ]]; then
        sudo rustdesk --password "$PASSWD"
        echo -e "${GREEN}Senha configurada com sucesso no RustDesk!${NC}"
    fi
fi

# 6. Prevenção de Suspensão / Sleep
echo ""
echo -e "[5/6] Verificando gerenciamento de energia (evitar suspensão)..."
if systemctl is-active --quiet sleep.target || systemctl is-active --quiet suspend.target; then
    echo -e "${YELLOW}       Aviso: Targets de suspensão detectados ativos.${NC}"
else
    echo -e "${GREEN}       Suspensão inativa.${NC}"
fi

# 7. Resumo Final
echo ""
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}           TUDO PRONTO! MÁQUINA VALIDADA             ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "Anote ou tire foto destes dados antes de sair da FEM:"
echo -e "  • ${YELLOW}IP Tailscale (Fixo e Imutável):${NC}  $TAILSCALE_IP"
echo -e "  • ${YELLOW}Hostname Tailscale:${NC}             walbarellos-fem"
echo -e "  • ${YELLOW}RustDesk ID:${NC}                    $RUSTDESK_ID"
echo ""
echo -e "${BLUE}Como conectar quando chegar em CASA:${NC}"
echo -e "  1. No PC de casa, certifique-se de que o Tailscale está logado na sua conta."
echo -e "  2. Teste o terminal:  ${YELLOW}ssh walbarellos@$TAILSCALE_IP${NC} (ou ${YELLOW}ssh walbarellos@walbarellos-fem${NC})"
echo -e "  3. No RustDesk de casa, conecte digitando o ID: ${YELLOW}$RUSTDESK_ID${NC}"
echo -e "     (Ou direto pelo IP Tailscale: ${YELLOW}$TAILSCALE_IP${NC})"
echo ""
echo -e "${RED}LEMBRETE ANTES DE SAIR DA FEM:${NC}"
echo -e "  - Deixe o PC ligado na tomada."
echo -e "  - Deixe o Chromium aberto com a página do teste."
echo -e "  - Não desligue nem suspenda o computador."
echo -e "  - Para garantir 100% que o PC não dormirá, você pode rodar em segundo plano:"
echo -e "    ${YELLOW}./prevent_sleep.sh &${NC}"
echo -e "${BLUE}======================================================${NC}"
