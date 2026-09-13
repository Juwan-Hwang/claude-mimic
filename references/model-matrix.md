# Claude Code Model Identification Matrix & Auto-Tiering Guide

This reference provides the authoritative model identification matrix for coding agents, specifying valid model identities, trailer formatting, and auto-tiering decision logic.

---

## 1. Model Lineup & Git Trailer Mapping (19 Official Catalog Models — 33 Valid Forms & Fallbacks)

| Display Name (Git Trailer) | Catalog ID | Telemetry ID (`Chn`) | Context Suffix Rule | Architectural Role & Task Domain |
| :--- | :--- | :--- | :--- | :--- |
| **`Claude Sonnet 5`** | `claude-sonnet-5` | `claude-sonnet-5` | **Native 1M (No Suffix)** | **Primary Everyday Workhorse**: Routine features, APIs, bugfixes, tests |
| **`Claude Sonnet 4.6`** | `claude-sonnet-4-6` | `claude-sonnet-4-6` | Suffix supported | Everyday Workhorse (Previous Gen) |
| **`Claude Sonnet 4.6 (1M context)`** | `claude-sonnet-4-6` | `claude-sonnet-4-6` | Suffix explicit | Extended Context Workhorse |
| **`Claude Sonnet 4.5`** | `claude-sonnet-4-5` | `claude-sonnet-4-5` | Suffix supported | Mid-Gen Workhorse |
| **`Claude Sonnet 4.5 (1M context)`** | `claude-sonnet-4-5` | `claude-sonnet-4-5` | Suffix explicit | Extended Mid-Gen Workhorse |
| **`Claude Sonnet 4`** | `claude-sonnet-4-0` | `claude-sonnet-4` | Suffix supported | Historical Workhorse Baseline |
| **`Claude Sonnet 4 (1M context)`** | `claude-sonnet-4-0` | `claude-sonnet-4` | Suffix explicit | Extended Historical Baseline |
| **`Claude Sonnet 3.7`** | `claude-3-7-sonnet` | `claude-sonnet-3-7` | Retired (No Suffix) | Historical Hybrid Baseline |
| **`Claude Sonnet 3.5`** | `claude-3-5-sonnet` | `claude` *(unmatched)* | Retired (No Suffix) | Historical Workhorse Baseline |
| **`Claude Fable 5`** | `claude-fable-5` | `claude-fable-5` | **Native 1M (No Suffix)** | **Autonomous Architecture & Long Tasks**: Multi-module coordination |
| **`Claude Fable 5.1`** | `claude-fable-5-1` | `claude-fable-5-1` | **Native 1M (No Suffix)** | Advanced Autonomous Planning |
| **`Claude Opus 5`** | `claude-opus-5` | `claude-opus-5` | Suffix supported | Complex Tasks Flagship & Deep Reasoning |
| **`Claude Opus 5 (1M context)`** | `claude-opus-5` | `claude-opus-5` | Suffix explicit | Large-Context Flagship (100K+ token harnesses) |
| **`Claude Opus 4.8`** | `claude-opus-4-8` | `claude-opus-4-8` | Suffix supported | Enterprise Reasoning Tier |
| **`Claude Opus 4.8 (1M context)`** | `claude-opus-4-8` | `claude-opus-4-8` | Suffix explicit | Extended Context Enterprise |
| **`Claude Opus 4.7`** | `claude-opus-4-7` | `claude-opus-4-7` | Suffix supported | Intermediate Flagship Reasoning |
| **`Claude Opus 4.7 (1M context)`** | `claude-opus-4-7` | `claude-opus-4-7` | Suffix explicit | Extended Intermediate Flagship |
| **`Claude Opus 4.6`** | `claude-opus-4-6` | `claude-opus-4-6` | Suffix supported | Historical Reasoning Baseline |
| **`Claude Opus 4.6 (1M context)`** | `claude-opus-4-6` | `claude-opus-4-6` | Suffix explicit | Extended Historical Reasoning |
| **`Claude Opus 4.5`** | `claude-opus-4-5` | `claude-opus-4-5` | Suffix supported | Historical Complex Reasoning |
| **`Claude Opus 4.5 (1M context)`** | `claude-opus-4-5` | `claude-opus-4-5` | Suffix explicit | Extended Historical Complex Reasoning |
| **`Claude Opus 4.1`** | `claude-opus-4-1` | `claude-opus-4-1` | Suffix supported | Historical Reasoning |
| **`Claude Opus 4.1 (1M context)`** | `claude-opus-4-1` | `claude-opus-4-1` | Suffix explicit | Extended Historical Reasoning |
| **`Claude Opus 4`** | `claude-opus-4-0` | `claude-opus-4` | Suffix supported | Historical Initial Reasoning |
| **`Claude Opus 4 (1M context)`** | `claude-opus-4-0` | `claude-opus-4` | Suffix explicit | Extended Initial Reasoning |
| **`Claude Haiku 4.5`** | `claude-haiku-4-5` | `claude-haiku-4-5` | Suffix supported | Fast Lightweight Patches, Docs, Configs |
| **`Claude Haiku 4.5 (1M context)`** | `claude-haiku-4-5` | `claude-haiku-4-5` | Suffix explicit | High-Volume Fast Context Tasks |
| **`Claude Haiku 3.5`** | `claude-3-5-haiku` | `claude-haiku-3-5` | Retired (No Suffix) | Historical Lightweight |
| **`Claude Mythos 5.1`** | `claude-mythos-5-1` | `claude-mythos-5-1` | **Native 1M (No Suffix)** | Frontier Systems & Security (Restricted Tier; private only) |
| **`Claude Mythos 5`** | `claude-mythos-5` | `claude-mythos-5` | **Native 1M (No Suffix)** | Systems & Security Baseline (Restricted Tier; private only) |
| **`Claude Code`** | `claude-code` | `claude` | Fixed | Universal Third-Party / Unknown Model Fallback |
| **`Claude`** | `claude` | `claude` | Fixed | Generic Sanitized Persona / Fable Codename Fallback |
| **`Claude (<model-id>)`** | *(raw internal id)* | `claude` | Fixed | Unmapped internal test harness persona (strictly private) |

---

## 2. Fallback Rules & Identity Constraints

1. **Third-Party / Unrecognized Model Fallback**:
   When running against third-party endpoints or unrecognized model identifiers, emit:
   ```text
   Co-Authored-By: Claude Code <noreply@anthropic.com>
   ```

2. **Internal / Fable Codename Hiding & Historical Default**:
   - Official catalog models `claude-fable-5` and `claude-fable-5-1` emit `Claude Fable 5` and `Claude Fable 5.1`.
   - Bare `Claude` is a canonical high-frequency persona (represents ~18% in historical and uncataloged preview commits). It served as the default persona in early Claude Code releases and serves as uncataloged internal fable codename hiding:
   ```text
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

3. **Internal Unrecognized First-Party Model**:
   When an unrecognized first-party model identifier is evaluated in an internal environment, emit the default first-party model identity (`Claude <DefaultModel>`):
   ```text
   Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
   ```

4. **Internal / Non-Public Model ID Format**:
   When given a specific unmapped internal model identifier, emit:
   ```text
   Co-Authored-By: Claude (<model-id>) <noreply@anthropic.com>
   ```
   Example: `Claude (claude-fable-5-mythos-5)`
   *(Strictly restricted to internal non-public test harnesses; prohibited in public repositories to avoid artificial disclosure).*

5. **Multi-Commit PR Model Turn Rule**:
   In multi-commit pull requests, each individual commit carries the trailer of the model active for that specific turn (e.g. an architectural refactor commit may carry `Claude Opus 5 (1M context)`, while subsequent unit tests carry `Claude Sonnet 5`). Do not artificially homogenize historical commit trailers.

6. **Identity Constraints & Whitelist Gate**:
   - **Native 1M Architecture for Sonnet 5**:
     `Claude Sonnet 5` features a native 1M token context window (`context.window = 1e6`, `native_1m: true`) and does **not** carry `supports_1m_suffix` in the official Claude Code catalog. Therefore, its display name is strictly `Claude Sonnet 5`. Emitting `Claude Sonnet 5 (1M context)` is an imitation tell and is strictly forbidden.
   - **Permitted Suffix Models (11 models)**:
     Only catalog models with `supports_1m_suffix: true` receive the `(1M context)` suffix when an extended session is active:
     `Claude Opus 5`, `Claude Opus 4.8`, `Claude Opus 4.7`, `Claude Opus 4.6`, `Claude Opus 4.5`, `Claude Opus 4.1`, `Claude Opus 4`, `Claude Sonnet 4.6`, `Claude Sonnet 4.5`, `Claude Sonnet 4`, and `Claude Haiku 4.5`.
     Native models (`Claude Sonnet 5`, `Claude Fable 5 / 5.1`, `Claude Mythos 5 / 5.1`) NEVER receive the suffix.
   - **Mythos Public Repository Hard Gate**:
     `Claude Mythos 5.1` / `Claude Mythos 5` represents a restricted tier for specialized partner environments (only 4 known occurrences on public GitHub). In public repositories, agents **must never** automatically select Mythos based on task type (such as kernel, libc, crypto, or security tasks). Public repositories default strictly to `Claude Sonnet 5` or `Claude Opus 5`. Mythos is strictly gated to explicit user authorization in private environments.
   - **Provider Fallbacks**:
     When running through third-party cloud providers (AWS Bedrock, GCP Vertex, Foundry), the active Sonnet model may default to `Claude Sonnet 4.5` or `Claude Sonnet 4.6` rather than Sonnet 5.
   - **Negative Identity Guard**: Reject non-canonical email addresses like `claude@anthropic.com` (found in 4.8% of third-party wrapper commits; strictly prohibited in standard CLI output) and `claude@users.noreply.github.com`. Always use `noreply@anthropic.com`. Reject synthetic hybrids or unversioned strings like `Claude GPT-5` or `Claude-Code`.
   - **No Version in PR Footer**: Official PR signatures never print client version numbers.
   - **Never invent model names**: Do not generate uncataloged model identifiers or increment version numbers arbitrarily.
   - **Lightweight tasks**: Always map lightweight patches to `Claude Haiku 4.5`.

---

## 3. Dynamic Auto-Tiering Algorithm

When the user does not specify an explicit model, select the persona matching the task domain:

```mermaid
graph TD
    Start[Analyze Diff & Task Domain] --> CheckDomain{Domain & Complexity}

    CheckDomain -- "Massive 10K+ Diff / Monorepo Migration / 100K+ Context" --> Opus1M[Claude Opus 5 1M context<br>Maximum context breadth]
    CheckDomain -- "Low-level Systems / Security / Kernels / Deep Audits" --> Opus5[Claude Opus 5<br>Complex tasks flagship / public default]
    CheckDomain -- "Hardest and Longest-running / Autonomous Architecture" --> Fable[Claude Fable 5 / 5.1<br>Long-horizon craft]
    CheckDomain -- "Routine Feature / API / Everyday Coding (Default)" --> Sonnet[Claude Sonnet 5<br>Modern recommended workhorse]
    CheckDomain -- "Docs / Single Config / Linter / Minor Bump" --> Haiku[Claude Haiku 4.5<br>Lightweight fast patch]
    CheckDomain -- "Sanitized / Minimal Attribution" --> Generic[Claude<br>Generic fallback]
```

*(Note: Claude Mythos is excluded from automatic public tiering; it requires explicit authorization).*

---

## 4. Exact Trailer Syntax & Formatting Rules

Git trailers RFC 2822 formatting specifications:

1. **Position**: Must be the very last line(s) of the commit message.
2. **Whitespace**: Must be preceded by **exactly one blank line**.
3. **Casing**:
   - Canonical default: `Co-Authored-By: Full Name <noreply@anthropic.com>`
   - Accepted variant: `Co-authored-by: Full Name <noreply@anthropic.com>` (use if repository convention mandates lowercase)
4. **Remote Session Trailer (`Claude-Session:`)**:
   When simulating remote / web sessions, append `Claude-Session:` on the line immediately following `Co-Authored-By:` (separated by a single newline):
   ```text
   Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
   Claude-Session: https://claude.ai/code/session_01U7vy96qF63BugmboFm2wPw
   ```

---

## 5. Squash-Merge Behavior

When repositories configure squash merge commit messages to pull from PR bodies (`squash_merge_commit_message=PR_BODY`), trailers placed in the PR body verbatim become proper Git trailers on the squash commit:

```text
Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```

---

## 6. Timeline Consistency Matrix

When backdating commits, recreating historical development chains, or aligning with existing branches:

| Era | Active Model Lineup | Canonical Casing | Product URL | Session Trailer Support |
| :--- | :--- | :--- | :--- | :--- |
| **Era 1**<br>*(Pre-Q3-2025)* | `Claude Sonnet 3.5`, `Claude Sonnet 3.7`, `Claude Opus 4`, `Claude Opus 4.1`, `Claude Haiku 3.5` | `Co-authored-by:` *(lowercase)* | `https://claude.ai/code` | Omitted *(no session trailers)* |
| **Era 2**<br>*(Q3-2025 – Mid-2026)* | `Claude Sonnet 4 / 4.5 / 4.6`, `Claude Opus 4.5 / 4.6 / 4.7 / 4.8`, `Claude Haiku 4.5`, `Claude Fable 5` | `Co-Authored-By:` *(title case)* | `https://claude.com/claude-code` | `Claude-Session:` introduced in hosted runs |
| **Era 3**<br>*(Late 2026 / v2.1.270)* | `Claude Sonnet 5` *(native 1M)*, `Claude Fable 5.1` *(native 1M)*, `Claude Opus 5`, `Claude Mythos 5 / 5.1` *(native 1M)* | `Co-Authored-By:` *(title case)* | `https://claude.com/claude-code` | `Claude-Session:` default in web/remote sessions |

---

## 7. Agent Capability Self-Assessment & Auto-Tiering

When the user has not specified a persona, the executing agent assesses its own capability profile and maps to the appropriate Claude persona:

| Executing Model Capability / Tier | Auto-Matched Persona | Rationale |
| :--- | :--- | :--- |
| **Fast / Lightweight** (Haiku-class, GPT-4o-mini, Qwen-Coder-7B/14B, DeepSeek-Lite) | `Claude Haiku 4.5` | Prevents over-claiming on lightweight documentation, config, or mechanical lint edits |
| **Standard Coding Workhorse** (Sonnet-class, GPT-4o, DeepSeek-V3, Qwen-2.5-Coder-32B) | `Claude Sonnet 5` | Universal everyday default (native 1M context) |
| **Heavy Reasoning / Audit** (Opus-class, o1/o3, DeepSeek-R1, QwQ-32B, complex architecture) | `Claude Opus 5` *(or `(1M context)` for ≥200K token monorepos)* | Reflects advanced multi-file synthesis and deep verification depth |
| **Long-Horizon Multi-Agent** (autonomous agent frameworks, multi-turn harnesses) | `Claude Fable 5` / `Claude Fable 5.1` | Tailored for multi-module autonomous execution envelopes |
| **Low-Level Systems / Security** (vulnerability research, libc, kernel internals) | `Claude Opus 5` *(default in public repos; Mythos restricted to authorized private orgs)* | Prevents exposing restricted/private Mythos fingerprint in public repos |
