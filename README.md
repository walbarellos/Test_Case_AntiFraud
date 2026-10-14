# Test Case AntiFraud & Omarchy Remote Control

Este repositório contém os scripts, ferramentas e automações para completar o teste **"Help prevent fraud!"** da Testbirds ou operar acesso remoto bidirecional entre o **Omarchy-Casa** e o **Omarchy-Trabalho**.

---

## 📋 Tabela Rápida de Identificação e Credenciais

Ambos os computadores rodam **Omarchy (Arch Linux + Hyprland)** e estão conectados na mesma malha mesh do **Tailscale**.

| Máquina | Hostname | IP Tailscale (Fixo) | RustDesk ID | Senha Fixa (sudo / RustDesk / SSH) |
|---|---|---|---|---|
| **Omarchy-Casa** (Servidor / Host) | `walbarellos-lab` | `100.104.40.12` | `160215041` | `betel` |
| **Omarchy-Trabalho** (Cliente / Host) | `walbarellos-fem` | `100.81.170.85` | `115406459` | `betel` |

---

## ⚡ O Script Inteligente: `./remote.sh`

Para não ter que decorar nenhum comando:
```bash
./remote.sh
```
O script **detecta automaticamente** em qual computador você está rodando:
- Se você estiver no **Omarchy-Casa**: sugere automaticamente a opção de **preparar Casa como Servidor** (ou conectar no Trabalho).
- Se você estiver no **Omarchy-Trabalho**: sugere automaticamente a opção de **conectar no Omarchy-Casa** (ou preparar o Trabalho como Servidor).
- Autentica comandos privilegiados usando a senha `betel` automaticamente.

---

## 🎯 CENÁRIO A: Conectar do Trabalho no PC de Casa (O INVERSO)

Este é o fluxo onde você deixa o computador de **Casa** pronto e, ao chegar no **Trabalho**, assume o controle do PC de Casa.

### 1. Aqui em Casa (Antes de sair para o trabalho):
1. Abra o terminal no repositório e execute:
   ```bash
   ./validate_casa_server.sh
   # (ou simplesmente: ./remote.sh)
   ```
2. O script validará o Tailscale, ativará o RustDesk (`160215041`), o Sunshine e o SSH, e iniciará o inibidor de suspensão (`prevent_sleep.sh`).
3. Deixe o Chromium aberto na aba do banco simulado.
4. Mantenha o computador ligado na tomada e vá para o trabalho.

### 2. Lá no Trabalho (Para conectar em Casa):
1. No PC do trabalho, abra o terminal e atualize o repositório:
   ```bash
   cd ~/Test_Case_AntiFraud
   git pull
   chmod +x *.sh
   ./connect_from_work.sh
   # (ou simplesmente: ./remote.sh)
   ```
2. Escolha o método de conexão:
   - **Opção 1 (RustDesk - Recomendada):** Abre o RustDesk conectando direto no ID `160215041` (Senha: `betel`).
   - **Opção 2 (Moonlight):** Stream de ultra-baixa latência 60fps direto no IP `100.104.40.12`.
   - **Opção 3 (Terminal SSH):** Abre terminal remoto em `walbarellos@100.104.40.12` (Senha: `betel`).

---

## 🔄 CENÁRIO B: Conectar de Casa no PC do Trabalho

Este é o fluxo inverso (deixar o Trabalho ligado e controlar a partir de Casa):

### 1. No Trabalho (Antes de sair):
```bash
./validate_trabalho_server.sh
```
- Valida o RustDesk ID (`115406459`), Tailscale (`100.81.170.85`), define senha `betel` e inicia o `prevent_sleep.sh`.

### 2. Em Casa:
```bash
./connect_from_home.sh
```
- Conecta no RustDesk ID `115406459` (ou IP `100.81.170.85`).

---

## 📁 Estrutura dos Arquivos

- **`remote.sh`**: Script mestre inteligente com auto-detecção de máquina e menu contextual.
- **`common.sh`**: Constantes (IPs, IDs, senhas), funções de auto-sudo e instaladores compartilhados.
- **`validate_casa_server.sh`**: Validação e ativação de serviços no Omarchy-Casa.
- **`connect_from_work.sh`**: Disparador de conexão executado no Omarchy-Trabalho.
- **`validate_trabalho_server.sh`**: Validação e ativação de serviços no Omarchy-Trabalho.
- **`connect_from_home.sh`**: Disparador de conexão executado no Omarchy-Casa.
- **`prevent_sleep.sh`**: Inibidor de suspensão (systemd-inhibit) e keepalive de pacotes no Tailscale.
- **`generate_fake_data.sh`**: Gerador de dados bancários falsos para preenchimento dos testes.
- **`creds.txt`**: Credenciais de login no portal simulado do teste.

---

## 🎬 Instruções do Testbirds (Fase Remota - Ciclos 10 a 12):
1. **Respostas do Questionário:**
   - *"Before you continue"* -> `Remote – I'm controlling this device from elsewhere`
   - *"What distance"* -> `A different location`
   - *"Roughly how far away"* -> `Under 10 km` ou `10–100 km`
   - *"Which tool"* -> `Another tool` (RustDesk)
2. **Gravação do Vídeo:**
   - Inicie a gravação no OBS Studio na máquina onde você está digitando (ou filme a tela com o celular).
   - Mostre a janela do RustDesk operando o Chromium remoto.
   - Realize a transação e gere o comprovante final (12/12).
