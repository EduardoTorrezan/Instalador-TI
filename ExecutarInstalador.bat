@echo off
setlocal

title Instalador de Pos-Formatacao TI

:: ============================================================
:: VERIFICAR SE ESTA COMO ADMINISTRADOR
:: ============================================================

net session >nul 2>&1

if %errorlevel% neq 0 (

    echo.
    echo ============================================
    echo   SOLICITANDO PRIVILEGIOS DE ADMINISTRADOR
    echo ============================================
    echo.
    echo O Windows ira solicitar uma conta
    echo administrativa para continuar.
    echo.

    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"

    exit /b
)

:: ============================================================
:: EXECUTAR O POWERSHELL
:: ============================================================

echo.
echo ============================================
echo   INSTALADOR DE POS-FORMATACAO TI
echo ============================================
echo.
echo Iniciando...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Instalar-Programas.ps1"

echo.
echo ============================================
echo   PROCESSO FINALIZADO
echo ============================================
echo.

pause