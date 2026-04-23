@echo off
setlocal

echo ========================================
echo Encerrando ambiente Cetti SaaS
echo ========================================

echo.
echo [1/4] Encerrando tunnel do Cloudflared...

REM Mata processos do cloudflared relacionados ao tunnel
taskkill /f /im cloudflared.exe >nul 2>&1

if %errorlevel%==0 (
echo Tunnel encerrado com sucesso.
) else (
echo Nenhum processo do cloudflared encontrado.
)

echo.
echo [2/4] Entrando na pasta do projeto...
cd /d C:\projects_cetti\cetti-saas

if %errorlevel% neq 0 (
echo ERRO: Nao foi possivel acessar a pasta.
pause
exit /b %errorlevel%
)

echo.
echo [3/4] Derrubando containers (docker-compose down)...
docker-compose down

if %errorlevel% neq 0 (
echo ERRO ao derrubar containers.
pause
exit /b %errorlevel%
)

echo.
echo [4/4] Encerrando Docker Desktop...

REM Fecha Docker Desktop
taskkill /f /im "Docker Desktop.exe" >nul 2>&1
taskkill /f /im "com.docker.backend.exe" >nul 2>&1
taskkill /f /im "com.docker.service" >nul 2>&1

echo Docker Desktop encerrado.

echo.
echo Ambiente finalizado com sucesso.
pause
