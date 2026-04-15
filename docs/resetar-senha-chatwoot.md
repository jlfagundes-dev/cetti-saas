# Resetar ou Voltar o Chatwoot ao Estado Inicial

## Objetivo

Este guia serve para dois casos:

1. Voltar o Chatwoot para o estado sem admin/usuários criados.
2. Resetar a senha de um usuário existente quando necessário.

### Como o Chatwoot se comporta

Mesmo com o banco vazio, o Chatwoot normalmente abre direto na tela de login. Ele não mostra uma tela automática de criação de admin. Se não existir usuário, o primeiro admin precisa ser criado manualmente com `rails runner`.

## Cenário 1: Voltar para estado sem admin

Se você criou um usuário de teste por engano e quer deixar o Chatwoot como se nunca tivesse sido configurado, remova o usuário criado:

```bash
docker compose exec -T chatwoot bundle exec rails runner 'user = User.find_by(email: "admin@cetti.me"); user&.destroy!; puts("Usuário removido") if user'
```

Para conferir se ficou vazio:

```bash
docker compose exec -T chatwoot bundle exec rails runner 'puts "Total de usuários: #{User.count}"'
```

### Observação importante

O script `postgres-init` não cria usuário de login do Chatwoot. Ele só:

- cria o banco `cetti_chat`
- garante a extensão `vector`

O usuário citado no PostgreSQL é o usuário de acesso ao banco, definido em `POSTGRES_USER` e `POSTGRES_PASSWORD`. Ele não tem relação com e-mail/senha de login do Chatwoot.

## Reset realmente limpo

Se a intenção for voltar para o fluxo inicial de cadastro do admin, apague o estado persistente completo do Chatwoot:

1. `chatwoot_data` - storage e marcador do primeiro boot
2. `postgres_data` - usuários, contas e configurações
3. `redis_data` - chave de onboarding e cache de sessão

Depois suba a stack de novo. O bootstrap vai ligar o onboarding somente se o banco estiver vazio, evitando forçar cadastro em uma instância já usada.

## Cenário 2: Resetar senha de usuário existente

Se você esqueceu a senha de um usuário já criado no Chatwoot, execute:

```bash
docker compose exec -T chatwoot bundle exec rails runner 'user = User.find_by(email: "seu-email@cetti.me"); user.update!(password: "NOVA_SENHA", password_confirmation: "NOVA_SENHA"); puts "Senha atualizada para: #{user.email}"'
```

**Substitua:**
- `seu-email@cetti.me` → email do usuário
- `NOVA_SENHA` → nova senha desejada

## Cenário 3: Criar usuário admin apenas se realmente precisar

Use este comando só quando quiser recriar um usuário administrador inicial:

```bash
docker compose exec -T chatwoot bundle exec rails runner 'User.create!(email: "admin@cetti.me", password: "Cetti@n8n_2026!", password_confirmation: "Cetti@n8n_2026!", name: "Admin Cetti", confirmed_at: Time.current); puts "User admin@cetti.me criado com sucesso!"'
```

## Cenário 4: Listar todos os usuários

```bash
docker compose exec -T chatwoot bundle exec rails runner 'User.all.each { |u| puts "Email: #{u.email} | ID: #{u.id}" }'
```

## Cenário 5: Deletar usuário específico

```bash
docker compose exec -T chatwoot bundle exec rails runner 'user = User.find_by(email: "seu-email@cetti.me"); user.destroy!; puts "Usuário deletado"'
```

## Cenário 6: Acessar console Rails interativo (avançado)

Se estiver em Linux/Mac:

```bash
docker compose exec chatwoot bundle exec rails console
```

Depois na sessão Ruby, use:

```ruby
# Listar usuários
User.all

# Buscar usuário
user = User.find_by(email: "admin@cetti.me")

# Resetar senha
user.update!(password: "nova_senha", password_confirmation: "nova_senha")

# Sair
exit
```

---

## ⚠️ Importante

- **Senhas fortes:** Use sempre senhas complexas com maiúsculas, minúsculas, números e caracteres especiais
- **URL-encoding:** Se a senha tem caracteres especiais (`@`, `!`, `#`), eles podem precisar de escape em URLs
- **Docker compose:** Execute sempre do diretório raiz do projeto (`/c/projects_cetti/cetti-saas`)
- **Flag `-T`:** Necessário em Windows/Git Bash para evitar erros TTY
- **Estado padrão:** O Chatwoot deve ficar sem admin criado até você decidir criar um usuário manualmente

---

## Histórico de Senhas Padrão (Cetti SaaS)

| Serviço | Email | Senha |
|---------|-------|-------|
| Chatwoot | sem usuário padrão | sem senha padrão |
| n8n | admin | Cetti@n8n_2026! |
| PostgreSQL | cetti | Cetti@postgres_2026! |
| Redis | (sem user) | Cetti@redis_2026! |

---

## Referência: Estrutura do User model Chatwoot

```ruby
# Atributos disponíveis para User
user.id                    # ID único
user.email                 # Email do usuário
user.password_digest       # Hash da senha (nunca modificar diretamente)
user.name                  # Nome completo
user.confirmed_at          # Data de confirmação de email (NULL = não confirmado)
user.created_at            # Data de criação
user.updated_at            # Última atualização
user.account_users         # Contas associadas
```

---

**Criado em:** 15/04/2026  
**Chatwoot Version:** latest  
**Base:** Rails 7.1.5.2
