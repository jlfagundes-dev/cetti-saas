@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Iniciando ambiente Cetti SaaS
echo ========================================

echo.
echo [1/5] Iniciando Docker Desktop...

REM Tenta iniciar o Docker Desktop
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Aguardando Docker iniciar...

:wait_docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
echo Docker ainda nao esta pronto... aguardando 5 segundos
timeout /t 5 > nul
goto wait_docker
)

echo Docker esta pronto!

echo.
echo [2/5] Entrando na pasta do projeto...
cd /d C:\projects_cetti\cetti-saas

if %errorlevel% neq 0 (
echo ERRO: Nao foi possivel acessar a pasta.
pause
exit /b %errorlevel%
)

echo.
echo [3/5] Subindo containers com docker-compose...
docker-compose up -d

if %errorlevel% neq 0 (
echo ERRO: Falha ao subir os containers.
pause
exit /b %errorlevel%
)

echo.
echo [4/5] Aguardando containers ficarem prontos...

:wait_containers
set "containers_up=0"

for /f %%i in ('docker ps --format "{{.Status}}" ^| findstr /i "Up"') do (
set "containers_up=1"
)

if "!containers_up!"=="0" (
echo Containers ainda nao estao prontos... aguardando 5 segundos
timeout /t 5 > nul
goto wait_containers
)

echo Containers em execucao!

echo.
echo [5/5] Iniciando tunnel do Cloudflared...
cloudflared tunnel run cetti-tunnel

echo.
echo Processo finalizado.
pause
