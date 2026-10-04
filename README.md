# Test Case AntiFraud - Testbirds

Este repositório contém os scripts e informações necessárias para completar o teste "Help prevent fraud!" da Testbirds.

## Arquivos:

- **`creds.txt`**: Suas credenciais geradas para login no site do banco simulado.
- **`generate_fake_data.sh`**: Script para gerar dados falsos (Payee name, Sort code, Account number, Reference, Amount) aleatórios. Execute antes de cada ciclo para ter dados novos prontos para digitar.
- **`setup_remote.sh`**: Script para instalar e configurar o **Tailscale** e o **Sunshine** no seu sistema Omarchy (Hyprland + Nvidia GTX 960). Só execute isso *após* terminar os 9 ciclos locais.

## Instruções para os Ciclos:

1. **Ciclos 1 a 9 (Locais)**: 
   - Sempre selecione "Local".
   - Verifique se o botão "LOG OUT" está azul/verde.
   - Use os dados gerados pelo `generate_fake_data.sh`.
   - Após os ciclos 3, 6 e 9, tire print do "Your collection progress" (3/9, 6/9, 9/9) e espere o cooldown.

2. **Ciclos 10 a 12 (Remotos)**:
   - Execute `./setup_remote.sh` no seu PC.
   - Configure o Moonlight no dispositivo que vai controlar o PC.
   - Selecione "Remote", indique a distância e escolha "Another tool".
   - Faça os pagamentos 10, 11 e 12.
   - Tire o último print (12/12).
