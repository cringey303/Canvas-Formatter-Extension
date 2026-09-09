$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot
$targets = if ($args.Count -eq 0) { @('chrome', 'firefox') } else { $args }

$versions = Get-ChildItem 'manifests/*.json' |
    ForEach-Object { (Get-Content $_.FullName -Raw | ConvertFrom-Json).version } |
    Sort-Object -Unique
if ($versions.Count -ne 1) {
    Write-Warning 'Manifest versions differ across manifests/*.json'
}

foreach ($target in $targets) {
    $manifest = Join-Path 'manifests' "$target.json"
    if (-not (Test-Path $manifest -PathType Leaf)) {
        throw "No manifest for '$target' ($manifest)"
    }

    $out = Join-Path 'dist' $target
    if (Test-Path $out) {
        Remove-Item $out -Recurse -Force
    }
    New-Item $out -ItemType Directory -Force | Out-Null
    Copy-Item 'src/*' $out -Recurse -Force
    Copy-Item $manifest (Join-Path $out 'manifest.json') -Force
    Write-Output "built $out"
}
