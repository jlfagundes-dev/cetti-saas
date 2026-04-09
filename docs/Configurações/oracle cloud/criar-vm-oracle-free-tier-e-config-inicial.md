# 📘 Guia rápido: VM Oracle Free Tier + Docker Compose

## Objetivo
Configurar uma VM gratuita na Oracle Cloud para rodar **Traefik + n8n + Evolution API** com persistência de dados e acesso seguro via SSH.

## Passos principais
1. **Criar VM Free Tier**  
   - Shape: `VM.Standard.E2.1.Micro`  
   - Imagem: Ubuntu 24.04  
   - IP público habilitado  
   - Porta 22 liberada para SSH  

2. **Instalar Docker e Docker Compose**  
   - Atualizar pacotes  
   - Instalar Docker e habilitar serviço  
   - Instalar Docker Compose  

3. **Configurar permissões**  
   - Adicionar usuário `ubuntu` ao grupo `docker`  
   - Criar diretório `~/cetti-stack/volumes` para persistência  
   - Ajustar permissões (`ubuntu:ubuntu`, chmod 755)  

4. **Criar arquivos do projeto**  
   - `docker-compose.yml` com serviços (Traefik, Postgres, Redis, n8n, Evolution API)  
   - `.env` com variáveis de ambiente (domínio, senhas, chaves)  

5. **Criar rede externa do Traefik**  
   ```bash
   docker network create traefik
   ```

6. **Subir containers**  
   - `docker-compose up -d`  
   - Verificar com `docker ps`  

7. **Configurar DNS**  
   - `n8n.cetti.me → IP público da VM`  
   - `api.cetti.me → IP público da VM`  
   - Traefik gera certificados SSL automaticamente  

---

## ⚠️ Orientações adicionais
- O comando `docker network create traefik` deve ser executado **antes** de rodar `docker-compose up -d`.  
- É necessário criar manualmente os arquivos `docker-compose.yml` e `.env` dentro de `~/cetti-stack` antes de subir os containers.

---

# ⚙️ Script de instalação

Salve como `setup.sh` e rode com:
```bash
chmod +x setup.sh
./setup.sh
```

```bash
#!/bin/bash

# Atualizar pacotes
sudo apt update && sudo apt upgrade -y

# Instalar Docker e Compose
sudo apt install docker.io docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker

# Adicionar usuário ubuntu ao grupo docker
sudo usermod -aG docker ubuntu

# Criar diretórios do projeto
mkdir -p ~/cetti-stack/volumes/{n8n,evolution,postgres,redis,letsencrypt}

# Ajustar permissões
sudo chown -R ubuntu:ubuntu ~/cetti-stack/volumes
sudo chmod -R 755 ~/cetti-stack/volumes

# Criar rede externa para Traefik
docker network create traefik

# Mensagem final
echo "Setup concluído. Saia e reconecte via SSH para aplicar permissões do grupo docker."
echo "Depois, vá até ~/cetti-stack, crie os arquivos docker-compose.yml e .env, e rode: docker-compose up -d"
```

---
