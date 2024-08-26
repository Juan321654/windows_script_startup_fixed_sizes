@echo off
start "" "C:\Program Files\DB Browser for SQLite\DB Browser for SQLite.exe"
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe"
timeout /t 10 /nobreak >nul
PowerShell -ExecutionPolicy Bypass -Command "& {Start-Sleep -Seconds 5; .\resize_windows.ps1}"
