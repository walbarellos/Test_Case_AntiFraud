#!/usr/bin/env bash

# ==============================================================================
# Funções e Constantes Compartilhadas: Omarchy Remote Toolkit
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Dados das Máquinas
CASA_HOSTNAME="walbarellos-lab"
CASA_IP="100.104.40.12"
CASA_RUSTDESK_ID="160215041"

TRABALHO_HOSTNAME="walbarellos-fem"
TRABALHO_IP="100.81.170.85"
TRABALHO_RUSTDESK_ID="115406459"

DEFAULT_PASS="betel"

# Mensagens formatadas
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[✔]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[⚠]${NC} $*"; }
log_error()   { echo -e "${RED}[✖]${NC} $*"; }
log_step()    { echo -e "\n${CYAN}==>${NC} ${BOLD}$*${NC}"; }

# Executa comando como sudo automaticamente com a senha padrão se necessário
run_sudo() {
    if sudo -n true 2>/dev/null; then
        sudo "$@"
    else
        echo "$DEFAULT_PASS" | sudo -S -p "" "$@" 2>/dev/null || sudo "$@"
    fi
}

# Detecta automaticamente se está no PC de Casa ou do Trabalho
detect_current_machine() {
    local hname=$(hostname 2>/dev/null || echo "")
    local my_ip=$(tailscale ip -4 2>/dev/null || echo "")

    if [[ "$hname" == *"$CASA_HOSTNAME"* ]] || [[ "$my_ip" == "$CASA_IP" ]]; then
        echo "CASA"
    elif [[ "$hname" == *"$TRABALHO_HOSTNAME"* ]] || [[ "$my_ip" == "$TRABALHO_IP" ]]; then
        echo "TRABALHO"
    else
        echo "UNKNOWN"
    fi
}

# Garante que o Tailscale está instalado, iniciado e com Tailscale SSH
ensure_tailscale() {
    log_step "Verificando Tailscale..."
    if ! command -v tailscale &>/dev/null; then
        log_warn "Tailscale não instalado. Instalando via pacman..."
        run_sudo pacman -S --needed --noconfirm tailscale
    fi

    if ! systemctl is-active --quiet tailscaled; then
        log_info "Iniciando tailscaled.service..."
        run_sudo systemctl enable --now tailscaled
        sleep 2
    fi

    local current_ip=$(tailscale ip -4 2>/dev/null || echo "")
    if [[ -z "$current_ip" ]]; then
        log_warn "Tailscale não autenticado. Autenticando com Tailscale SSH..."
        run_sudo tailscale up --ssh
        current_ip=$(tailscale ip -4 2>/dev/null || echo "")
    fi

    log_success "Tailscale ativo! IP local: $current_ip"
}

# Garante que o OpenSSH Daemon está instalado e ativo
ensure_sshd() {
    log_step "Verificando OpenSSH Daemon (sshd)..."
    if ! command -v sshd &>/dev/null; then
        log_warn "OpenSSH não instalado. Instalando..."
        run_sudo pacman -S --needed --noconfirm openssh
    fi

    if ! systemctl is-active --quiet sshd; then
        log_info "Ativando sshd.service..."
        run_sudo systemctl enable --now sshd
    fi
    log_success "sshd.service ativo e pronto para conexões na porta 22."
}

# Garante que o RustDesk está instalado, configurado com a senha e serviço ativo
ensure_rustdesk() {
    log_step "Verificando RustDesk..."
    if ! command -v rustdesk &>/dev/null; then
        log_warn "RustDesk não instalado. Instalando via yay/pacman..."
        if command -v yay &>/dev/null; then
            yay -S --needed --noconfirm rustdesk-bin
        elif command -v pacman &>/dev/null; then
            run_sudo pacman -S --needed --noconfirm rustdesk || true
        fi
    fi

    if command -v rustdesk &>/dev/null; then
        if ! systemctl is-active --quiet rustdesk; then
            log_info "Habilitando serviço do RustDesk..."
            run_sudo systemctl enable --now rustdesk
            sleep 2
        fi

        # Configurar senha padrão fixa para acesso não assistido
        run_sudo rustdesk --password "$DEFAULT_PASS" 2>/dev/null || true
        local rust_id=$(rustdesk --get-id 2>/dev/null || echo "Desconhecido")
        log_success "RustDesk ativo! ID local: $rust_id (Senha: $DEFAULT_PASS)"
    else
        log_error "Não foi possível verificar/instalar o RustDesk."
    fi
}

# Garante que o Sunshine está instalado e ativo
ensure_sunshine() {
    log_step "Verificando Sunshine (Host para Moonlight)..."
    if ! command -v sunshine &>/dev/null; then
        log_warn "Sunshine não instalado. Instalando..."
        run_sudo pacman -S --needed --noconfirm sunshine || yay -S --needed --noconfirm sunshine
    fi

    if command -v sunshine &>/dev/null; then
        # Permissão KMS para Wayland/Hyprland
        run_sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine)) 2>/dev/null || true

        # Ativa o serviço de usuário do Sunshine
        systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service 2>/dev/null || true
        mkdir -p "$HOME/.config/systemd/user"
        ln -sf /usr/lib/systemd/user/app-dev.lizardbyte.app.Sunshine.service "$HOME/.config/systemd/user/sunshine.service" 2>/dev/null || true

        log_success "Sunshine configurado e rodando! Web UI: https://localhost:47990/"
    else
        log_warn "Sunshine não instalado. (Opcional se usar RustDesk)"
    fi
}

# Garante que o Moonlight está instalado
ensure_moonlight() {
    log_step "Verificando Moonlight (Cliente)..."
    if ! command -v moonlight &>/dev/null; then
        log_warn "Moonlight não instalado. Instalando moonlight-qt..."
        run_sudo pacman -S --needed --noconfirm moonlight-qt || true
    fi

    if command -v moonlight &>/dev/null; then
        log_success "Moonlight instalado: $(which moonlight)"
    fi
}
