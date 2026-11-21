@echo off
setlocal
cd /d "%~dp0"
where node.exe >nul 2>nul
if errorlevel 1 (
  echo Instala Node.js 22 con npm y Java 21. Despues vuelve a abrir este archivo.
  pause
  exit /b 1
)
node.exe "firebase\scripts\iniciar.cjs" %*
if errorlevel 1 pause
