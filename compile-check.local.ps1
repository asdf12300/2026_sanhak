$ErrorActionPreference = "Stop"

chcp 65001 > $null
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$externalLibDir = Join-Path $env:USERPROFILE ".projectos-java-lib\sanhak"
$tomcatServletApi = Join-Path $env:USERPROFILE "Downloads\apache-tomcat-9.0.116-windows-x64\apache-tomcat-9.0.116\lib\servlet-api.jar"
$webInfLibDir = Join-Path $projectRoot "src\main\WebContent\WEB-INF\lib"
$buildDir = Join-Path $projectRoot "build\codex-classes"

New-Item -ItemType Directory -Force -Path $externalLibDir | Out-Null
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

if (Test-Path $tomcatServletApi) {
    Copy-Item -Path $tomcatServletApi -Destination (Join-Path $externalLibDir "servlet-api.jar") -Force
}

Copy-Item -Path (Join-Path $webInfLibDir "*.jar") -Destination $externalLibDir -Force

$classpath = (Get-ChildItem -Path $externalLibDir -Filter "*.jar" | ForEach-Object { $_.FullName }) -join ";"
$sources = Get-ChildItem -Path (Join-Path $projectRoot "src\main\java") -Recurse -Filter "*.java" |
    Where-Object { $_.Name -notin @("ChatWebSocket.java", "HttpSessionConfigurator.java") } |
    ForEach-Object { $_.FullName }

javac -encoding UTF-8 -cp $classpath -d $buildDir $sources
