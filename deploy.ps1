$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ProjectRoot
$LocalConfigPath = Join-Path $ProjectRoot "deploy.local.ps1"
$WarPath = Join-Path $BaseDir "ProjectOS.war"
$RemoteWar = "/tmp/ROOT.war"

if (-not (Test-Path -LiteralPath $LocalConfigPath)) {
    throw "배포 설정 파일을 찾을 수 없습니다: $LocalConfigPath`ndeploy.example.ps1을 deploy.local.ps1로 복사한 뒤 SSH 키 경로와 서버 주소를 설정해주세요."
}

. $LocalConfigPath

if (-not $KeyPath) {
    throw "deploy.local.ps1에 KeyPath를 설정해주세요."
}

if (-not $Server) {
    throw "deploy.local.ps1에 Server를 설정해주세요. 예: ubuntu@52.78.13.192"
}

function Write-Step($Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

if (-not (Test-Path -LiteralPath $WarPath)) {
    throw "WAR 파일을 찾을 수 없습니다: $WarPath`nEclipse에서 ProjectOS.war를 먼저 Export 해주세요."
}

if (-not (Test-Path -LiteralPath $KeyPath)) {
    throw "SSH 키 파일을 찾을 수 없습니다: $KeyPath"
}

Write-Step "WAR 파일 확인"
Get-Item -LiteralPath $WarPath | Select-Object FullName, Length, LastWriteTime | Format-List

Write-Step "서버로 WAR 업로드"
scp -i $KeyPath $WarPath "${Server}:${RemoteWar}"

Write-Step "Tomcat 재배포"
$RemoteCommands = @(
    "sudo systemctl stop tomcat",
    "sudo rm -rf /opt/tomcat/webapps/ROOT",
    "sudo rm -f /opt/tomcat/webapps/ROOT.war",
    "sudo mv /tmp/ROOT.war /opt/tomcat/webapps/ROOT.war",
    "sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war",
    "sudo test -f /opt/tomcat/webapps/ROOT.war",
    "sudo systemctl start tomcat",
    "sleep 4",
    "sudo ls -la /opt/tomcat/webapps | grep ROOT",
    "curl -I -s http://127.0.0.1:8080/login.jsp",
    "sudo tail -n 40 /opt/tomcat/logs/catalina.out"
)

ssh -i $KeyPath $Server ($RemoteCommands -join " && ")

Write-Step "배포 완료"
Write-Host "브라우저에서 확인: https://projectos-team.duckdns.org/" -ForegroundColor Green
