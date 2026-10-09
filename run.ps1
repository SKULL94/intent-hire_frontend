# Launch the Flutter app with the dart-defines it needs, read from .env.
#
# Usage:
#   .\run.ps1                       # flutter run -d chrome
#   .\run.ps1 -Device windows       # desktop
#   .\run.ps1 -WebPort 9000         # web dev server port (default 8787, pinned
#                                   # so the browser keeps your login session)
#   .\run.ps1 -Device emulator-5554 # Android emulator (see note on API_BASE_URL)
#   .\run.ps1 -Release              # release build
#   .\run.ps1 -Build                # `flutter build` instead of `run`
#   .\run.ps1 -List                 # show available devices and exit
#   .\run.ps1 -DryRun               # print the flutter command, run nothing
#   .\run.ps1 -- --verbose          # anything after `--` goes to flutter verbatim
#
# Why this script exists: lib/core/constants/app_constants.dart reads config via
# String.fromEnvironment, which is resolved at COMPILE time. Flutter does not
# read .env on its own (no flutter_dotenv in pubspec.yaml), so a plain
# `flutter run` leaves SUPABASE_URL empty, initSupabase() throws a StateError
# before runApp(), and you get a blank white page with the error only in the
# console.
#
# Kept deliberately ASCII-only. This file has no BOM, so PowerShell 5.1 decodes
# it as cp1252; a UTF-8 em dash would arrive as bytes ending in 0x94, which
# cp1252 maps to a smart closing quote that the parser treats as a string
# delimiter. One stray dash in a string and the whole script fails to parse.

# PositionalBinding=$false matters: without it every named parameter is also
# implicitly positional, so `.\run.ps1 -Device windows -- --verbose` binds
# "--verbose" to the next free slot ($EnvFile) instead of letting it fall
# through to $FlutterArgs.
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$Device = 'chrome',
    [int]$WebPort = 8787,
    [switch]$Release,
    [switch]$Build,
    [switch]$List,
    [switch]$DryRun,
    [string]$EnvFile = '.env',
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location $root

function Say  { param($m) Write-Host "> $m" -ForegroundColor Cyan }
function Warn { param($m) Write-Host "! $m" -ForegroundColor Yellow }
function Ok   { param($m) Write-Host "+ $m" -ForegroundColor Green }
function Die  { param($m) Write-Host "x $m" -ForegroundColor Red; exit 1 }

# --- which keys reach the app ------------------------------------------------
# Deliberately a whitelist, not "everything in .env".
#
# Every dart-define is baked into the compiled output. On web that output is
# JavaScript the browser downloads, so anything passed here is readable by
# anyone who opens the page. Your .env also holds SUPABASE_SERVICE_KEY,
# DATABASE_URL, SUPABASE_JWT_SECRET, ANTHROPIC_API_KEY and GITHUB_TOKEN -
# backend-only secrets that must never ship in a client build. That is why
# `--dart-define-from-file=.env` is the wrong tool here: it would forward all
# of them. Add a key below only if the Dart code actually reads it.
$Required = @('SUPABASE_URL', 'SUPABASE_ANON_KEY')
$Optional = [ordered]@{ 'API_BASE_URL' = 'http://localhost:8000' }

# --- .env parsing ------------------------------------------------------------
function Read-DotEnv {
    param([string]$Path)

    $map = @{}
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }

        $split = $trimmed.IndexOf('=')
        if ($split -lt 1) { continue }

        $key = $trimmed.Substring(0, $split).Trim()
        # Tolerate `export FOO=bar`, which some .env files carry.
        if ($key -like 'export *') { $key = $key.Substring(7).Trim() }

        $value = $trimmed.Substring($split + 1).Trim()
        if ($value.StartsWith('"') -or $value.StartsWith("'")) {
            # Quoted. Find the closing quote and take what is between them: a
            # '#' inside the quotes is data, and anything after the closing
            # quote is a comment. Testing EndsWith instead would miss the
            # quotes entirely on `FOO="bar"  # note`, whose last char is 'e'.
            $quote = $value[0]
            $close = $value.IndexOf($quote, 1)
            if ($close -gt 0) {
                $value = $value.Substring(1, $close - 1)
            } else {
                # Unbalanced opening quote: drop it, keep the rest literally.
                $value = $value.Substring(1).Trim()
            }
        } else {
            # Unquoted: ' # ...' is a trailing comment (standard dotenv behaviour).
            $value = ($value -replace '\s+#.*$', '').Trim()
        }

        $map[$key] = $value
    }
    return $map
}

# Show enough to confirm the right value loaded, not enough to leak it.
function Format-Masked {
    param([string]$Value)
    if ($Value.Length -le 24) { return $Value }
    return '{0}... ({1} chars)' -f $Value.Substring(0, 18), $Value.Length
}

# --- preflight ---------------------------------------------------------------
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Die 'flutter is not on PATH. Expected something like C:\src\flutter\bin.'
}

if ($List) {
    & flutter devices
    exit $LASTEXITCODE
}

# Join-Path would happily glue an absolute -EnvFile onto $root and produce a
# path that cannot exist, so only resolve relative ones against the repo.
if ([System.IO.Path]::IsPathRooted($EnvFile)) {
    $envPath = $EnvFile
} else {
    $envPath = Join-Path $root $EnvFile
}

if (-not (Test-Path -LiteralPath $envPath)) {
    Die "No env file at $envPath. Copy .env from the backend repo, or pass -EnvFile <path>."
}

$values = Read-DotEnv -Path $envPath

$missing = @()
foreach ($key in $Required) {
    if (-not $values.ContainsKey($key) -or $values[$key] -eq '') { $missing += $key }
}
if ($missing.Count -gt 0) {
    Die "$EnvFile is missing a value for: $($missing -join ', ')"
}

# --- assemble the defines ----------------------------------------------------
$defines = [ordered]@{}
foreach ($key in $Required) { $defines[$key] = $values[$key] }
foreach ($key in $Optional.Keys) {
    if ($values.ContainsKey($key) -and $values[$key] -ne '') {
        $defines[$key] = $values[$key]
    } else {
        $defines[$key] = $Optional[$key]
        Warn "$key not set in $EnvFile - defaulting to $($Optional[$key])"
    }
}

Say "Config from $EnvFile"
foreach ($key in $defines.Keys) {
    Write-Host ("    {0,-18} {1}" -f $key, (Format-Masked $defines[$key]))
}

# --- warn about the two mistakes that look like app bugs ---------------------
$apiBase = $defines['API_BASE_URL']
$webDevices = @('chrome', 'edge', 'web-server')
$hostDevices = $webDevices + @('windows', 'macos', 'linux')

$isLocalApi = $apiBase -match '^https?://(localhost|127\.0\.0\.1|\[::1\])'
$isHostDevice = $hostDevices -contains $Device

# A localhost backend is unreachable from an Android emulator or a real device:
# there, localhost is the device itself. The ngrok tunnel in the backend repo is
# what that case wants.
if ($isLocalApi -and -not $isHostDevice) {
    Warn "API_BASE_URL is $apiBase but you are targeting '$Device'."
    Warn 'On a device/emulator localhost is the device itself - point it at the ngrok URL.'
}

# If the API is local, say up front whether it is actually answering, so an
# empty matches list is not mistaken for "no matches".
if ($isLocalApi) {
    try {
        Invoke-RestMethod -Uri "$apiBase/health" -TimeoutSec 3 -ErrorAction Stop | Out-Null
        Ok "Backend is up at $apiBase"
    } catch {
        Warn "Backend is not answering at $apiBase/health."
        Warn 'Start it with:  ..\intent-hire-backend\restart.ps1 -Detach'
    }
}

if ($Release -and ($webDevices -contains $Device)) {
    Warn 'Release web build: these defines end up readable in the shipped JS.'
}

# --- run ---------------------------------------------------------------------
if ($Build) {
    # `flutter build` takes a target platform, not a device id.
    $target = $Device
    if ($webDevices -contains $Device) { $target = 'web' }
    $cmd = @('build', $target)
    $what = "build $target"
} else {
    $cmd = @('run', '-d', $Device)
    $what = "run -d $Device"
}

# Pin the web port. `flutter run -d chrome` otherwise picks a random one every
# launch, and the browser keys localStorage by origin (scheme+host+PORT). A new
# port is a new origin with empty storage, which is why the Supabase session is
# gone and you have to sign in again on every run. A fixed port keeps the
# session - and anything else stored locally - across restarts.
if (-not $Build -and ($webDevices -contains $Device)) {
    $cmd += "--web-port=$WebPort"
}

if ($Release) { $cmd += '--release' }
foreach ($key in $defines.Keys) { $cmd += "--dart-define=$key=$($defines[$key])" }
if ($FlutterArgs) { $cmd += $FlutterArgs }

Say "flutter $what  (+ $($defines.Count) dart-defines)"

if ($DryRun) {
    # Values masked: this is for eyeballing the shape of the command, and the
    # output tends to end up pasted into chats and issue threads.
    foreach ($arg in $cmd) {
        if ($arg -like '--dart-define=*') {
            $pair = $arg.Substring(14)
            $eq = $pair.IndexOf('=')
            Write-Host ("    --dart-define={0}={1}" -f $pair.Substring(0, $eq), (Format-Masked $pair.Substring($eq + 1)))
        } else {
            Write-Host "    $arg"
        }
    }
    Ok 'Dry run - nothing launched.'
    exit 0
}

if (-not $Build) { Say "Press 'r' to hot reload, 'q' to quit" }

& flutter @cmd
exit $LASTEXITCODE
