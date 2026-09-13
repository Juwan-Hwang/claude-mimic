/**
 * Claude Mimic plugin for OpenCode
 */
export default async function ({ registerCommand, registerRule }) {
  if (typeof registerRule === 'function') {
    registerRule({
      name: 'claude-mimic',
      description: "Format git commits and PRs in Claude Code's dialect",
      rule: "Follow Claude Code's Git Safety Protocol: NEVER commit unless asked, NEVER amend, NEVER skip hooks, format commit with concise why and RFC 2822 Co-Authored-By trailer, PRs with Summary/Test plan and robot signature."
    });
  }

  registerCommand({
    name: 'claude-mimic',
    description: "Format git commits and PRs in Claude Code's dialect",
    handler: async (context) => {
      return {
        instruction: "Format git commits and PRs in Claude Code dialect: concise why, RFC 2822 trailer 'Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>', and PR footer '🤖 Generated with [Claude Code](https://claude.com/claude-code)'."
      };
    }
  });
}
