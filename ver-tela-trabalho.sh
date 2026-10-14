#!/usr/bin/env bash
# Comando EXATO testado em 13/10 que abriu a tela do trabalho (fem).
# Executar NESTA maquina (casa/lab). Exige fem online: Tailscale + Sunshine.
#
# Teste que funcionou (fullscreen, padrao do Moonlight.conf 1280x720):
#   WAYLAND_DISPLAY=wayland-1 DISPLAY=:0 moonlight stream 100.81.170.85 Desktop
#   -> video HEVC fluiu (~1.4GB), janela abriu no Hyprland.
#
# Uso seguro (janelado): ./ver-tela-trabalho.sh
# Teste literal (fullscreen): FULLSCREEN=1 ./ver-tela-trabalho.sh
# Sair: Ctrl+Alt+Shift+Q
# Se travar: outro terminal e pkill -f '[m]oonlight stream'

set -e
HOST="100.81.170.85"
APP="Desktop"

echo "== [1/2] pareamento =="
timeout 20 moonlight list "$HOST"   # esperado: Desktop / Low Res Desktop / Steam Big Picture

echo "== [2/2] abrindo tela (SAIR: Ctrl+Alt+Shift+Q) =="
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export DISPLAY="${DISPLAY:-:0}"
if [[ "${FULLSCREEN:-0}" == "1" ]]; then
    exec moonlight stream "$HOST" "$APP"
else
    exec moonlight stream "$HOST" "$APP" \
        --display-mode windowed --720 --fps 30 --bitrate 3000 \
        --video-codec H.264
fi
