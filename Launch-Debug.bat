@echo off
title Pokemon Essentials - MKXP-Z Debug Console
color 0A
cd /d "%~dp0"

echo.
echo ================================================================================
echo                   MKXP-Z Enhanced Debug Console
echo ================================================================================
echo.
echo Game: Pokemon Essentials v21.1
echo Engine: MKXP-Z 2.4.2/4e8ce16
echo.
echo ================================================================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0Launch-Debug.ps1"

pause
