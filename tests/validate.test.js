import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { execSync } from 'node:child_process';

const ROOT = path.resolve('.');

function runPs(scriptRelativePath, args) {
  let shell = 'pwsh';
  try {
    execSync('pwsh -v', { stdio: 'ignore' });
  } catch {
    shell = 'powershell';
  }
  return execSync(`${shell} -NoProfile -File "${path.join(ROOT, scriptRelativePath)}" ${args}`, {
    cwd: ROOT,
    encoding: 'utf-8'
  });
}

function runBash(scriptRelativePath, args) {
  let bashBin = 'sh';
  try {
    execSync('sh --version', { stdio: 'ignore' });
  } catch {
    if (fs.existsSync('C:\\Program Files\\Git\\bin\\bash.exe')) {
      bashBin = '"C:\\Program Files\\Git\\bin\\bash.exe"';
    } else {
      bashBin = 'bash';
    }
  }
  return execSync(`${bashBin} "${path.join(ROOT, scriptRelativePath).replace(/\\/g, '/')}" ${args}`, {
    cwd: ROOT,
    encoding: 'utf-8'
  });
}

test('Model matrix and references contain verified 19 models and accurate canonical IDs', () => {
  const modelMatrix = fs.readFileSync(path.join(ROOT, 'references/model-matrix.md'), 'utf-8');
  assert.ok(modelMatrix.includes('Claude Sonnet 5'), 'model-matrix.md must contain Sonnet 5');
  assert.ok(modelMatrix.includes('Claude Sonnet 3.5'), 'model-matrix.md must contain Sonnet 3.5');
  assert.ok(modelMatrix.includes('Claude Sonnet 3.7'), 'model-matrix.md must contain Sonnet 3.7');
  assert.ok(modelMatrix.includes('Claude Mythos 5.1'), 'model-matrix.md must contain Mythos 5.1');
  assert.ok(modelMatrix.includes('Claude Mythos 5'), 'model-matrix.md must contain Mythos 5');
  assert.ok(modelMatrix.includes('Claude Fable 5.1'), 'model-matrix.md must contain Fable 5.1');
  assert.ok(modelMatrix.includes('Claude Opus 5'), 'model-matrix.md must contain Opus 5');

  // Verify canonical IDs from v2.1.270 binary
  assert.ok(modelMatrix.includes('claude-3-5-sonnet'), 'Canonical ID must be claude-3-5-sonnet');
  assert.ok(modelMatrix.includes('claude-3-7-sonnet'), 'Canonical ID must be claude-3-7-sonnet');
  assert.ok(modelMatrix.includes('claude-3-5-haiku'), 'Canonical ID must be claude-3-5-haiku');
  assert.ok(modelMatrix.includes('claude-opus-4-0'), 'Canonical ID must be claude-opus-4-0');
  assert.ok(modelMatrix.includes('claude-sonnet-4-0'), 'Canonical ID must be claude-sonnet-4-0');

  const prSigs = fs.readFileSync(path.join(ROOT, 'references/pr-signatures.md'), 'utf-8');
  assert.ok(prSigs.includes('claude-sonnet-5'), 'pr-signatures.md must contain claude-sonnet-5');
  assert.ok(prSigs.includes('claude-3-5-sonnet'), 'pr-signatures.md must contain claude-3-5-sonnet');
  assert.ok(prSigs.includes('via Cowork'), 'pr-signatures.md must document via Cowork surface mode');
  assert.ok(prSigs.includes('Claude-Session:'), 'pr-signatures.md must document Claude-Session commit trailer');
});

test('Model constraints: Sonnet 5, Fable, and Mythos never receive 1M suffix; 11 catalog models support 1M suffix', () => {
  const scriptsToCheck = [
    'scripts/git-claude-commit.ps1',
    'scripts/git-claude-commit.sh',
    'scripts/gh-claude-pr.ps1',
    'scripts/gh-claude-pr.sh'
  ];

  for (const f of scriptsToCheck) {
    const content = fs.readFileSync(path.join(ROOT, f), 'utf-8');
    assert.ok(!content.includes('sonnet5-1m'), `${f} must NOT contain sonnet5-1m option`);
    assert.ok(!content.includes('Claude Sonnet 5 (1M context)'), `${f} must NOT contain 'Claude Sonnet 5 (1M context)'`);
    assert.ok(!content.includes('Claude Fable 5 (1M context)'), `${f} must NOT contain 'Claude Fable 5 (1M context)'`);
    assert.ok(!content.includes('Claude Mythos 5 (1M context)'), `${f} must NOT contain 'Claude Mythos 5 (1M context)'`);
  }

  const modelMatrix = fs.readFileSync(path.join(ROOT, 'references/model-matrix.md'), 'utf-8');
  assert.ok(modelMatrix.includes('Native 1M'), 'model-matrix.md must document Native 1M');
  assert.ok(modelMatrix.includes('33 Valid Forms'), 'model-matrix.md must document 33 Valid Forms');

  const skill = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
  assert.ok(skill.includes('Native 1M'), 'SKILL.md must document Native 1M');
});

test('Settings types, regex, and identity guards: commitTrailers is bool, session regex and email guards verified', () => {
  const skill = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
  assert.ok(skill.includes('`attribution.commitTrailers` (bool)'), 'SKILL.md must document attribution.commitTrailers as bool');
  assert.ok(skill.includes('^(cse_|session_)[A-Za-z0-9_-]{1,128}$'), 'SKILL.md must document client validation regex');
  assert.ok(skill.includes('claude@anthropic.com'), 'SKILL.md must guard against claude@anthropic.com');

  const modelMatrix = fs.readFileSync(path.join(ROOT, 'references/model-matrix.md'), 'utf-8');
  assert.ok(modelMatrix.includes('claude@anthropic.com'), 'model-matrix.md must guard against claude@anthropic.com');
});

test('Edge cases: Revert commits, maintainer rebase, and file sync identities are documented', () => {
  const templates = fs.readFileSync(path.join(ROOT, 'references/templates.md'), 'utf-8');
  assert.ok(templates.includes('Revert "'), 'templates.md must document revert commit template');
  assert.ok(templates.includes('Claude Code file sync'), 'templates.md must document file sync identity');

  const gitConv = fs.readFileSync(path.join(ROOT, 'docs/git-conventions.md'), 'utf-8');
  assert.ok(gitConv.includes('Claude Code file sync'), 'docs/git-conventions.md must document file sync identity');
  assert.ok(gitConv.includes('Revert "'), 'docs/git-conventions.md must document revert commit template');
});

test('Clean references: No scraping or direct third-party repo citations in skill and references', () => {
  const filesToCheck = [
    'references/model-matrix.md',
    'references/pr-signatures.md',
    'references/templates.md',
    'docs/git-conventions.md',
    'SKILL.md',
    'skills/claude-mimic/SKILL.md',
    '.cursor/skills/claude-mimic/SKILL.md'
  ];

  const forbiddenCitations = [
    'ayghri',
    'i-have-adhd',
    'worldcoin/world-chain',
    'oxidecomputer/sush',
    'sector-dynasties',
    'keepur/hive'
  ];

  for (const f of filesToCheck) {
    const content = fs.readFileSync(path.join(ROOT, f), 'utf-8');
    for (const citation of forbiddenCitations) {
      assert.ok(!content.includes(citation), `${f} must NOT cite external private scraping target '${citation}'`);
    }
  }
});

test('SKILL.md, skills/claude-mimic/SKILL.md, and .cursor/skills/claude-mimic/SKILL.md must be identical and have Git Safety Protocol', () => {
  const rootSkill = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
  const innerSkill = fs.readFileSync(path.join(ROOT, 'skills/claude-mimic/SKILL.md'), 'utf-8');
  const cursorSkill = fs.readFileSync(path.join(ROOT, '.cursor/skills/claude-mimic/SKILL.md'), 'utf-8');
  assert.equal(rootSkill.replace(/\r\n/g, '\n'), innerSkill.replace(/\r\n/g, '\n'), 'SKILL.md and skills/claude-mimic/SKILL.md must match exactly');
  assert.equal(rootSkill.replace(/\r\n/g, '\n'), cursorSkill.replace(/\r\n/g, '\n'), 'SKILL.md and .cursor/skills/claude-mimic/SKILL.md must match exactly');

  assert.ok(rootSkill.includes('Git Safety Protocol'), 'SKILL.md must include Git Safety Protocol');
  assert.ok(rootSkill.includes('NEVER update git config'), 'SKILL.md must forbid updating git config');
  assert.ok(rootSkill.includes('NEVER `git commit --amend`'), 'SKILL.md must forbid git commit --amend');
  assert.ok(rootSkill.includes('concise'), 'SKILL.md must default to concise commit messages');
  assert.ok(rootSkill.includes('under 70 characters'), 'SKILL.md must require PR titles under 70 chars');
  assert.ok(rootSkill.includes('Claude-Session:'), 'SKILL.md must include Claude-Session trailer');
  assert.ok(rootSkill.includes('via <Surface>'), 'SKILL.md must document surface mode');
  assert.ok(rootSkill.includes('Default Bias'), 'SKILL.md must include Default Bias section');
  assert.ok(rootSkill.includes('Claude Sonnet 3.7'), 'SKILL.md must use correct naming order Claude Sonnet 3.7');
  assert.ok(rootSkill.includes('Claude Sonnet 3.5'), 'SKILL.md must document Claude Sonnet 3.5');
  assert.ok(rootSkill.includes('Claude Haiku 3.5'), 'SKILL.md must use correct naming order Claude Haiku 3.5');
  assert.ok(rootSkill.includes('references/model-matrix.md'), 'SKILL.md must link to references/model-matrix.md');
  assert.ok(rootSkill.includes('references/pr-signatures.md'), 'SKILL.md must link to references/pr-signatures.md');
  assert.ok(rootSkill.includes('references/templates.md'), 'SKILL.md must link to references/templates.md');
  assert.ok(rootSkill.includes('Agent Capability Self-Assessment'), 'SKILL.md must define capability self-assessment');
  assert.ok(rootSkill.includes('Claude Opus 4.8 (1M context)'), 'SKILL.md must document Opus 4.8 (1M context)');
});

test('Multi-agent manifests and derived rule files must be valid and preserve Git Safety Protocol', () => {
  const manifests = [
    'plugin.json',
    '.claude-plugin/plugin.json',
    '.codex-plugin/plugin.json',
    'opencode.json',
    'gemini-extension.json',
    'kimi.plugin.json',
    'qwen-extension.json'
  ];

  for (const m of manifests) {
    const fullPath = path.join(ROOT, m);
    assert.ok(fs.existsSync(fullPath), `Manifest ${m} must exist`);
    const content = fs.readFileSync(fullPath, 'utf-8');
    assert.doesNotThrow(() => JSON.parse(content), `Manifest ${m} must be valid JSON`);
  }

  const agentRuleFiles = [
    '.cursor/rules/claude-mimic.mdc',
    'AGENTS.md',
    'GEMINI.md',
    'CONTRIBUTING.md'
  ];

  for (const arf of agentRuleFiles) {
    const fullPath = path.join(ROOT, arf);
    assert.ok(fs.existsSync(fullPath), `${arf} must exist`);
    const content = fs.readFileSync(fullPath, 'utf-8');
    assert.ok(content.includes('Git Safety Protocol') || content.includes('SKILL.md'), `${arf} must reference Git Safety Protocol or SKILL.md`);
  }
});

test('README.md and multilingual variants adhere to centered header, i-have-adhd format, and clean presentation', () => {
  const readmeEn = fs.readFileSync(path.join(ROOT, 'README.md'), 'utf-8');
  const readmeZh = fs.readFileSync(path.join(ROOT, 'README.zh-CN.md'), 'utf-8');
  const readmeJa = fs.readFileSync(path.join(ROOT, 'README.ja.md'), 'utf-8');
  const readmeKo = fs.readFileSync(path.join(ROOT, 'README.ko.md'), 'utf-8');

  // Centered Claude Mimic header check
  assert.ok(readmeEn.includes('<h1 align="center">Claude Mimic</h1>'), 'README.md must have centered Claude Mimic header');
  assert.ok(readmeZh.includes('<h1 align="center">Claude Mimic</h1>'), 'README.zh-CN.md must have centered Claude Mimic header');
  assert.ok(readmeJa.includes('<h1 align="center">Claude Mimic</h1>'), 'README.ja.md must have centered Claude Mimic header');
  assert.ok(readmeKo.includes('<h1 align="center">Claude Mimic</h1>'), 'README.ko.md must have centered Claude Mimic header');

  // Language switchers
  assert.ok(readmeEn.includes('English') && readmeEn.includes('简体中文'), 'README.md must have language switcher');
  assert.ok(readmeZh.includes('English') && readmeZh.includes('简体中文'), 'README.zh-CN.md must have language switcher');

  // Centered horizontal badges
  assert.match(readmeEn, /<p align="center">[\s\S]*?<img src="https:\/\/img\.shields\.io/, 'README.md must center badges horizontally');
  assert.match(readmeZh, /<p align="center">[\s\S]*?<img src="https:\/\/img\.shields\.io/, 'README.zh-CN.md must center badges horizontally');

  // Comparison table
  assert.ok(readmeEn.includes('## The Difference'), 'README.md must include The Difference comparison table');
  assert.ok(readmeZh.includes('## 效果对比'), 'README.zh-CN.md must include The Difference comparison table');

  // Multi-Agent compatibility
  assert.ok(readmeEn.includes('## Multi-Agent Compatibility'), 'README.md must document Multi-Agent Compatibility');
  assert.ok(readmeZh.includes('## 多平台 Agent 兼容性'), 'README.zh-CN.md must document Multi-Agent Compatibility');

  // Transparency / Disclaimer section
  assert.ok(readmeEn.includes('## Responsible Use & Transparency'), 'README.md must have transparency section');
  assert.ok(readmeZh.includes('## 负责任使用与透明度说明'), 'README.zh-CN.md must have compliance section');

  const allReadmes = [readmeEn, readmeZh, readmeJa, readmeKo];
  const sensitivePatterns = [/leaked source/i, /decompiled/i, /reverse engineering/i, /\bIDA\b/];
  for (const doc of allReadmes) {
    for (const pat of sensitivePatterns) {
      assert.ok(!pat.test(doc), `README must not contain sensitive pattern ${pat}`);
    }
  }

  assert.ok(!readmeEn.includes('## ⚡'), 'README.md must not use emoji prefix in headings');
  assert.ok(!readmeEn.includes('## 🚀'), 'README.md must not use emoji prefix in headings');
});

test('gh-claude-pr.sh contains authentic v2.1.270 iRr() reference and no fWu comment', () => {
  const shContent = fs.readFileSync(path.join(ROOT, 'scripts/gh-claude-pr.sh'), 'utf-8');
  assert.ok(!shContent.includes('fWu('), 'gh-claude-pr.sh must not contain fWu comment');
  assert.ok(shContent.includes('iRr()'), 'gh-claude-pr.sh must reference iRr()');
});

test('gh-claude-pr.ps1 default dry-run omits Changelog and generates clean unadorned signature', () => {
  const output = runPs('scripts/gh-claude-pr.ps1', '-Title "fix(evals): close child stdin" -DryRun');

  assert.ok(output.includes('## Summary'), 'Output must include ## Summary');
  assert.ok(output.includes('## Test plan'), 'Output must include ## Test plan');
  assert.ok(!output.includes('## Changelog'), 'Default PR output must omit ## Changelog');
  assert.ok(!output.includes('<!-- CHANGELOG:START -->'), 'Default PR output must omit changelog markers');
  assert.ok(output.includes('🤖 Generated with [Claude Code](https://claude.com/claude-code)'), 'Output must include clean unadorned signature');
});

test('gh-claude-pr.ps1 supports --Surface and renders via Cowork', () => {
  const output = runPs('scripts/gh-claude-pr.ps1', '-Title "fix(evals): close child stdin" -Surface cowork -DryRun');

  assert.ok(output.includes('🤖 Generated with [Claude Code](https://claude.com/claude-code) via Cowork'), 'Output must include via Cowork');
});

test('gh-claude-pr.ps1 remote mode generates authentic session ID', () => {
  const output = runPs('scripts/gh-claude-pr.ps1', '-Title "fix(evals): close child stdin" -SignatureMode remote -DryRun');

  assert.match(output, /https:\/\/claude\.ai\/code\/session_01[1-9A-HJ-NP-Za-km-z]{22}/, 'Session URL must use authentic session pattern');
});

test('gh-claude-pr.ps1 places Changelog block BEFORE signature when requested', () => {
  const output = runPs('scripts/gh-claude-pr.ps1', '-Title "fix(wire): enforce order" -SignatureMode changelog -DryRun');

  const changelogIdx = output.indexOf('<!-- CHANGELOG:START -->');
  const sigIdx = output.indexOf('🤖 Generated with');
  assert.ok(changelogIdx > 0, 'Changelog block must exist');
  assert.ok(sigIdx > 0, 'Signature must exist');
  assert.ok(changelogIdx < sigIdx, 'Changelog block must be placed BEFORE signature');
});

test('git-claude-commit.ps1 supports default sonnet5 model trailer and sonnet35 option', () => {
  const outputDefault = runPs('scripts/git-claude-commit.ps1', '-Title "feat(auth): tighten monotonic TTL" -Body "Enforces monotonic clock." -DryRun');
  assert.ok(outputDefault.includes('Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>'), 'Default model must be Claude Sonnet 5');
  assert.ok(!outputDefault.includes('(1M context)'), 'Sonnet 5 must not have (1M context)');

  const outputSonnet35 = runPs('scripts/git-claude-commit.ps1', '-Title "feat(auth): tighten monotonic TTL" -Body "Enforces monotonic clock." -Model sonnet35 -DryRun');
  assert.ok(outputSonnet35.includes('Co-Authored-By: Claude Sonnet 3.5 <noreply@anthropic.com>'), 'Model sonnet35 must produce Claude Sonnet 3.5');
});

test('git-claude-commit.ps1 supports dual trailer (Claude-Session:) and lowercase casing', () => {
  const output = runPs('scripts/git-claude-commit.ps1', '-Title "feat(planets): add table" -Body "Calculates mineral yield." -Model opus47 -SessionId session_01U7vy96qF63BugmboFm2wPw -Lowercase -DryRun');

  assert.ok(output.includes('Co-authored-by: Claude Opus 4.7 <noreply@anthropic.com>'), 'Must support lowercase Co-authored-by and Opus 4.7');
  assert.ok(output.includes('Claude-Session: https://claude.ai/code/session_01U7vy96qF63BugmboFm2wPw'), 'Must include Claude-Session URL');

  const coAuthIdx = output.indexOf('Co-authored-by: Claude Opus 4.7');
  const sessionIdx = output.indexOf('Claude-Session: https://claude.ai/code/session_01U7vy96qF63BugmboFm2wPw');
  assert.ok(coAuthIdx > 0, 'Co-authored-by must exist');
  assert.ok(sessionIdx > coAuthIdx, 'Claude-Session must follow Co-authored-by');
});

test('gh-claude-pr.sh behavior: default dry-run, mode8, and surface', () => {
  const outputDefault = runBash('scripts/gh-claude-pr.sh', '-t "fix(evals): close child stdin" --dry-run');
  assert.ok(outputDefault.includes('## Summary'), 'sh output must include ## Summary');
  assert.ok(outputDefault.includes('## Test plan'), 'sh output must include ## Test plan');
  assert.ok(!outputDefault.includes('## Changelog'), 'sh default PR output must omit ## Changelog');
  assert.ok(outputDefault.includes('🤖 Generated with [Claude Code](https://claude.com/claude-code)'), 'sh output must include clean unadorned signature');

  const outputP8 = runBash('scripts/gh-claude-pr.sh', '-t "feat(cloud): add container" --mode p8 --dry-run');
  assert.ok(outputP8.includes('---'), 'P8 must include horizontal rule separator');
  assert.match(outputP8, /_Generated by \[Claude Code\]\(https:\/\/claude\.ai\/code\/session_01[1-9A-HJ-NP-Za-km-z]{22}\)_/, 'P8 must include italicized attribution link');

  const outputSurface = runBash('scripts/gh-claude-pr.sh', '-t "fix(evals): close child stdin" --surface cowork --dry-run');
  assert.ok(outputSurface.includes('🤖 Generated with [Claude Code](https://claude.com/claude-code) via Cowork'), 'sh output must support surface cowork');
});

test('git-claude-commit.sh behavior: default Sonnet 5, dual trailer, and lowercase', () => {
  const outputDefault = runBash('scripts/git-claude-commit.sh', '-t "feat(auth): tighten TTL" -b "Enforces clock." --dry-run');
  assert.ok(outputDefault.includes('Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>'), 'sh default model must be Claude Sonnet 5');
  assert.ok(!outputDefault.includes('(1M context)'), 'Sonnet 5 must not receive (1M context)');

  const outputDual = runBash('scripts/git-claude-commit.sh', '-t "feat(planets): add table" -b "Calculates yield." -m opus47 -s session_01U7vy96qF63BugmboFm2wPw -l --dry-run');
  assert.ok(outputDual.includes('Co-authored-by: Claude Opus 4.7 <noreply@anthropic.com>'), 'sh must support lowercase Co-authored-by and Opus 4.7');
  assert.ok(outputDual.includes('Claude-Session: https://claude.ai/code/session_01U7vy96qF63BugmboFm2wPw'), 'sh must include Claude-Session URL');
});

test('v2.1.270 Parity: C6 has Claude-Session tag, P8 is documented, Fable rules are harmonized, and Author is human', () => {
  const skill = fs.readFileSync(path.join(ROOT, 'SKILL.md'), 'utf-8');
  assert.ok(skill.includes('| C6 | `Claude-Session: https://claude.ai/code/session_<id>`'), 'C6 commit trailer must carry Claude-Session tag, never bare URL');
  assert.ok(skill.includes('Author vs. Committer Protocol'), 'SKILL.md must define human Author vs Committer protocol');
  assert.ok(skill.includes('P8'), 'SKILL.md must document P8 signature');
  assert.ok(skill.includes('Claude Fable 5.1'), 'SKILL.md must document Claude Fable 5.1');
  assert.ok(skill.includes('Managed Attribution Precedence'), 'SKILL.md must define enterprise managed settings hierarchy');

  const modelMatrix = fs.readFileSync(path.join(ROOT, 'references/model-matrix.md'), 'utf-8');
  assert.ok(modelMatrix.includes('Timeline Consistency Matrix'), 'model-matrix.md must contain Timeline Consistency Matrix');
  assert.ok(modelMatrix.includes('claude-fable-5-mythos-5'), 'model-matrix.md must cite authentic binary fallback model');
});

test('Strict separation: Agent-facing skill files contain no human research trivia or case studies', () => {
  const refFiles = fs.readdirSync(path.join(ROOT, 'references')).sort();
  assert.deepEqual(refFiles, ['model-matrix.md', 'pr-signatures.md', 'templates.md'], 'references/ must contain ONLY agent lookup manuals');

  const agentFacingFiles = [
    'SKILL.md',
    'skills/claude-mimic/SKILL.md',
    '.cursor/skills/claude-mimic/SKILL.md',
    'references/model-matrix.md',
    'references/pr-signatures.md',
    'references/templates.md'
  ];

  const humanTriviaPatterns = [
    /170[,\.]000\+\s*followers/i,
    /\bu\/81847\b/,
    /\bfrom upstream \/commit-push-pr\b/i,
    /\(87%\+\s*Empirical\s*Share\)/i,
    /\bahs\(e\)/i,
    /GitHub\s*App\s*ID\s*1236702/i,
    /\bdecompil/i,
    /\breverse[\s-]engineering\b/i
  ];

  for (const aff of agentFacingFiles) {
    const content = fs.readFileSync(path.join(ROOT, aff), 'utf-8');
    for (const pat of humanTriviaPatterns) {
      assert.ok(!pat.test(content), `${aff} must NOT contain human trivia pattern ${pat}`);
    }
  }
});

test('Reference files in root, skills/, and .cursor/skills/ must match byte-for-byte', () => {
  const refFiles = ['model-matrix.md', 'pr-signatures.md', 'templates.md'];
  for (const ref of refFiles) {
    const rootRef = fs.readFileSync(path.join(ROOT, 'references', ref), 'utf-8');
    const innerRef = fs.readFileSync(path.join(ROOT, 'skills/claude-mimic/references', ref), 'utf-8');
    const cursorRef = fs.readFileSync(path.join(ROOT, '.cursor/skills/claude-mimic/references', ref), 'utf-8');
    assert.equal(rootRef.replace(/\r\n/g, '\n'), innerRef.replace(/\r\n/g, '\n'), `references/${ref} must match skills/claude-mimic/references/${ref}`);
    assert.equal(rootRef.replace(/\r\n/g, '\n'), cursorRef.replace(/\r\n/g, '\n'), `references/${ref} must match .cursor/skills/claude-mimic/references/${ref}`);
  }
});

test('Bedrock and cloud IDs in docs/git-conventions.md use bare foundation model IDs', () => {
  const gitConv = fs.readFileSync(path.join(ROOT, 'docs/git-conventions.md'), 'utf-8');
  assert.ok(!gitConv.includes('20260601'), 'docs/git-conventions.md must NOT contain fake date 20260601');
  assert.ok(!gitConv.includes('20260515'), 'docs/git-conventions.md must NOT contain fake date 20260515');
  assert.ok(gitConv.includes('anthropic.claude-opus-5'), 'docs/git-conventions.md must use bare Bedrock foundation model ID');
  assert.ok(gitConv.includes('us.anthropic.claude-fable-5'), 'docs/git-conventions.md must use bare cross-region inference ID');
});

test('Surface mappings include claude-desktop-3p alias', () => {
  const prSigs = fs.readFileSync(path.join(ROOT, 'references/pr-signatures.md'), 'utf-8');
  assert.ok(prSigs.includes('claude-desktop-3p'), 'pr-signatures.md must document claude-desktop-3p');
  const sh = fs.readFileSync(path.join(ROOT, 'scripts/gh-claude-pr.sh'), 'utf-8');
  assert.ok(sh.includes('claude-desktop-3p'), 'gh-claude-pr.sh must handle claude-desktop-3p');
  const ps1 = fs.readFileSync(path.join(ROOT, 'scripts/gh-claude-pr.ps1'), 'utf-8');
  assert.ok(ps1.includes('claude-desktop-3p'), 'gh-claude-pr.ps1 must handle claude-desktop-3p');
});

test('Release Readiness: README files contain real username, skills CLI install, and manifests at v1.0.0', () => {
  const readmes = ['README.md', 'README.zh-CN.md', 'README.ja.md', 'README.ko.md'];
  for (const r of readmes) {
    const content = fs.readFileSync(path.join(ROOT, r), 'utf-8');
    assert.ok(!content.includes('<your-'), `${r} must NOT contain '<your-' placeholder`);
    assert.ok(content.includes('Juwan-Hwang/claude-mimic'), `${r} must use actual repository slug Juwan-Hwang/claude-mimic`);
    assert.ok(content.includes('npx skills add Juwan-Hwang/claude-mimic'), `${r} must include npx skills command`);
  }

  assert.ok(!fs.existsSync(path.join(ROOT, 'CHANGELOG.md')), 'CHANGELOG.md must not exist prior to first public release');

  const manifests = ['package.json', 'plugin.json', 'gemini-extension.json', 'opencode.json', 'kimi.plugin.json', 'qwen-extension.json'];
  for (const m of manifests) {
    const parsed = JSON.parse(fs.readFileSync(path.join(ROOT, m), 'utf-8'));
    assert.equal(parsed.version, '1.0.0', `${m} version must be 1.0.0`);
  }
});

test('E2E Git Execution: creates a temporary repository, performs commit via script, and verifies RFC 2822 trailer', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'claude-mimic-e2e-'));
  try {
    // 1. Initialize temporary git repository
    execSync('git init', { cwd: tmpDir, stdio: 'ignore' });
    execSync('git config user.name "Tester"', { cwd: tmpDir, stdio: 'ignore' });
    execSync('git config user.email "tester@example.com"', { cwd: tmpDir, stdio: 'ignore' });
    execSync('git config commit.gpgsign false', { cwd: tmpDir, stdio: 'ignore' });

    // 2. Stage a test file
    fs.writeFileSync(path.join(tmpDir, 'feature.txt'), 'console.log("hello world");\n');
    execSync('git add feature.txt', { cwd: tmpDir, stdio: 'ignore' });

    // 3. Execute git-claude-commit.ps1 with -NoGpgSign
    const scriptPath = path.join(ROOT, 'scripts/git-claude-commit.ps1');
    const commitCmd = `pwsh -NoProfile -ExecutionPolicy Bypass -File "${scriptPath}" -Title "feat(core): initialize feature subsystem" -Body "Sets up initial subsystem entrypoint." -Model sonnet5 -NoGpgSign`;
    execSync(commitCmd, { cwd: tmpDir, stdio: 'ignore' });

    // 4. Verify git log message and RFC 2822 trailer
    const logOutput = execSync('git log -1 --pretty=format:"%B"', { cwd: tmpDir, encoding: 'utf-8' });
    assert.ok(logOutput.includes('feat(core): initialize feature subsystem'), 'Commit title must match');
    assert.ok(logOutput.includes('Sets up initial subsystem entrypoint.'), 'Commit body must match');
    assert.ok(logOutput.includes('Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>'), 'Co-Authored-By trailer must be present');

    // 5. Verify git can parse the trailer via git interpret-trailers
    const trailerOutput = execSync('git interpret-trailers --parse', { input: logOutput, encoding: 'utf-8' });
    assert.ok(trailerOutput.includes('Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>'), 'git interpret-trailers must recognize the co-author trailer');
  } finally {
    // 6. Clean up temporary directory
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});
