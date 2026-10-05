#!/usr/bin/env bash

# ==============================================================================
# Inibidor de Suspensão e Keepalive de Rede para o PC da FEM
# ==============================================================================

echo "====================================================="
echo "   Inibidor de Sleep & Keepalive Ativo (FEM)"
echo "====================================================="
echo "Este script impede que o sistema entre em suspensão"
echo "e envia pings periódicos para manter o NAT ativo no"
echo "firewall da universidade."
echo "Pressione Ctrl+C para encerrar quando retornar."
echo "====================================================="

# Função para manter o túnel NAT aberto
keepalive_loop() {
    while true; do
        # Ping no DERP da Tailscale a cada 25 segundos para manter a conexão aberta no firewall
        ping -c 1 -W 2 100.100.100.100 &>/dev/null || true
        sleep 25
    done
}

keepalive_loop &
KEEPALIVE_PID=$!

trap "kill $KEEPALIVE_PID 2>/dev/null; exit 0" SIGINT SIGTERM EXIT

# Executa o inibidor oficial do systemd
if command -v systemd-inhibit &>/dev/null; then
    systemd-inhibit --what=idle:sleep:shutdown --who="Testbirds AntiFraud" --why="Executando teste remoto a partir de casa" sleep infinity
else
    echo "systemd-inhibit não encontrado. Mantendo processo ativo..."
    while true; do sleep 3600; done
fi
