<#
.SYNOPSIS
    Crea un proyecto nuevo de LudumNostrum a partir de IA/template.

.DESCRIPTION
    Copia la plantilla a ..\<Name> (hermano de IA), sustituye los marcadores
    {{PROJECT_NAME}}, {{DESCRIPTION}}, {{DATE}} y {{FRAMEWORK_VERSION}},
    guarda la versión del framework en .claude/framework-version,
    inicializa git en la rama main y hace el primer commit.

.EXAMPLE
    .\New-Project.ps1 -Name Proyecto002 -Description "Juego de cartas cooperativo"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_-]*$')]
    [string]$Name,

    [string]$Description = '_Pendiente de definir con el usuario._',

    [switch]$NoGit,
    [switch]$NoCommit
)

$ErrorActionPreference = 'Stop'

$iaRoot      = Split-Path -Parent $PSScriptRoot
$templateDir = Join-Path $iaRoot 'template'
$projectDir  = Join-Path (Split-Path -Parent $iaRoot) $Name

if (Test-Path $projectDir) {
    throw "Ya existe '$projectDir'. Elige otro nombre."
}

# Versión del framework: primera entrada '## [x.y.z]' del CHANGELOG
$changelog = Get-Content (Join-Path $iaRoot 'CHANGELOG.md') -Encoding UTF8
$version = ($changelog | Select-String '^## \[(\d+\.\d+\.\d+)\]' | Select-Object -First 1).Matches[0].Groups[1].Value

Write-Host "Creando $Name desde la plantilla v$version..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $projectDir | Out-Null
Copy-Item -Path (Join-Path $templateDir '*') -Destination $projectDir -Recurse -Force

# Sustitución de marcadores (UTF-8 sin BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$tokens = @{
    '{{PROJECT_NAME}}'      = $Name
    '{{DESCRIPTION}}'       = $Description
    '{{DATE}}'              = (Get-Date -Format 'yyyy-MM-dd')
    '{{FRAMEWORK_VERSION}}' = $version
}
Get-ChildItem -Path $projectDir -Recurse -File -Include *.md, *.json | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $new = $text
    foreach ($k in $tokens.Keys) { $new = $new.Replace($k, $tokens[$k]) }
    if ($new -ne $text) { [System.IO.File]::WriteAllText($_.FullName, $new, $utf8NoBom) }
}

[System.IO.File]::WriteAllText((Join-Path $projectDir '.claude\framework-version'), "$version`n", $utf8NoBom)

# Directorios vacíos que git debe conservar
New-Item -ItemType File -Path (Join-Path $projectDir '.ai\decisions\.gitkeep') -Force | Out-Null

if (-not $NoGit) {
    Push-Location $projectDir
    try {
        git init -b main | Out-Null
        if (-not $NoCommit) {
            git add -A
            git commit -m "chore: bootstrap $Name from LudumNostrum IA v$version" | Out-Null
        }
    } finally { Pop-Location }
}

Write-Host "Listo: $projectDir" -ForegroundColor Green
Write-Host "Siguiente: cd '$projectDir'; claude"
