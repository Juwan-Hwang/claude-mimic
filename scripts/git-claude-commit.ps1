<#
.SYNOPSIS
  Creates an authentic Claude Code git commit with validated Co-Author trailers.
  Adheres strictly to Claude Code's Git Safety Protocol.

.EXAMPLE
  .\git-claude-commit.ps1 -Title "fix(evals): close child stdin" -Body "Redirects stdin to DEVNULL." -Model "opus55"
  .\git-claude-commit.ps1 -Title "feat(planets): add table" -Body "Adds stats." -SessionId "session_01U7vy96qF63BugmboFm2wPw"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Body,

    [Parameter(Mandatory=$false)]
    [ValidateSet("opus55", "opus55-1m", "sonnet55", "haiku55", "sonnet5", "sonnet46", "sonnet46-1m", "sonnet45", "sonnet45-1m", "sonnet4", "sonnet4-1m", "sonnet37", "sonnet35", "fable5", "fable51", "opus5", "opus5-1m", "opus48", "opus48-1m", "opus47", "opus47-1m", "opus46", "opus46-1m", "opus45", "opus45-1m", "opus41", "opus41-1m", "opus4", "opus4-1m", "haiku45", "haiku45-1m", "haiku35", "mythos5", "mythos51", "claudecode", "claude")]
    [string]$Model = "opus55",

    [Parameter(Mandatory=$false)]
    [string]$SessionId = "",

    [Parameter(Mandatory=$false)]
    [switch]$AutoSession,

    [Parameter(Mandatory=$false)]
    [switch]$Lowercase,

    [Parameter(Mandatory=$false)]
    [switch]$NoGpgSign,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Authentic 32-character Claude Bitcoin Base58 Session ID Generator
# Alphabet: 58 characters (1-9, A-Z excl I/O, a-z excl l)
function Get-ClaudeSessionId {
    $chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    $rand = -join ((1..22) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return "session_01$rand"
}

$modelNameMap = @{
    "opus55"      = "Claude Opus 5.5"
    "opus55-1m"   = "Claude Opus 5.5 (1M context)"
    "sonnet55"    = "Claude Sonnet 5.5"
    "haiku55"     = "Claude Haiku 5.5"
    "sonnet5"     = "Claude Sonnet 5"
    "sonnet46"    = "Claude Sonnet 4.6"
    "sonnet46-1m" = "Claude Sonnet 4.6 (1M context)"
    "sonnet45"    = "Claude Sonnet 4.5"
    "sonnet45-1m" = "Claude Sonnet 4.5 (1M context)"
    "sonnet4"     = "Claude Sonnet 4"
    "sonnet4-1m"  = "Claude Sonnet 4 (1M context)"
    "fable5"      = "Claude Fable 5"
    "fable51"     = "Claude Fable 5.1"
    "opus5"       = "Claude Opus 5"
    "opus5-1m"    = "Claude Opus 5 (1M context)"
    "opus48"      = "Claude Opus 4.8"
    "opus48-1m"   = "Claude Opus 4.8 (1M context)"
    "opus47"      = "Claude Opus 4.7"
    "opus47-1m"   = "Claude Opus 4.7 (1M context)"
    "opus46"      = "Claude Opus 4.6"
    "opus46-1m"   = "Claude Opus 4.6 (1M context)"
    "opus45"      = "Claude Opus 4.5"
    "opus45-1m"   = "Claude Opus 4.5 (1M context)"
    "opus41"      = "Claude Opus 4.1"
    "opus41-1m"   = "Claude Opus 4.1 (1M context)"
    "opus4"       = "Claude Opus 4"
    "opus4-1m"    = "Claude Opus 4 (1M context)"
    "haiku45"     = "Claude Haiku 4.5"
    "haiku45-1m"  = "Claude Haiku 4.5 (1M context)"
    "sonnet37"    = "Claude Sonnet 3.7"
    "sonnet35"    = "Claude Sonnet 3.5"
    "haiku35"     = "Claude Haiku 3.5"
    "mythos5"     = "Claude Mythos 5"
    "mythos51"    = "Claude Mythos 5.1"
    "claudecode"  = "Claude Code"
    "claude"      = "Claude"
}

$modelName = $modelNameMap[$Model]
# Fallback in v2.1.270 for unrecognized/third-party models is "Claude Code"
if (-not $modelName) { $modelName = "Claude Code" }

$prefix = if ($Lowercase) { "Co-authored-by" } else { "Co-Authored-By" }
$trailer = "$prefix`: $modelName <noreply@anthropic.com>"

$suppressSession = ($env:CLAUDE_CODE_SUPPRESS_SESSION_ATTRIBUTION -eq "1" -or $env:CLAUDE_CODE_SUPPRESS_SESSION_ATTRIBUTION -eq "true")
if (-not $suppressSession) {
    if ($SessionId -eq "" -and $AutoSession) {
        $SessionId = Get-ClaudeSessionId
    }
    if ($SessionId -ne "") {
        $sessionUrl = if ($SessionId.StartsWith("https://")) { $SessionId } else { "https://claude.ai/code/$SessionId" }
        $trailer = "$trailer`nClaude-Session: $sessionUrl"
    }
}

$fullMsg = @"
$Title

$Body

$trailer
"@

if ($DryRun) {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Claude Mimic - Commit Dry Run" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host $fullMsg
    Write-Host "==========================================" -ForegroundColor Yellow
    return
}

# Git Safety Protocol: Ensure git repository
$isRepo = & git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Git Safety Protocol: Not inside a git repository."
    exit 1
}

# Git Safety Protocol: Check for staged changes
& git diff --cached --quiet 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Error "Git Safety Protocol: No staged changes found. Claude Code will not create empty commits."
    exit 1
}

# Git Safety Protocol: Check for sensitive files
$stagedFiles = & git diff --cached --name-only
$sensitive = $stagedFiles | Where-Object { $_ -match "(\.env|\.credentials|credentials\.json|id_rsa|private_key|\.pem)$" }
if ($sensitive) {
    Write-Error "Git Safety Protocol: Staged files likely contain secrets: $($sensitive -join ', '). Commit aborted."
    exit 1
}

Write-Host "Creating commit with:" -ForegroundColor Cyan
Write-Host $trailer -ForegroundColor Green

$gitArgs = @("commit", "-m", $fullMsg)
if ($NoGpgSign) {
    $gitArgs += "--no-gpg-sign"
}

& git @gitArgs
