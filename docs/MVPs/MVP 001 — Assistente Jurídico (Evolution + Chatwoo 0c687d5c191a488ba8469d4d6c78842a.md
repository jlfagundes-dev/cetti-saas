# MVP 001 — Assistente Jurídico da Cetti (Evolution + Chatwoot + n8n)

### 1) Objetivo do MVP

- Problema que resolve: Atender leads e clientes de um escritório via WhatsApp com triagem, coleta de dados/documentos, organização e agendamento — com rastreabilidade do processo.
- Persona / usuário: Cliente final do escritório (WhatsApp) e equipe do escritório (Chatwoot).
- Resultado esperado:
    - Cliente consegue tirar dúvidas iniciais, ser qualificado e agendar reunião.
    - Documentos recebidos ficam organizados no Drive e registrados no banco.
    - Escritório tem visão de status/pipeline por cliente e documentos.

### 2) Escopo (o que entra / o que não entra)

- Entra:
    - WhatsApp (número de teste WABA) → Chatwoot → n8n (orquestração)
    - Suporte a: texto, áudio, imagem e documentos
    - Memória/histórico (Postgres ou Redis) e cadastro do cliente (Postgres preferencial)
    - Classificação do serviço via Google Sheets (catálogo de serviços do escritório)
    - Organização automática de pastas e arquivos no Google Drive
    - Agendamento de reunião no Google Calendar + notificação em grupo no WhatsApp
    - Respostas “humanas” (mensagens picadas) + debounce para mensagens picadas do cliente
- Não entra (por enquanto):
    - Integração com tribunais / acompanhamento processual automatizado real
    - Assinatura digital / protocolo automático em sistemas externos
    - Painel próprio além do Chatwoot

### 3) Arquitetura (alto nível)

- Canais de entrada:
    - WhatsApp (WABA teste) via Evolution API
    - Eventos do Chatwoot (ex: message_created)
- Orquestração (n8n):
    - Workflow “cérebro” que roteia tipo de mensagem e chama sub-workflows modulares
- Atendimento (Chatwoot):
    - Multi-tenant por Account (1 por cliente do Chatwoot)
    - Inbox por canal WhatsApp/API
- Memória/DB:
    - Postgres: clientes, documentos, pipeline, logs
    - Redis: debounce/cache curto para juntar mensagens picadas
    - (Opcional futuro) pgvector para embeddings e busca semântica em documentos
- Files (Drive):
    - Pastas por cliente + subpastas por tipo/etapa
    - Links persistidos no Postgres
- Agenda (Calendar):
    - Criação de evento após qualificação
    - Notificação para grupo do WhatsApp quando reunião marcada

### 4) Fluxos (módulos n8n)

- Fluxo A — Entrada/Normalização (Cérebro)
    - Trigger: webhook Chatwoot (message_created)
    - Debounce por whatsapp_id no Redis (5–10s) para juntar mensagens picadas
    - Roteador por tipo (texto/áudio/imagem/documento)
- Fluxo B — Agente/IA + Qualificação
    - Monta contexto do cliente (carrega/atualiza cadastro no Postgres)
    - Lê catálogo de serviços no Google Sheets e classifica intenção/serviço
    - Decide próximos passos: pedir dados, pedir docs, responder dúvida, propor agendamento
- Fluxo C — Documentos/Drive
    - OCR/extração + análise IA para identificar tipo do doc
    - Cria/verifica pasta do cliente no Drive
    - Faz upload, retorna link e registra em documentos + status_etapa
- Fluxo D — Agendamento/Notificações
    - Cria evento no Google Calendar
    - Envia confirmação ao cliente
    - Envia aviso para grupo (advogados/equipe) no WhatsApp
- Fluxo E — Resposta “natural”
    - Split da resposta em 2–4 mensagens
    - Wait randômico entre envios

### 5) Modelo de dados (SQL)

```sql
-- Cliente
CREATE TABLE clientes (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	whatsapp_id VARCHAR(50) UNIQUE,
	nome VARCHAR(255),
	email VARCHAR(255),
	status_processo VARCHAR(50) DEFAULT 'Triagem',
	drive_folder_id VARCHAR(100),
	created_at TIMESTAMP DEFAULT NOW()
);

-- Documentos + pipeline
CREATE TABLE documentos (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	cliente_id UUID REFERENCES clientes(id),
	nome_arquivo VARCHAR(255),
	tipo_documento VARCHAR(100),
	url_drive TEXT,
	status_etapa VARCHAR(100),
	resumo_ia TEXT,
	created_at TIMESTAMP DEFAULT NOW()
);

-- (Futuro) embeddings
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE documento_embeddings (
	id SERIAL PRIMARY KEY,
	documento_id UUID REFERENCES documentos(id),
	embedding vector(1536),
	conteudo TEXT
);
```

### 6) Prompts que funcionaram

#### Prompt 1 — Arquitetura modular + modelagem DB

**Contexto/objetivo:** gerar desenho do MVP (fluxos n8n modulares) + modelagem inicial em Postgres.

**Prompt (original):**

```
Você é um especialista em automação, crie um json com um fluxo no n8n, onde você tem um número de teste do waba, quer usar chatwoot pra ter controle sobre o whatsapp e crie um assistente jurídico que atende cliente, tira dúvidas, cadastra cliente, agenda reunião no Google calendar e analisa documentos e salva em pastas organizadas no, Google drive, ao que receber uma mensagem no whatsapp de teste da waba, passe pelo chatwoot, e iniciei o fluxo, nesse fluxo você entenderá mensagem de texto, mensagem de voz, imagem e documentos, se for texto você passa pela ia que terá memória postgres ou redis para histórico do chat, você fará o cadastro do cliente em um banco de dados gratuito, pode ser MariadB ou até mesmo postgres, acredito que o postgres é melhor porque vai permitir vetorizar e vai permitir buscar clientes cadastrados e documentos deste cliente, faça toda a modelagem do banco para esse contexto do assistente, se for mensagem de áudio transcrever com ia grátis e seguir o fluxo da mensagem de texto, ser for documento ou imagem analisa com ia, identifica e cria pastas no Google drive para organizar e salva lá, mantenha esse registro no banco para controle e possibilidade de gerar relatórios por cliente e status do processo com pipeline do caminho que o documento percorreu, exemplo decisão primeira instância, aguardando decisão do juiz, petição protocolada, além disso aí atender um cliente, qualificar ele através de uma planilha no Google sheets com os serviços que o escritório de advogados presta, usar ia para ler essa planilha e classificar o cliente antes de marcar a reunião e já pedir documentos essenciais, outro ponto o assistente tem que permitir enviar mensagem de resposta para o cliente via ia e estas mensagens podem ser picadas para dar mais naturalidade e também tem que ter cache para receber mensagens picadas do cliente, exemplo, oi, quero, saber, sobre, meu direto. O cliente pode mandar essa mensagem picadas não sei em um texto único e também é preciso mandar uma mensagem para um grupo no whatsapp quando tiver uma reunião agendada, você deve criar fluxos separados e juntar eles, por exemplo um fluxo para agendar no Google calendário, outro pra salvar no drive, outro pra consultar planilha Google com os serviços, para que possa ser possível modularizar este fluxo geral
```

**Resultado (colado):**

```
Arquitetura modular (Fluxos A/B/C/D), modelagem Postgres (clientes, documentos, embeddings), debounce Redis para mensagens picadas, análise de mídia (voz/imagem/docs), organização Drive e agendamento Calendar.
```

**O que ficou bom / o que melhorar:**

- Bom: modularização por sub-workflows e uso de Postgres como fonte de verdade.
- Melhorar: detalhar o payload real do Chatwoot/Evolution e os estados do pipeline (enum) para relatórios.

#### Prompt 2 — Plano de execução (tarefas para Dev Jr)

**Contexto/objetivo:** quebrar implementação em tarefas diárias curtas, do básico ao integrado.

**Prompt (original):**

```
Agora você é um tech lead, que precisar criar tarefas para um único Dev Jr executar esse projeto, oriente passo a passo desde configurar número teste no waba, a configurar chatwoot para eu administrar e o cliente ter acesso a uma interface, tenho o chatwoot em servidor e quero usar um chatwoot para vários clientes eu ajustando todos mais os clientes também tendo um administrador, configurar PostgreSQL, tudo desde de o básico tarefa a tarefa, tarefas curtas para serem terminadas no mesmo dia, sobre a minha estrutura atual de infra, tenho um docker compose, com n8n, chatwoot, evolution api, redis, e postgres, tudo sobe com docker UP, hoje estou rodando pra testes no meu Pc o docker e criei um túnel cloudflare para expor para web, meu n8n é n8n.cetti.me, evoapi é api.cetti.me, e chatwoot é chat.cetti.me, para produção pretendo subir esse docker em uma vm na nuvem
```

**Resultado (colado):**

```
Plano em sprints de 1 dia: (1) WABA + Chatwoot multi-tenant + Evolution, (2) Postgres + cadastro, (3) IA + Sheets + Whisper, (4) Drive + pipeline, (5) Calendar + notificações + mensagens picadas.
```

**O que ficou bom / o que melhorar:**

- Bom: divisão por entregáveis testáveis por dia.
- Melhorar: adicionar checklist de “definição de pronto” por sprint (inputs/outputs, logs, erros).

### 7) Decisões e trade-offs

- Postgres como DB principal (em vez de MariaDB) por possibilidade de vetorização e busca.
- Redis para debounce/cache curto (evitar múltiplas respostas para mensagens picadas).
- Modularizar n8n com Execute Workflow para manutenção.

### 8) Backlog (tarefas curtas)

- [ ]  Validar evento/payload do Chatwoot (message_created) e mapear campos essenciais
- [ ]  Definir schema final (campos obrigatórios) e enums de status_processo/status_etapa
- [ ]  Implementar debounce Redis por whatsapp_id (janela 5–10s)
- [ ]  Implementar roteamento mídia (texto/áudio/imagem/doc)
- [ ]  Implementar cadastro/busca de cliente no Postgres
- [ ]  Criar integração Google Sheets (catálogo de serviços) + classificação
- [ ]  Criar fluxo Drive (pasta do cliente + upload + registro)
- [ ]  Criar fluxo Calendar (criação do evento + mensagens)
- [ ]  Implementar respostas picadas + delays
- [ ]  Criar tabela de logs de erro e padrão de observabilidade mínima

### 9) Riscos e validações

- Risco: IA alucinar serviço atendido / orientar incorretamente.
- Como validar: obrigar IA a citar “serviço encontrado na planilha” e pedir confirmação antes de agendar.
- Risco: dados sensíveis (LGPD).
- Como validar: mascarar/limitar armazenamento, políticas de retenção e controle de acesso no Chatwoot.

### 10) Próximos passos

- Transformar Backlog em tarefas na base ✅ Tarefas e Backlog.
- Criar primeiro fluxo no n8n: A (Entrada/Normalização) com debounce + roteamento.