#!/bin/sh
set -eu

# Usa a senha via variavel para os comandos psql/createdb.
export PGPASSWORD="${POSTGRES_PASSWORD}"

# Mantem compatibilidade com nomes antigos de variavel.
EVOLUTION_DB_NAME="${EVOLUTION_DB_NAME:-${POSTGRES_DB_EVOLUTION:-evolution}}"
POSTGRES_DB_N8N="${POSTGRES_DB_N8N:-n8n}"

# Espera o Postgres principal ficar pronto antes de criar os bancos.
until pg_isready -h postgres -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; do
  echo "Aguardando o Postgres ficar pronto..."
  sleep 2
done

create_db_if_missing() {
  db_name="$1"

  if psql -h postgres -U "${POSTGRES_USER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${db_name}'" | grep -q 1; then
    echo "Banco '${db_name}' ja existe."
    return 0
  fi

  echo "Criando banco '${db_name}'..."
  createdb -h postgres -U "${POSTGRES_USER}" "${db_name}"
}

enable_vector_extension() {
  db_name="$1"
  echo "Garantindo extensao vector em '${db_name}'..."
  psql -h postgres -U "${POSTGRES_USER}" -d "${db_name}" -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS vector;"
}

# Bancos da stack: principal, n8n, chatwoot e evolution.
create_db_if_missing "${POSTGRES_DB}"
create_db_if_missing "${POSTGRES_DB_N8N}"
create_db_if_missing "${POSTGRES_DB_CHAT}"
create_db_if_missing "${EVOLUTION_DB_NAME}"

# Extensao vector disponivel para recursos de IA quando necessario.
enable_vector_extension "${POSTGRES_DB}"
enable_vector_extension "${POSTGRES_DB_N8N}"
enable_vector_extension "${POSTGRES_DB_CHAT}"
enable_vector_extension "${EVOLUTION_DB_NAME}"

echo "Bootstrap de bancos concluido com sucesso."
