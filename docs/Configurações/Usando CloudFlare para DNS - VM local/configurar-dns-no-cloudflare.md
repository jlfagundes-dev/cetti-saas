# 📘 Documentação: Configuração de Domínio e Cloudflare Tunnel

## 1. Registro e ativação do domínio
- Registrar o domínio (ex.: **cetti.me**) na **Namecheap** via GitHub Student.  
- Confirmar que o domínio está ativo e acessível no painel da Namecheap.

## 2. Adicionar o domínio ao Cloudflare
- Acessar [dash.cloudflare.com](https://dash.cloudflare.com).  
- No painel da conta, clicar em **Onboard a domain**.  
- Inserir o domínio **cetti.me**.  
- Selecionar o plano **Free**.  
- Revisar os registros DNS escaneados pelo Cloudflare.  
- Copiar os **nameservers** fornecidos pelo Cloudflare.  
- Alterar os nameservers na Namecheap:  
  - **Domain List → Manage → Nameservers → Custom DNS**.  
  - Inserir os dois nameservers do Cloudflare.  
- Voltar ao Cloudflare e clicar em **Done, check nameservers**.  
- Aguardar propagação (até 24h).  
- Confirmar que o domínio aparece como **Active** no painel.

## 3. Instalar e configurar o Cloudflared
No notebook (Windows 11):
```bash
winget install Cloudflare.cloudflared
cloudflared tunnel login
```
- O login abre o navegador e autentica a conta Cloudflare.  
- Criar o túnel:
```bash
cloudflared tunnel create cetti-tunnel
```

## 4. Associar subdomínios ao túnel
```bash
cloudflared tunnel route dns cetti-tunnel n8n.cetti.me
cloudflared tunnel route dns cetti-tunnel api.cetti.me
cloudflared tunnel route dns cetti-tunnel chat.cetti.me
```

## 5. Configurar serviços locais
Criar o arquivo `config.yml` em `C:\Users\<SEU_USUARIO>\.cloudflared\config.yml`:

```yaml
tunnel: cetti-tunnel
credentials-file: C:\Users\<SEU_USUARIO>\.cloudflared\1dde9e7a-e6f6-480d-af81-2667bc3cdf3e.json #exemplo tem que ser o arquivo da pasta que foi criada ao criar o tunel

ingress:
  - hostname: n8n.cetti.me
    service: http://localhost:5678
  - hostname: api.cetti.me
    service: http://localhost:8080
  - hostname: chat.cetti.me
    service: http://localhost:3000
  - service: http_status:404
```

## 6. Rodar o túnel
```bash
cloudflared tunnel run cetti-tunnel
```

## 7. Resultado esperado
- `https://n8n.cetti.me` → acessa o n8n rodando na porta 5678.  
- `https://api.cetti.me` → acessa a API local na porta 8080.  
- `https://chat.cetti.me` → acessa o Chatwoot na porta 3000.  
- Todos com SSL automático e sem abrir portas no roteador.

---