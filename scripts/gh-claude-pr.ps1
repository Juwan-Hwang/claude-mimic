<#
.SYNOPSIS
  Generates and submits an authentic Claude Code Pull Request using GitHub CLI (gh).

.DESCRIPTION
  Formats PR title (< 70 chars), official skeleton body (Summary + Test plan), and 
  authentic Anthropic Claude Code signatures according to production standards.

.PARAMETER Title
  PR title (under 70 chars, e.g., "fix(stream): close child stdin")

.PARAMETER Body
  Full custom markdown body. If omitted, structured template is generated.

.PARAMETER Type
  Template type when Body is omitted: "default" (official skeleton) or "lean" (Variant B).

.PARAMETER Summary
  Summary points for the auto-generated template.

.PARAMETER Changes
  Detailed changes list for the auto-generated template.

.PARAMETER Verification
  Test and verification steps for the auto-generated template.

.PARAMETER Changelog
  Changelog entry text (omitted by default; placed before signature if provided).

.PARAMETER Model
  Claude model identity. Supported: sonnet5, sonnet46, sonnet46-1m, sonnet45, sonnet45-1m, sonnet4, sonnet4-1m, sonnet37, sonnet35, fable5, fable51, opus5, opus5-1m, opus48, opus48-1m, opus47, opus47-1m, opus46, opus46-1m, opus45, opus45-1m, opus41, opus41-1m, opus4, opus4-1m, haiku45, haiku45-1m, haiku35, mythos5, mythos51, claudecode, claude.

.PARAMETER SignatureMode
  Signature mode: standard, surface, remote, enhanced, oneshot, changelog, undercover.

.PARAMETER Surface
  Surface name: cowork, desktop, slack, teams, mobile, actions.

.PARAMETER PromptCount
  Turn / prompt count for enhanced attribution (opt-in). Default: 0.

.PARAMETER Percent
  Contribution percentage for enhanced attribution. Default: 0.

.PARAMETER Memories
  Number of memories recalled. Default: 0.

.PARAMETER LegacyUrl
  Use legacy product URL (https://claude.ai/code) for pre-Q3 2025 repositories.

.PARAMETER Reviewer
  Optional GitHub reviewer handle (default: none; opt-in only).

.PARAMETER BaseBranch
  Base branch to target (e.g., "main").

.PARAMETER Draft
  Create as draft pull request.

.PARAMETER DryRun
  Output PR title and body to console without executing `gh pr create`.

.EXAMPLE
  .\gh-claude-pr.ps1 -Title "fix(stream): close child stdin" -Type default -Model sonnet5 -DryRun
  .\gh-claude-pr.ps1 -Title "fix(stream): close child stdin" -Surface cowork -DryRun
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$false)]
    [string]$Body = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("default", "lean")]
    [string]$Type = "default",

    [Parameter(Mandatory=$false)]
    [string]$Summary = "",

    [Parameter(Mandatory=$false)]
    [string]$Changes = "",

    [Parameter(Mandatory=$false)]
    [Alias("TestPlan")]
    [string]$Verification = "",

    [Parameter(Mandatory=$false)]
    [string]$Changelog = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("sonnet5", "sonnet46", "sonnet46-1m", "sonnet45", "sonnet45-1m", "sonnet4", "sonnet4-1m", "sonnet37", "sonnet35", "fable5", "fable51", "opus5", "opus5-1m", "opus48", "opus48-1m", "opus47", "opus47-1m", "opus46", "opus46-1m", "opus45", "opus45-1m", "opus41", "opus41-1m", "opus4", "opus4-1m", "haiku45", "haiku45-1m", "haiku35", "mythos5", "mythos51", "claudecode", "claude")]
    [string]$Model = "sonnet5",

    [Parameter(Mandatory=$false)]
    [ValidateSet("standard", "surface", "remote", "enhanced", "oneshot", "changelog", "undercover", "mode8", "p8", "remote_attached")]
    [string]$SignatureMode = "standard",

    [Parameter(Mandatory=$false)]
    [string]$SessionId = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("cowork", "desktop", "slack", "teams", "mobile", "actions")]
    [string]$Surface = "",

    [Parameter(Mandatory=$false)]
    [string]$Reviewer = "",

    [Parameter(Mandatory=$false)]
    [int]$PromptCount = 0,

    [Parameter(Mandatory=$false)]
    [int]$Percent = 0,

    [Parameter(Mandatory=$false)]
    [int]$Memories = 0,

    [Parameter(Mandatory=$false)]
    [switch]$LegacyUrl,

    [Parameter(Mandatory=$false)]
    [switch]$NoReviewer,

    [Parameter(Mandatory=$false)]
    [string]$BaseBranch = "",

    [Parameter(Mandatory=$false)]
    [switch]$Draft,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Enforce title length guideline (< 70 chars)
if ($Title.Length -gt 70) {
    Write-Warning "PR title exceeds 70 characters ($($Title.Length) chars). Claude Code guidelines keep titles under 70 characters."
}

$productUrl = if ($LegacyUrl) { "https://claude.ai/code" } else { "https://claude.com/claude-code" }

# Model Slugs
$modelSlugMap = @{
    "sonnet5"     = "claude-sonnet-5"
    "sonnet46"    = "claude-sonnet-4-6"
    "sonnet46-1m" = "claude-sonnet-4-6"
    "sonnet45"    = "claude-sonnet-4-5"
    "sonnet45-1m" = "claude-sonnet-4-5"
    "sonnet4"     = "claude-sonnet-4-0"
    "sonnet4-1m"  = "claude-sonnet-4-0"
    "sonnet37"    = "claude-3-7-sonnet"
    "sonnet35"    = "claude-3-5-sonnet"
    "fable5"      = "claude-fable-5"
    "fable51"     = "claude-fable-5-1"
    "opus5"       = "claude-opus-5"
    "opus5-1m"    = "claude-opus-5"
    "opus48"      = "claude-opus-4-8"
    "opus48-1m"   = "claude-opus-4-8"
    "opus47"      = "claude-opus-4-7"
    "opus47-1m"   = "claude-opus-4-7"
    "opus46"      = "claude-opus-4-6"
    "opus46-1m"   = "claude-opus-4-6"
    "opus45"      = "claude-opus-4-5"
    "opus45-1m"   = "claude-opus-4-5"
    "opus41"      = "claude-opus-4-1"
    "opus41-1m"   = "claude-opus-4-1"
    "opus4"       = "claude-opus-4-0"
    "opus4-1m"    = "claude-opus-4-0"
    "haiku45"     = "claude-haiku-4-5"
    "haiku45-1m"  = "claude-haiku-4-5"
    "haiku35"     = "claude-3-5-haiku"
    "mythos5"     = "claude-mythos-5"
    "mythos51"    = "claude-mythos-5-1"
    "claudecode"  = "claude-code"
    "claude"      = "claude"
}
$modelSlug = $modelSlugMap[$Model]
if (-not $modelSlug) { $modelSlug = "claude-code" }

# Map Surface Name strictly to v2.1.270 iRr() switch cases
function Get-SurfaceDisplay([string]$s) {
    switch ($s) {
        "cowork"            { "Cowork" }
        "desktop"           { "Claude Desktop" }
        "claude-desktop"    { "Claude Desktop" }
        "claude-desktop-3p" { "Claude Desktop" }
        "remote_desktop"    { "Claude Desktop" }
        "slack"             { "Claude Tag in Slack" }
        "teams"             { "Claude Tag in Teams" }
        "mobile"            { "Mobile" }
        "actions"           { "GitHub Actions" }
        default             { $s }
    }
}

# Authentic 32-character Claude Bitcoin Base58 Session ID Generator (session_01 + 22 chars)
# Alphabet: 58 characters (1-9, A-Z excl I/O, a-z excl l)
function Get-ClaudeSessionId {
    $chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    $rand = -join ((1..22) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return "session_01$rand"
}

if ($SessionId -ne "" -and $SignatureMode -eq "standard") {
    $SignatureMode = "remote"
}

if ($Surface -ne "" -and $SignatureMode -eq "standard") {
    $SignatureMode = "surface"
}

# Safe emoji string conversion ensuring GBK console immunity
$robot = [char]::ConvertFromUtf32(0x1F916)

# Build Signature
$sig = ""
switch ($SignatureMode) {
    "standard" {
        $sig = "`n$robot Generated with [Claude Code]($productUrl)"
    }
    "surface" {
        $sName = Get-SurfaceDisplay $Surface
        if (-not $sName) { $sName = "Cowork" }
        $sig = "`n$robot Generated with [Claude Code]($productUrl) via $sName"
    }
    "remote" {
        $sid = if ($SessionId) { $SessionId } else { Get-ClaudeSessionId }
        $sUrl = if ($sid.StartsWith("https://")) { $sid } else { "https://claude.ai/code/$sid" }
        $sig = "`n$robot Generated with [Claude Code]($productUrl)`n`n$sUrl"
    }
    { $_ -in @("mode8", "p8", "remote_attached") } {
        $sid = if ($SessionId) { $SessionId } else { Get-ClaudeSessionId }
        $sUrl = if ($sid.StartsWith("https://")) { $sid } else { "https://claude.ai/code/$sid" }
        $sig = "`n$robot Generated with [Claude Code]($productUrl)`n`n$sUrl`n`n---`n_Generated by [Claude Code]($sUrl)_"
    }
    { $_ -in @("enhanced", "oneshot") } {
        if ($Percent -eq 0 -and $PromptCount -eq 0 -and $Memories -eq 0) {
            $sig = "`n$robot Generated with [Claude Code]($productUrl)"
        } else {
            $memSuffix = ""
            if ($Memories -gt 0) {
                if ($Memories -eq 1) {
                    $memSuffix = ", 1 memory recalled"
                } else {
                    $memSuffix = ", $Memories memories recalled"
                }
            }
            $sig = "`n$robot Generated with [Claude Code]($productUrl) ($Percent% $PromptCount-shotted by $modelSlug$memSuffix)"
        }
    }
    "changelog" {
        $sig = "`n$robot Generated with [Claude Code]($productUrl)"
    }
    "undercover" {
        $sig = ""
    }
}

# Changelog block generator (omitted by default; placed BEFORE signature if requested)
$changelogBlock = ""
if ($SignatureMode -eq "changelog" -or $Changelog -ne "") {
    $cText = if ($Changelog) { $Changelog } else { $Title }
    $changelogBlock = @"

## Changelog
<!-- CHANGELOG:START -->
- $cText
<!-- CHANGELOG:END -->
"@
}

if ($Body -ne "") {
    $finalBody = $Body
    if ($changelogBlock -ne "" -and -not ($finalBody.Contains("<!-- CHANGELOG:START -->"))) {
        $finalBody = "$finalBody`n$changelogBlock"
    }
    if ($sig -ne "" -and -not ($finalBody.Contains("Generated with"))) {
        $finalBody = "$finalBody`n$sig"
    }
} else {
    # Official Claude Code prompt placeholders (_xe() and bxe() in v2.1.270)
    if ($Type -eq "lean") {
        if (-not $Summary) { $Summary = "<1-2 plain sentences: what this change does and why>" }
        if (-not $Verification) { $Verification = "<1-2 lines: what you verified and how (commands run, behavior observed); note anything unverified>" }
    } else {
        if (-not $Summary) { $Summary = "<1-3 bullet points>" }
        if (-not $Verification) { $Verification = "[Bulleted markdown checklist of TODOs for testing the pull request...]" }
    }

    $finalBody = @"
## Summary
$Summary

## Test plan
$Verification$changelogBlock
$sig
"@
}

if ($DryRun) {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Claude Mimic - PR Dry Run" -ForegroundColor Cyan
    Write-Host "Title: $Title ($($Title.Length) chars)" -ForegroundColor Green
    if ($BaseBranch) { Write-Host "Base:  $BaseBranch" -ForegroundColor Gray }
    if ($Draft) { Write-Host "Draft: Yes" -ForegroundColor Magenta }
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host $finalBody
    Write-Host "==========================================" -ForegroundColor Yellow
    return
}

# Check gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI ('gh') is not installed or not in PATH."
    exit 1
}

# Check if PR already exists
$existingPr = $null
try {
    $existingPr = & gh pr view --json number -q .number 2>$null
} catch {}

if ($existingPr) {
    Write-Host "Existing PR #$existingPr found. Updating via 'gh pr edit'..." -ForegroundColor Cyan
    $editArgs = @("pr", "edit", $existingPr, "--title", $Title, "--body", $finalBody)
    if ($Reviewer -ne "" -and -not $NoReviewer) {
        $editArgs += @("--add-reviewer", $Reviewer)
    }
    & gh @editArgs
} else {
    Write-Host "Creating authentic Claude Code Pull Request via 'gh pr create'..." -ForegroundColor Cyan
    $ghArgs = @("pr", "create", "--title", $Title, "--body", $finalBody)
    if ($BaseBranch) { $ghArgs += @("--base", $BaseBranch) }
    if ($Draft) { $ghArgs += "--draft" }
    if ($Reviewer -ne "" -and -not $NoReviewer) {
        $ghArgs += @("--reviewer", $Reviewer)
    }
    & gh @ghArgs
}
