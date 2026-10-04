#!/usr/bin/env bash

echo "======================================"
echo "Instalação e Configuração: Fase Remota"
echo "======================================"
echo "Este script instalará o Tailscale e o Sunshine (AUR)."
echo "Ele requer privilégios de sudo em alguns momentos."
echo ""

# Instalar Tailscale
echo "[1/4] Instalando Tailscale..."
if ! command -v tailscale &> /dev/null; then
    sudo pacman -S --needed --noconfirm tailscale
    sudo systemctl enable --now tailscaled
    echo "Tailscale instalado. Execute 'sudo tailscale up' para conectar seu dispositivo à rede."
else
    echo "Tailscale já está instalado."
fi

# Instalar Sunshine
echo "[2/4] Instalando Sunshine via yay..."
if ! command -v sunshine &> /dev/null; then
    yay -S --needed --noconfirm sunshine
else
    echo "Sunshine já está instalado."
fi

# Configurar permissões para Wayland (KMS)
echo "[3/4] Configurando capacidades para o Sunshine capturar tela no Wayland (KMS)..."
# Sunshine já tenta aplicar essas permissões no pacote AUR, mas garantimos aqui:
sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

# Avisos sobre o Hyprland e Nvidia
echo "[4/4] Verificação do ambiente (NVIDIA + Hyprland)..."
if grep -q "nvidia-drm.modeset=1" /proc/cmdline; then
    echo "✅ Parâmetro nvidia-drm.modeset=1 detectado no boot. A captura de tela (KMS) deve funcionar."
else
    echo "⚠️ AVISO: 'nvidia-drm.modeset=1' não foi encontrado nos parâmetros de boot do kernel."
    echo "   Para o Sunshine capturar a tela no Hyprland com placas NVIDIA,"
    echo "   é altamente recomendado ativar o KMS (nvidia-drm.modeset=1)."
    echo "   Por favor, adicione isso ao seu gerenciador de boot (GRUB/systemd-boot) se a captura falhar."
fi

echo "======================================"
echo "Configuração concluída."
echo "Para iniciar o Sunshine, você pode rodar:"
echo "systemctl --user enable --now sunshine"
echo ""
echo "Acesse a interface web do Sunshine em: https://localhost:47990/"
echo "======================================"
