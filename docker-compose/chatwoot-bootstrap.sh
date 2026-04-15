#!/bin/sh
set -eu

MARKER_FILE="/app/storage/.chatwoot_bootstrapped"
# Permite trocar o caminho do marcador por variavel de ambiente.
MARKER_FILE="${CHATWOOT_BOOTSTRAP_MARKER:-$MARKER_FILE}"

# Se ja marcou bootstrap antes, nao roda de novo.
if [ -f "$MARKER_FILE" ]; then
  exit 0
fi

echo "Verificando primeiro boot do Chatwoot..."

# Executa logica Ruby dentro do contexto do Chatwoot.
bundle exec rails runner '
marker = ENV.fetch("CHATWOOT_BOOTSTRAP_MARKER", "/app/storage/.chatwoot_bootstrapped")

# So habilita onboarding inicial se nao houver conta nem usuario.
if Account.count.zero? && User.count.zero?
  Redis::Alfred.set(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING, true)
  puts "Onboarding inicial habilitado"
else
  puts "Instancia ja possui dados; onboarding nao sera forcado"
end

# Grava marcador para evitar executar esse bootstrap em todo restart.
File.write(marker, Time.current.to_s)
'