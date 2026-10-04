#!/usr/bin/env bash

# Gerador de dados falsos para pagamentos no banco simulado (formato UK)

NAMES=("Maria Teste" "João Silva" "Ana Oliveira" "Carlos Souza" "Beatriz Costa" "Fernanda Lima" "Roberto Santos" "Juliana Mendes" "Pedro Alves" "Camila Rocha" "Lucas Pereira" "Mariana Gomes" "Rafael Barbosa" "Larissa Carvalho" "Thiago Martins")
REFS=("aluguel" "internet" "presente" "jantar" "conta de luz" "conta de agua" "mercado" "assinatura" "servicos" "condominio" "doacao" "freelance" "reembolso" "viagem" "escola")

# Sorteia um nome e uma referência
RANDOM_NAME=${NAMES[$RANDOM % ${#NAMES[@]}]}
RANDOM_REF=${REFS[$RANDOM % ${#REFS[@]}]}

# Gera Sort Code (6 dígitos)
SORT_CODE=$(printf "%06d" $((RANDOM % 1000000)))
# Formata como XX-XX-XX
SORT_CODE_FORMATTED="${SORT_CODE:0:2}-${SORT_CODE:2:2}-${SORT_CODE:4:2}"

# Gera Account Number (8 dígitos)
ACCOUNT_NUMBER=$(printf "%08d" $((RANDOM % 100000000)))

# Gera um valor (entre 10.00 e 250.99)
AMOUNT=$(printf "%d.%02d" $((RANDOM % 241 + 10)) $((RANDOM % 100)))

echo "======================================"
echo "DADOS PARA O NOVO PAGAMENTO (Pay Someone New)"
echo "======================================"
echo "Payee name        : $RANDOM_NAME"
echo "Sort code         : $SORT_CODE_FORMATTED"
echo "Account number    : $ACCOUNT_NUMBER"
echo "Payment reference : $RANDOM_REF"
echo "Amount            : $AMOUNT"
echo "======================================"
echo "Lembre-se: Digite à mão no formulário. Não use Control+C / Control+V!"
