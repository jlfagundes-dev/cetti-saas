# Arquitetura Técnica Mínima do Cetti AIO v1

- Diagrama Lógico
    
    ```mermaid
    flowchart TD
        %% CANAIS
        U[Cliente Final] -->|Mensagem| WA[WhatsApp]
    
        %% ENTRADA
        WA --> EVO[Evolution API]
        EVO --> WH[Webhook n8n]
    
        %% PRÉ-PROCESSAMENTO
        WH --> F1{Mensagem válida?}
        F1 -->|Não| IGN[Ignorar]
        F1 -->|Sim| F2{Tipo de mensagem}
    
        F2 -->|Texto| TXT[Extrair Texto]
        F2 -->|Áudio| AUD[Whisper / STT]
    
        TXT --> NORM[Normalizar Mensagem]
        AUD --> NORM
    
        %% CONTEXTO DO CLIENTE (TENANT)
        NORM --> CTX[Carregar Contexto do Cliente]
        CTX --> PG[(PostgreSQL)]
    
        %% CETTI AIO
        CTX --> AIO[Cetti AIO Engine]
        AIO --> PROMPT[Prompt Mestre + Variáveis]
        AIO --> MEM[Memória Conversacional]
        MEM --> REDIS[(Redis)]
    
        %% DECISÃO
        AIO --> DEC{Decisão}
        DEC -->|Responder| RESP[Gerar Resposta IA]
        DEC -->|Escalar| HUMAN[Encaminhar para Humano]
        DEC -->|Ação| ACT[Disparar Automação]
    
        %% SAÍDA
        RESP --> EVO
        HUMAN --> CHAT[Chatwoot]
        ACT --> N8N[n8n Subflow]
    
        EVO -->|Resposta| WA
    
    ```
    
- Contexto
- Requisitos
- Infra
- Segurança
- Operação e Governança
- Casos de Uso
- Diagramas Complementares