param(
    [switch]$Update
)

$ErrorActionPreference = 'Stop'

foreach ($command in @('php', 'composer')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command was not found. Install PHP 8.2 or newer and Composer, then ensure both are on PATH."
    }
}

Push-Location $PSScriptRoot
try {
    if (-not (Test-Path .env)) {
        Copy-Item .env.example .env
        Write-Host 'Created .env from .env.example.'
    }

    $envContents = Get-Content .env -Raw
    $appKey = [regex]::Match($envContents, '(?m)^[ \t]*APP_KEY[ \t]*=[ \t]*(.*?)[ \t]*\r?$')
    if (-not $appKey.Success) {
        throw 'APP_KEY is missing from .env. Add an empty APP_KEY= line and rerun the script.'
    }

    $composerCommand = if ($Update) { 'update' } else { 'install' }
    & composer $composerCommand --no-interaction --prefer-dist
    if ($LASTEXITCODE -ne 0) {
        throw "Composer $composerCommand failed with exit code $LASTEXITCODE."
    }

    $keyValue = $appKey.Groups[1].Value.Trim().Trim([char[]]@('"', "'"))
    if ([string]::IsNullOrWhiteSpace($keyValue)) {
        & php artisan key:generate --no-interaction
        if ($LASTEXITCODE -ne 0) {
            throw "Application key generation failed with exit code $LASTEXITCODE."
        }
    }

    Write-Host 'Setup complete. Configure the database in app/.env if needed, then run php artisan serve from the app directory.'
}
finally {
    Pop-Location
}