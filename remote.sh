#!/usr/bin/env bash

# ==============================================================================
# Script Mestre Inteligente: Detecção Automática e Controle Remoto Omarchy
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${CYAN}${BOLD}         OMARCHY REMOTE CONTROL & ANTI-FRAUD TOOLKIT               ${NC}"
echo -e "${BLUE}===================================================================${NC}"

# Detecção Automática do Ambiente
MACHINE=$(detect_current_machine)
LOCAL_IP=$(tailscale ip -4 2>/dev/null || echo "Desconectado")
HOSTNAME_CURR=$(hostname 2>/dev/null || echo "Desconhecido")

echo ""
echo -e "  • ${BOLD}Máquina Atual:${NC}    $HOSTNAME_CURR"
echo -e "  • ${BOLD}IP Tailscale:${NC}     $LOCAL_IP"
echo -e "  • ${BOLD}Local Detectado:${NC}  ${YELLOW}$MACHINE${NC}"
echo ""

# Argumentos diretos de linha de comando
case "$1" in
    --validate-casa)
        exec "$SCRIPT_DIR/validate_casa_server.sh"
        ;;
    --connect-casa)
        exec "$SCRIPT_DIR/connect_from_work.sh"
        ;;
    --validate-work)
        exec "$SCRIPT_DIR/validate_trabalho_server.sh"
        ;;
    --connect-work)
        exec "$SCRIPT_DIR/connect_from_home.sh"
        ;;
    --sleep)
        exec "$SCRIPT_DIR/prevent_sleep.sh"
        ;;
    --setup)
        ensure_tailscale
        ensure_sshd
        ensure_rustdesk
        ensure_sunshine
        ensure_moonlight
        log_success "Todas as ferramentas instaladas e verificadas!"
        exit 0
        ;;
esac

# Menu Inteligente Contextual
if [[ "$MACHINE" == "CASA" ]]; then
    echo -e "${GREEN}Você está no PC de CASA ($CASA_HOSTNAME).${NC}"
    echo -e "O que você deseja fazer?"
    echo -e "  1. ${BOLD}${GREEN}[PADRÃO] Preparar Casa como SERVIDOR (Para controlar lá do Trabalho)${NC}"
    echo -e "  2. Conectar no PC do Trabalho (Casa -> Trabalho)"
    echo -e "  3. Instalar/Verificar todas as ferramentas locais"
    echo -e "  4. Iniciar inibidor de suspensão (prevent_sleep.sh)"
    echo -e "  5. Sair"
    echo ""
    read -t 10 -p "Escolha [1-5] (Padrão: 1 em 10s): " CHOICE || CHOICE=1
    CHOICE=${CHOICE:-1}

    case "$CHOICE" in
        1) exec "$SCRIPT_DIR/validate_casa_server.sh" ;;
        2) exec "$SCRIPT_DIR/connect_from_home.sh" ;;
        3)
            ensure_tailscale
            ensure_sshd
            ensure_rustdesk
            ensure_sunshine
            ensure_moonlight
            log_success "Ferramentas instaladas e atualizadas!"
            ;;
        4) exec "$SCRIPT_DIR/prevent_sleep.sh" ;;
        *) echo "Saindo..." ;;
    esac

elif [[ "$MACHINE" == "TRABALHO" ]]; then
    echo -e "${GREEN}Você está no PC do TRABALHO ($TRABALHO_HOSTNAME).${NC}"
    echo -e "O que você deseja fazer?"
    echo -e "  1. ${BOLD}${GREEN}[PADRÃO] Conectar no PC de CASA (Trabalho -> Casa - O INVERSO)${NC}"
    echo -e "  2. Preparar e Validar Trabalho como SERVIDOR (Para controlar de Casa)"
    echo -e "  3. Instalar/Verificar todas as ferramentas locais"
    echo -e "  4. Iniciar inibidor de suspensão (prevent_sleep.sh)"
    echo -e "  5. Sair"
    echo ""
    read -t 10 -p "Escolha [1-5] (Padrão: 1 em 10s): " CHOICE || CHOICE=1
    CHOICE=${CHOICE:-1}

    case "$CHOICE" in
        1) exec "$SCRIPT_DIR/connect_from_work.sh" ;;
        2) exec "$SCRIPT_DIR/validate_trabalho_server.sh" ;;
        3)
            ensure_tailscale
            ensure_sshd
            ensure_rustdesk
            ensure_sunshine
            ensure_moonlight
            log_success "Ferramentas instaladas e atualizadas!"
            ;;
        4) exec "$SCRIPT_DIR/prevent_sleep.sh" ;;
        *) echo "Saindo..." ;;
    esac

else
    echo -e "${YELLOW}Ambiente não identificado automaticamente.${NC}"
    echo -e "Escolha o que deseja fazer:"
    echo -e "  1. Conectar no Omarchy-Casa (A partir de outro PC)"
    echo -e "  2. Conectar no Omarchy-Trabalho (A partir de outro PC)"
    echo -e "  3. Preparar ESTE PC como Servidor (Casa)"
    echo -e "  4. Preparar ESTE PC como Servidor (Trabalho)"
    echo -e "  5. Instalar todas as ferramentas"
    echo -e "  6. Sair"
    echo ""
    read -p "Escolha [1-6]: " CHOICE
    case "$CHOICE" in
        1) exec "$SCRIPT_DIR/connect_from_work.sh" ;;
        2) exec "$SCRIPT_DIR/connect_from_home.sh" ;;
        3) exec "$SCRIPT_DIR/validate_casa_server.sh" ;;
        4) exec "$SCRIPT_DIR/validate_trabalho_server.sh" ;;
        5)
            ensure_tailscale
            ensure_sshd
            ensure_rustdesk
            ensure_sunshine
            ensure_moonlight
            ;;
        *) echo "Saindo..." ;;
    esac
fi
