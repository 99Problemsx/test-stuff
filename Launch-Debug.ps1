# MKXP-Z Enhanced Debug Console
$gamePath = "C:\Users\Marcel Weidenauer\Documents\GitHub\Backup_Clean_2025-10-03_23-49"
$gameExe = Join-Path $gamePath "Game.exe"

$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "           MKXP-Z Enhanced Debug Console" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Game: " -NoNewline -ForegroundColor Yellow
Write-Host "Pokemon Essentials v21.1" -ForegroundColor White
Write-Host "Engine: " -NoNewline -ForegroundColor Yellow
Write-Host "MKXP-Z 2.4.2/4e8ce16" -ForegroundColor White
Write-Host "Path: " -NoNewline -ForegroundColor Yellow
Write-Host $gamePath -ForegroundColor Gray
Write-Host ""
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

Write-Host "[" -NoNewline -ForegroundColor DarkGray
Write-Host (Get-Date -Format 'HH:mm:ss') -NoNewline -ForegroundColor Gray
Write-Host "] " -NoNewline -ForegroundColor DarkGray
Write-Host "Starting game..." -ForegroundColor Green
Write-Host ""

$process = Start-Process -FilePath $gameExe -WorkingDirectory $gamePath -PassThru

Write-Host "[" -NoNewline -ForegroundColor DarkGray
Write-Host (Get-Date -Format 'HH:mm:ss') -NoNewline -ForegroundColor Gray
Write-Host "] " -NoNewline -ForegroundColor DarkGray
Write-Host "Game process started (PID: $($process.Id))" -ForegroundColor Cyan
Write-Host ""
Write-Host "Debug Info:" -ForegroundColor Yellow
Write-Host "  - Press F2 in game to toggle FPS display" -ForegroundColor Gray
Write-Host "  - Press F12 to soft reset" -ForegroundColor Gray
Write-Host "  - Press Alt+Enter for fullscreen" -ForegroundColor Gray
Write-Host ""
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

try {
    $process.WaitForExit()
    
    Write-Host ""
    Write-Host "[" -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format 'HH:mm:ss') -NoNewline -ForegroundColor Gray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Game closed normally" -ForegroundColor Green
    } else {
        Write-Host "Game closed with exit code: $($process.ExitCode)" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "[" -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format 'HH:mm:ss') -NoNewline -ForegroundColor Gray
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press Enter to close..." -ForegroundColor DarkGray
Read-Host
