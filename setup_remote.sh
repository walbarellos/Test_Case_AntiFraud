#!/usr/bin/env bash

# ==============================================================================
# Script de Configuração Rápida & Delegação para o Remote Toolkit
# Repositório: https://github.com/walbarellos/Test_Case_AntiFraud
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Se passar argumentos, repassa diretamente ao remote.sh
if [[ $# -gt 0 ]]; then
    exec "$SCRIPT_DIR/remote.sh" "$@"
fi

# Executa o assistente mestre inteligente
exec "$SCRIPT_DIR/remote.sh"
