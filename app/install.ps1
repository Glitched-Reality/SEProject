param(
    [Parameter(Position = 0)]
    [ValidateSet('install', 'update', 'start', 'stop', 'status')]
    [string]$Action = 'install',
    [switch]$Update
)

$ErrorActionPreference = 'Stop'

if ($Update) {
    if ($Action -ne 'install') {
        throw '-Update cannot be combined with another action.'
    }
    $Action = 'update'
}

Push-Location $PSScriptRoot
try {
    $pidFile = Join-Path $PSScriptRoot 'storage/logs/dev-server-windows.json'
    $server = $null
    if (Test-Path $pidFile) {
        try {
            $savedServer = Get-Content $pidFile -Raw | ConvertFrom-Json
            $process = Get-Process -Id $savedServer.Id -ErrorAction Stop
            if ($process.ProcessName -eq 'php' -and $process.StartTime.ToUniversalTime().Ticks -eq [long]$savedServer.StartTicks) {
                $server = $process
            }
        }
        catch {
            $server = $null
        }
    }

    if ($Action -eq 'status') {
        if ($server) {
            Write-Host "Development server is running at http://127.0.0.1:8000 (PID $($server.Id))."
        }
        else {
            Write-Host 'Development server is not running.'
            exit 1
        }
        return
    }

    if ($Action -eq 'stop') {
        if ($server) {
            Stop-Process -Id $server.Id -ErrorAction Stop
            Remove-Item $pidFile -Force
            Write-Host 'Development server stopped.'
        }
        else {
            Write-Host 'No managed development server is running.'
        }
        return
    }

    if ($Action -eq 'start') {
        if ($server) {
            Write-Host "Development server is already running at http://127.0.0.1:8000 (PID $($server.Id))."
            return
        }
        $php = Get-Command php -CommandType Application -ErrorAction SilentlyContinue
        if (-not $php) {
            throw 'php was not found. Install PHP 8.2 or newer and ensure it is on PATH.'
        }
        if (-not (Test-Path 'vendor/autoload.php') -or -not (Test-Path '.env')) {
            throw 'Install the application first with ./app/install.ps1 install.'
        }
        New-Item -ItemType Directory -Force 'storage/logs' | Out-Null
        $publicPath = Join-Path $PSScriptRoot 'public'
        $logPath = Join-Path $PSScriptRoot 'storage/logs/dev-server-windows.log'
        $errorPath = Join-Path $PSScriptRoot 'storage/logs/dev-server-windows-error.log'
        $server = Start-Process -FilePath $php.Source -ArgumentList @('-S', '127.0.0.1:8000', '-t', ('"{0}"' -f $publicPath)) -WorkingDirectory $PSScriptRoot -RedirectStandardOutput $logPath -RedirectStandardError $errorPath -PassThru
        @{ Id = $server.Id; StartTicks = $server.StartTime.ToUniversalTime().Ticks } | ConvertTo-Json | Set-Content $pidFile
        Write-Host "Development server launched at http://127.0.0.1:8000. Check $errorPath if it fails to start."
        return
    }

    foreach ($command in @('php', 'composer')) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            throw "$command was not found. Install PHP 8.2 or newer and Composer, then ensure both are on PATH."
        }
    }

    if (-not (Test-Path .env)) {
        Copy-Item .env.example .env
        Write-Host 'Created .env from .env.example.'
    }

    $envContents = Get-Content .env -Raw
    $appKey = [regex]::Match($envContents, '(?m)^[ \t]*APP_KEY[ \t]*=[ \t]*(.*?)[ \t]*\r?$')
    if (-not $appKey.Success) {
        throw 'APP_KEY is missing from .env. Add an empty APP_KEY= line and rerun the script.'
    }

    $composerCommand = $Action
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

    Write-Host 'Setup complete. Configure the database in app/.env if needed, then run ./app/install.ps1 start.'
}
finally {
    Pop-Location
}