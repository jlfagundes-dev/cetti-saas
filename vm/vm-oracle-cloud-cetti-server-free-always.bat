@echo off
setlocal

set "HOST=141.148.19.92"
set "USER=ubuntu"

rem Caminho absoluto principal da sua chave
set "KEY_FILE=C:\Users\jlfag\OneDrive\Plano de Negocio - Cetti Agentics AI\estrutura oracle cloud\key network vm gratis\ssh-key-2026-03-28.key"

rem Fallbacks uteis caso a chave seja movida
if not exist "%KEY_FILE%" set "KEY_FILE=%USERPROFILE%\.ssh\ssh-key-2026-03-28.key"
if not exist "%KEY_FILE%" set "KEY_FILE=%~dp0ssh-key-2026-03-28.key"

if not exist "%KEY_FILE%" (
	echo [ERRO] Nao foi possivel encontrar a chave SSH.
	echo Procurado em:
	echo - C:\Users\jlfag\OneDrive\Plano de Negocio - Cetti Agentics AI\estrutura oracle cloud\key network vm gratis\ssh-key-2026-03-28.key
	echo - %USERPROFILE%\.ssh\ssh-key-2026-03-28.key
	echo - %~dp0ssh-key-2026-03-28.key
	echo.
	pause
	exit /b 1
)

echo Conectando em %USER%@%HOST% com a chave:
echo %KEY_FILE%
echo.

ssh -i "%KEY_FILE%" %USER%@%HOST%

echo.
echo Sessao encerrada. Pressione qualquer tecla para fechar.
pause >nul