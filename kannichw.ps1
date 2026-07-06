# Kannich Wrapper Script
# Commit this file with your project to enable portable CI builds.

$ErrorActionPreference = "Stop"

# Configuration
$KannichImage = if ($env:KANNICH_IMAGE) { $env:KANNICH_IMAGE } else { "derkork/kannich:latest" }

# Docker proxy support - prefix image if configured
if ($env:KANNICH_DOCKER_PROXY_PREFIX) {
    # Only prefix if the image doesn't already start with the prefix
    if (-not $KannichImage.StartsWith($env:KANNICH_DOCKER_PROXY_PREFIX)) {
        $KannichImage = $env:KANNICH_DOCKER_PROXY_PREFIX + $KannichImage
    }
}

# Determine project directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = if ($env:KANNICH_PROJECT_DIR) { $env:KANNICH_PROJECT_DIR } else { $ScriptDir }

# KANNICH_PROJECT_DIR inside the container is always /workspace (set via the env file below).

# Check for Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Error: Docker not found. Please install Docker."
    exit 1
}

try { docker info | Out-Null } catch {}
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Docker daemon not running. Please start Docker."
    exit 1
}

# Docker proxy login if configured
if ($env:KANNICH_DOCKER_PROXY_URL) {
    if ($env:KANNICH_DOCKER_PROXY_USERNAME -and $env:KANNICH_DOCKER_PROXY_PASSWORD) {
        Write-Host "Logging in to Docker proxy: $env:KANNICH_DOCKER_PROXY_URL"
        $env:KANNICH_DOCKER_PROXY_PASSWORD | docker login $env:KANNICH_DOCKER_PROXY_URL -u $env:KANNICH_DOCKER_PROXY_USERNAME --password-stdin
    }
}

if ($env:KANNICH_CACHE_DIR) {
    # user may want to supply their own cache dir
    if (-not (Test-Path $env:KANNICH_CACHE_DIR -PathType Container)) {
        Write-Host "Creating cache directory: $env:KANNICH_CACHE_DIR"
        try {
            New-Item -ItemType Directory -Path $env:KANNICH_CACHE_DIR -Force | Out-Null
        } catch {
            Write-Error "Error: Failed to create cache directory: $env:KANNICH_CACHE_DIR"
            exit 1
        }
    }
    $CacheMount = "$env:KANNICH_CACHE_DIR`:/kannich/cache"
} else {
    # the default cache is a docker volume
    try { docker volume inspect kannich-cache | Out-Null } catch {}
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Creating docker volume: kannich-cache"
        docker volume create kannich-cache | Out-Null
    }
    $CacheMount = "kannich-cache:/kannich/cache"
}

# KANNICH_CACHE_DIR inside the container is always /kannich/cache (set via the env file below).

# Detect --dev-mode / -d flag
$DevMode = $false
foreach ($arg in $args) {
    if ($arg -eq "--dev-mode" -or $arg -eq "-d") {
        $DevMode = $true
        break
    }
}

# Dev mode: mount host .m2/repository
$DevModeMount = @()
if ($DevMode) {
    $HostM2Repo = Join-Path $env:USERPROFILE ".m2\repository"
    if (-not (Test-Path $HostM2Repo -PathType Container)) {
        Write-Host "No local maven repository exists. Creating an empty one."
        try {
            New-Item -ItemType Directory -Path $HostM2Repo -Force | Out-Null
        } catch {
            Write-Error "Error: Failed to create local maven repository: $HostM2Repo"
            exit 1
        }
    }
    $DevModeMount = @("-v", "${HostM2Repo}:/kannich/dev-repo")
}

# Pull image if not present
if (-not (docker images -q $KannichImage)) {
    Write-Host "Pulling Kannich builder image..."
    docker pull $KannichImage
}

# Container name for cleanup
$ContainerName = "kannich-$PID"

# Check if running in a terminal for colored output
$TtyFlag = @()
if ([Environment]::UserInteractive -and -not [Console]::IsOutputRedirected) {
    $TtyFlag = @("-t")
}

# If KANNICH_BOOTSTRAP_SETTINGS_XML is not set, try to read $HOME/.m2/settings.xml into this variable
# if it exists.
if (-not $env:KANNICH_BOOTSTRAP_SETTINGS_XML) {
    $SettingsXmlPath = Join-Path $env:USERPROFILE ".m2\settings.xml"
    if (Test-Path $SettingsXmlPath -PathType Leaf) {
        $env:KANNICH_BOOTSTRAP_SETTINGS_XML = Get-Content $SettingsXmlPath -Raw
    }
}

# Put all environment variables into a file named ".kannich_current_env"
# Use null bytes as delimiters to handle multiline values unambiguously.
# Override container-specific paths so the container sees /workspace and /kannich/cache
# regardless of host-side values, without modifying the current session's env vars.
$EnvFile = Join-Path $ProjectDir ".kannich_current_env"
$ContainerEnvOverrides = @{ "KANNICH_PROJECT_DIR" = "/workspace"; "KANNICH_CACHE_DIR" = "/kannich/cache" }
$EnvContent = ([Environment]::GetEnvironmentVariables().GetEnumerator() | ForEach-Object {
    $val = if ($ContainerEnvOverrides.ContainsKey($_.Key)) { $ContainerEnvOverrides[$_.Key] } else { $_.Value }
    $_.Key + "=" + $val + [char]0
}) -join ''
[IO.File]::WriteAllText($EnvFile, $EnvContent)

# Cleanup function
$Cleanup = {
    try {
        $ErrorActionPreference = "SilentlyContinue"
        & docker stop $ContainerName 2>&1 | Out-Null
    } catch { }
}

# Handle Ctrl+C
try {
    # Run Kannich inside Docker
    $ExtraDockerOpts = @()
    if ($env:KANNICH_DOCKER_OPTS) {
        $ExtraDockerOpts = $env:KANNICH_DOCKER_OPTS -split '\s+'
    }

    $dockerArgs = @(
        "run", "--rm",
        "--init",
        "--name", $ContainerName,
        "--privileged"
    ) + $TtyFlag + @(
        "-v", "${ProjectDir}:/workspace",
        "-v", $CacheMount
    ) + $DevModeMount + $ExtraDockerOpts + @(
        "-w", "/workspace",
        $KannichImage
    ) + $args

    docker @dockerArgs
    exit $LASTEXITCODE
} finally {
    & $Cleanup
}
