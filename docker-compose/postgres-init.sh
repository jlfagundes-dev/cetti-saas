#!/bin/sh
set -eu

# Usa a senha via variavel para os comandos psql/createdb.
export PGPASSWORD="${POSTGRES_PASSWORD}"

# Espera o Postgres principal ficar pronto antes de criar o DB do Chatwoot.
until pg_isready -h postgres -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; do
  echo "Aguardando o Postgres ficar pronto..."
  sleep 2
done

# Cria o banco do Chatwoot apenas se ele ainda nao existir.
if ! psql -h postgres -U "${POSTGRES_USER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB_CHAT}'" | grep -q 1; then
  createdb -h postgres -U "${POSTGRES_USER}" "${POSTGRES_DB_CHAT}"
fi

# Garante a extensao vector necessaria para recursos de IA.
psql -h postgres -U "${POSTGRES_USER}" -d "${POSTGRES_DB_CHAT}" -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS vector;"
