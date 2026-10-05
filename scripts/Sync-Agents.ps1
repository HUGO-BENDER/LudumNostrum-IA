<#
.SYNOPSIS
    Actualiza los agentes y skills de un proyecto existente desde IA/template.

.DESCRIPTION
    Sobrescribe .claude/agents y .claude/skills del proyecto con los de la plantilla
    y actualiza .claude/framework-version. NO toca .ai/, AGENTS.md, CLAUDE.md ni
    .claude/settings.json; si estos difieren de la plantilla, lo avisa para revisarlo a mano.
    Los agentes o skills que solo existan en el proyecto se conservan.

.EXAMPLE
    .\Sync-Agents.ps1 -Name Proyecto001
    .\Sync-Agents.ps1 -Name Proyecto001 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Name
)

$ErrorActionPreference = 'Stop'

$iaRoot      = Split-Path -Parent $PSScriptRoot
$templateDir = Join-Path $iaRoot 'template'
$projectDir  = Join-Path (Split-Path -Parent $iaRoot) $Name

if (-not (Test-Path (Join-Path $projectDir '.claude'))) {
    throw "'$projectDir' no parece un proyecto del framework (falta .claude/)."
}

$changelog = Get-Content (Join-Path $iaRoot 'CHANGELOG.md') -Encoding UTF8
$version = ($changelog | Select-String '^## \[(\d+\.\d+\.\d+)\]' | Select-Object -First 1).Matches[0].Groups[1].Value

$versionFile = Join-Path $projectDir '.claude\framework-version'
$current = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { 'desconocida' }
Write-Host "$Name : v$current -> v$version" -ForegroundColor Cyan

foreach ($sub in 'agents', 'skills') {
    $src = Join-Path $templateDir ".claude\$sub"
    $dst = Join-Path $projectDir ".claude\$sub"
    if ($PSCmdlet.ShouldProcess($dst, "Sincronizar $sub")) {
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
        Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
    }
}

if ($PSCmdlet.ShouldProcess($versionFile, "Escribir v$version")) {
    [System.IO.File]::WriteAllText($versionFile, "$version`n", (New-Object System.Text.UTF8Encoding($false)))
}

# Avisos de archivos que no se sincronizan automáticamente
foreach ($rel in '.claude\settings.json', '.gitignore') {
    $a = Join-Path $templateDir $rel
    $b = Join-Path $projectDir $rel
    if ((Test-Path $b) -and ((Get-FileHash $a).Hash -ne (Get-FileHash $b).Hash)) {
        Write-Warning "$rel difiere de la plantilla. Revísalo a mano si quieres los cambios nuevos."
    }
}

Write-Host "Sincronizado. Revisa con: git -C '$projectDir' diff" -ForegroundColor Green
