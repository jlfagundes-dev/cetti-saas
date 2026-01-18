# Copilot Instructions — Cetti Agentics SaaS

## Contexto do Projeto

Este repositório faz parte do desenvolvimento do **SaaS da Cetti Agentics**, uma startup focada em **automação, atendimento digital inteligente e agentes de IA** para **pequenas e médias empresas (PMEs)**.

O **produto âncora** da plataforma é o:

**Cetti AIO – Assistente Inteligente Operacional**

O Cetti AIO é o núcleo lógico que dá inteligência a:

* chatbots
* atendimento via WhatsApp
* automações
* agentes conectados

> Princípio central: **vender primeiro, escalar depois, sem overengineering**.

Slogan da empresa:
**“Simplificamos a tecnologia para você crescer.”**

---

## Objetivo do Sistema

O sistema deve permitir:

* Atendimento digital inteligente (WhatsApp como canal principal)
* Automação de fluxos operacionais
* Uso de IA de forma **prática, contextualizada e controlada**
* Evolução gradual para um SaaS multi-tenant

Sempre priorizando:

* baixo custo
* implementação rápida
* valor imediato para o cliente

---

## Estágio do Projeto (Muito Importante)

Este projeto está em **fase inicial (early-stage, pré ou primeiros clientes)**.

Portanto, o Copilot deve **EVITAR** sugerir:

* arquiteturas complexas
* abstrações excessivas
* padrões enterprise
* soluções “para o futuro distante”

O foco é:

> **funcionar bem agora, com possibilidade clara de evolução depois**.

---

## Arquitetura Geral (Visão Atual)

* SaaS **multi-tenant simples**
* Isolamento lógico por cliente (não físico)
* Backend orientado a APIs e eventos
* Forte uso de automação via n8n
* IA como camada de inteligência, não como dependência central rígida

---

## Stack Preferencial (Prioridade Máxima)

### Orquestração e Automação

* **n8n** como core operacional
* Webhooks e fluxos reutilizáveis

### Backend / Integrações

* Node.js / TypeScript (somente quando necessário)
* APIs REST simples
* Webhooks
* Sem frameworks pesados se não forem indispensáveis

### Mensageria / Atendimento

* WhatsApp via **Evolution API**
* **Chatwoot** para atendimento humano (quando aplicável)

### Dados e Estado

* **PostgreSQL** como banco principal
* **Redis** para:

  * filas
  * locks
  * controle de estado
  * rate limiting simples

### Inteligência Artificial

* LLMs via API (OpenAI ou compatíveis, exemplo Groq que tem custo zero inicial)
* Uso de **Prompt Mestre (Cetti AIO)** como base
* Evitar pipelines complexos de RAG no início
* Vetorização somente se houver necessidade real

### Infraestrutura

* Docker / Docker Compose
* Linux (Ubuntu)
* Cloud de baixo custo (Railway, Free Tier, VM simples)
* Um único ambiente no início (sem separar ambientes excessivos)
* Hoje estou usando o Railway para n8n, evolutionAPI, postgres e redis. Mais para frente podemos migrar para outro provedor se necessário ou para um vm simples rodando tudo via docker compose.

---

## Diretrizes de Produto (Muito Importante)

Ao sugerir código, fluxos ou arquitetura, o Copilot deve sempre considerar:

* O **Cetti AIO é o cérebro do sistema**
* Chatbots e automações são “interfaces” do Cetti AIO
* Tudo deve ser reutilizável entre clientes
* Tudo deve ser configurável por cliente (tenant)
* Nada deve exigir refatoração grande para evoluir

Se a sugestão:

* não ajuda a vender
* não ajuda a entregar valor rápido
* não ajuda a operar com poucos recursos

👉 **provavelmente não deve ser implementada agora**.

---

## Diretrizes Técnicas

* Priorizar simplicidade extrema
* Código claro e direto
* Poucas camadas
* Uso consistente de variáveis de ambiente
* Nada de credenciais hardcoded
* Preferir soluções síncronas simples quando possível
* Pensar sempre em custo operacional

Evitar explicitamente:

* Kubernetes
* Microsserviços
* Service Mesh
* Event Bus complexo
* Dependência pesada de vendor específico

---

## Padrões de Negócio

O sistema deve suportar logicamente:

* Plano Essencial (automação simples, IA mínima ou inexistente)
* Plano Inteligente (IA com Cetti AIO ativo)
* Plano Avançado (agentes, automações e integrações)

Mesmo que **nem tudo seja implementado agora**, a estrutura deve permitir isso **sem reescrever o sistema**.

---

## Linguagem e Estilo das Sugestões

O Copilot deve:

* Usar linguagem técnica clara
* Ser direto e pragmático
* Priorizar exemplos práticos
* Pensar como arquiteto de startup early-stage
* Evitar academicismo e explicações longas

---

## Mentalidade Esperada

Este não é um projeto acadêmico nem enterprise.

É um **produto real**, com:

* fundador solo
* recursos limitados
* foco em venda
* foco em entrega

Toda sugestão deve responder implicitamente à pergunta:

> **Isso ajuda a Cetti a vender, entregar e evoluir sem dor?**

---

## Objetivo Final

Construir um **SaaS simples, funcional e vendável**, baseado no **Cetti AIO**, que gere valor real para PMEs e permita crescimento gradual e sustentável da **Cetti Agentics**.
