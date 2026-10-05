# Test Case AntiFraud - Testbirds

Este repositório contém todos os scripts, ferramentas e configurações necessárias para completar o teste **"Help prevent fraud!"** da Testbirds com segurança, garantindo que você possa realizar as transações remotas a partir do **Omarchy-Casa** controlando o **Omarchy-2-Trabalho** sem risco de desconexão por IPs dinâmicos.

---

## 🔒 Como a questão de IPs dinâmicos foi resolvida:
Nem a rede do trabalho nem a sua operadora de internet em casa possuem IPs fixos. Para resolver isso:
- **Tailscale Mesh (WireGuard):** O computador **Omarchy-2-Trabalho** tem o IP fixo e imutável **`100.81.170.85`**. Não importa se a rede cair ou o IP público trocar, o túnel se reestabelece automaticamente.
- **Tailscale SSH:** Acesso de emergência por terminal direto sem depender de portas abertas no roteador.
- **RustDesk ID (`115406459`):** Permite acesso gráfico direto via ID global ou direto pelo IP Tailscale (`100.81.170.85`).

---

## 📁 Estrutura dos Arquivos:

- **`validate_trabalho_server.sh`**: Script para rodar no **Omarchy-2-Trabalho** antes de sair. Ele testa a conexão, verifica o Tailscale, valida o RustDesk e confere se a máquina está pronta.
- **`prevent_sleep.sh`**: Script que inibe a suspensão do sistema via systemd e faz pings periódicos para o firewall da rede corporativa não derrubar a conexão NAT.
- **`connect_from_home.sh`**: Script para rodar no seu **Omarchy-Casa**. Ele testa o túnel e abre o RustDesk direto no Omarchy-2-Trabalho.
- **`generate_fake_data.sh`**: Gerador de dados bancários (Payee name, Sort code, Account number, Reference, Amount) para preencher os formulários à mão.
- **`creds.txt`**: Suas credenciais de login no banco simulado.

---

## 🚀 Passo a Passo:

### 1. No Omarchy-2-Trabalho (Antes de sair):
1. No terminal do repositório, execute:
   ```bash
   chmod +x *.sh
   ./validate_trabalho_server.sh
   ```
2. Defina uma senha no **RustDesk** (se ainda não o fez) para acesso não assistido.
3. Deixe o Chromium aberto com a aba do banco simulado.
4. Execute o inibidor de sleep em segundo plano:
   ```bash
   ./prevent_sleep.sh &
   ```
5. Deixe o computador ligado e vá para casa.

---

### 2. No Omarchy-Casa:
1. Clone ou dê `git pull` neste repositório:
   ```bash
   git clone git@github.com:walbarellos/Test_Case_AntiFraud.git
   cd Test_Case_AntiFraud
   chmod +x *.sh
   ```
2. Execute o script de conexão:
   ```bash
   ./connect_from_home.sh
   ```
3. O script testará o link do Tailscale e abrirá o RustDesk conectando no ID **`115406459`** (ou use o IP `100.81.170.85`). Digite sua senha.
4. Você verá a tela do Omarchy-2-Trabalho com o Chromium aberto!

---

### 3. Formulário do Testbirds:
- **Browser:** `Chromium`
- **Version:** `152.0.7977.82`
- **Device to remote control:** `Desktop PC (Linux / Omarchy - Omarchy-Casa)`

---

### 4. Ciclos de Teste:
1. **Ciclos 1 a 9 (Locais):**
   - Feitos diretamente na máquina local (**Omarchy-2-Trabalho**) com prints a cada 3 ciclos (3/9, 6/9, 9/9).
2. **Ciclos 10 a 12 (Remotos):**
   - Feitos a partir do **Omarchy-Casa** através da janela do RustDesk operando o Chromium do Omarchy-2-Trabalho.
   - Responda às perguntas do Testcase 11:
     - *"Before you continue"* -> `Remote – I'm controlling this device from elsewhere`
     - *"What distance"* -> `A different location`
     - *"Roughly how far away"* -> Selecione a distância aproximada (ex: `Under 10 km` ou `10–100 km`)
     - *"Which tool"* -> `Another tool` (RustDesk)
   - Grave o vídeo mostrando a janela do RustDesk controlando o Chromium remoto (via OBS Studio de casa ou filmando com o celular).
   - Tire o print final (12/12) e envie o relatório.
