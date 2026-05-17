$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ProjectRoot
$LocalConfigPath = Join-Path $ProjectRoot "deploy.local.ps1"
$WarPath = Join-Path $BaseDir "ProjectOS.war"
$RemoteWar = "/tmp/ROOT.war"
$RemoteBackupBase = "/home/ubuntu/projectos-backups"

if (-not (Test-Path -LiteralPath $LocalConfigPath)) {
    throw ("Missing deploy config / 배포 설정 파일을 찾을 수 없습니다: {0}. Copy deploy.example.ps1 to deploy.local.ps1 and set KeyPath/Server / deploy.example.ps1을 deploy.local.ps1로 복사한 뒤 KeyPath와 Server를 설정해주세요." -f $LocalConfigPath)
}

. $LocalConfigPath

if (-not $KeyPath) {
    throw "Please set KeyPath in deploy.local.ps1 / deploy.local.ps1에 KeyPath를 설정해주세요."
}

if (-not $Server) {
    throw "Please set Server in deploy.local.ps1 / deploy.local.ps1에 Server를 설정해주세요. Example / 예시: ubuntu@15.164.171.73"
}

function Write-Step($Message) {
    Write-Host ""
    Write-Host ("==> {0}" -f $Message) -ForegroundColor Cyan
}

if (-not (Test-Path -LiteralPath $WarPath)) {
    throw ("WAR file not found / WAR 파일을 찾을 수 없습니다: {0}. Export ProjectOS.war from Eclipse first / Eclipse에서 ProjectOS.war를 먼저 생성해주세요." -f $WarPath)
}

if (-not (Test-Path -LiteralPath $KeyPath)) {
    throw ("SSH key not found / SSH 키 파일을 찾을 수 없습니다: {0}" -f $KeyPath)
}

Write-Step "Check WAR file / WAR 파일 확인"
Get-Item -LiteralPath $WarPath | Select-Object FullName, Length, LastWriteTime | Format-List

Write-Step "Upload WAR to server / 서버에 WAR 업로드"
scp -i $KeyPath $WarPath "${Server}:${RemoteWar}"

Write-Step "Back up current deployment / 기존 배포본 백업"
$BackupStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$RemoteBackupDir = "$RemoteBackupBase/deploy-$BackupStamp"

$RollbackScript = @'
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
sudo systemctl stop tomcat
sudo rm -rf /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/ROOT.war
if [ -f ROOT.war ]; then sudo cp -a ROOT.war /opt/tomcat/webapps/ROOT.war; fi
if [ -d ROOT ]; then sudo cp -a ROOT /opt/tomcat/webapps/ROOT; fi
sudo chown -R tomcat:tomcat /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/ROOT.war 2>/dev/null || true
sudo systemctl start tomcat
sudo systemctl status tomcat --no-pager
'@

$RollbackScript = $RollbackScript -replace "`r`n", "`n"
$EncodedRollback = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($RollbackScript))

$BackupCommands = @(
    "sudo mkdir -p '$RemoteBackupDir'",
    "if sudo test -f /opt/tomcat/webapps/ROOT.war; then sudo cp -a /opt/tomcat/webapps/ROOT.war '$RemoteBackupDir/ROOT.war'; fi",
    "if sudo test -d /opt/tomcat/webapps/ROOT; then sudo cp -a /opt/tomcat/webapps/ROOT '$RemoteBackupDir/ROOT'; fi",
    "echo '$EncodedRollback' | base64 -d | sudo tee '$RemoteBackupDir/rollback.sh' >/dev/null",
    "sudo chmod +x '$RemoteBackupDir/rollback.sh'",
    "sudo ls -la '$RemoteBackupDir'"
)

ssh -i $KeyPath $Server ($BackupCommands -join " && ")
Write-Host ("Backup path / 백업 경로: {0}" -f $RemoteBackupDir) -ForegroundColor Yellow

Write-Step "Deploy to Tomcat / Tomcat에 배포"
$RemoteCommands = @(
    "sudo systemctl stop tomcat",
    "sudo rm -rf /opt/tomcat/webapps/ROOT",
    "sudo rm -f /opt/tomcat/webapps/ROOT.war",
    "sudo mv /tmp/ROOT.war /opt/tomcat/webapps/ROOT.war",
    "sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war",
    "sudo test -f /opt/tomcat/webapps/ROOT.war",
    "sudo systemctl start tomcat",
    "sleep 6",
    "sudo ls -la /opt/tomcat/webapps | grep ROOT",
    "curl -I -s http://127.0.0.1:8080/login.jsp",
    "sudo tail -n 40 /opt/tomcat/logs/catalina.out"
)

ssh -i $KeyPath $Server ($RemoteCommands -join " && ")

Write-Step "Deployment complete / 배포 완료"
Write-Host "Check in browser / 브라우저에서 확인: https://projectos-team.duckdns.org/" -ForegroundColor Green
Write-Host ("Rollback if needed / 필요 시 롤백: sudo {0}/rollback.sh" -f $RemoteBackupDir) -ForegroundColor Yellow
