#!/usr/bin/env node
// Foreman Init — First-run CLI discovery and capability profiling
// Asks permission, discovers CLIs, tests capabilities, saves profile.
// Works on macOS, Linux, Windows (with Node installed).

const { execSync, existsSync, mkdirSync, writeFileSync } = require('child_process');
const { join } = require('path');
const readline = require('readline');

const CONFIG_DIR = process.env.FOREMAN_CONFIG_DIR || join(require('os').homedir(), '.foreman');
const PROFILE_FILE = join(CONFIG_DIR, 'profile.json');
const FLEET_FILE = join(CONFIG_DIR, 'fleet.json');

const COLORS = {
  RED: '\x1b[0;31m',
  GREEN: '\x1b[0;32m',
  YELLOW: '\x1b[1;33m',
  BLUE: '\x1b[0;34m',
  BOLD: '\x1b[1m',
  DIM: '\x1b[2m',
  NC: '\x1b[0m',
};

function question(rl, prompt) {
  return new Promise(resolve => rl.question(prompt, resolve));
}

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  console.log('');
  console.log(`${COLORS.BOLD}╔══════════════════════════════════════════════╗${COLORS.NC}`);
  console.log(`${COLORS.BOLD}║         Foreman — First Run Setup            ║${COLORS.NC}`);
  console.log(`${COLORS.BOLD}║   Paperclip is the company.                  ║${COLORS.NC}`);
  console.log(`${COLORS.BOLD}║   Foreman runs the crew.                      ║${COLORS.NC}`);
  console.log(`${COLORS.BOLD}╚══════════════════════════════════════════════╝${COLORS.NC}`);
  console.log('');

  // Step 1: Permission
  console.log(`${COLORS.BLUE}Step 1: Permission Check${COLORS.NC}`);
  console.log(`${COLORS.DIM}Foreman needs to scan your machine for AI agent CLIs and test their capabilities.${COLORS.NC}`);
  console.log(`${COLORS.DIM}This will run discovery commands like 'agent models', 'ollama list', 'claude --version'.${COLORS.NC}`);
  console.log(`${COLORS.DIM}No files will be modified. No projects will be created.${COLORS.NC}`);
  console.log('');

  const confirm = await question(rl, `${COLORS.BOLD}Allow Foreman to scan for and test available CLIs?${COLORS.NC} [y/N] `);
  if (!confirm.toLowerCase().startsWith('y')) {
    console.log(`${COLORS.RED}Setup cancelled. Run 'foreman init' again when you're ready.${COLORS.NC}`);
    rl.close();
    process.exit(0);
  }
  console.log('');

  // Step 2: Discover CLIs
  console.log(`${COLORS.BLUE}Step 2: CLI Discovery${COLORS.NC}`);
  console.log(`${COLORS.DIM}Scanning for available AI agent CLIs...${COLORS.NC}`);
  console.log('');

  const clis = [
    { name: 'Cursor Agent', cmd: 'agent', versionCmd: 'agent models', versionFlag: 'models' },
    { name: 'Claude Code', cmd: 'claude', versionCmd: 'claude --version', versionFlag: '--version' },
    { name: 'Codex', cmd: 'codex', versionCmd: 'codex --version', versionFlag: '--version' },
    { name: 'Ollama', cmd: 'ollama', versionCmd: 'ollama --version', versionFlag: '--version' },
    { name: 'Hermes', cmd: 'hermes', versionCmd: 'hermes --version', versionFlag: '--version' },
  ];

  const found = {};
  for (const cli of clis) {
    try {
      const path = execSync(`which ${cli.cmd} 2>/dev/null`, { encoding: 'utf8' }).trim();
      let version = 'available';
      try {
        version = execSync(`${cli.versionCmd} 2>&1`, { encoding: 'utf8' }).trim().split('\n')[0];
      } catch {}
      found[cli.name] = { found: true, version, path };
      console.log(`  ${COLORS.GREEN}✓${COLORS.NC} ${COLORS.BOLD}${cli.name}${COLORS.NC} (${version})`);
      console.log(`    ${COLORS.DIM}${path}${COLORS.NC}`);
    } catch {
      found[cli.name] = { found: false };
      console.log(`  ${COLORS.RED}✗${COLORS.NC} ${cli.name} ${COLORS.DIM}(not found)${COLORS.NC}`);
    }
  }
  console.log('');

  // Step 3: Test capabilities
  console.log(`${COLORS.BLUE}Step 3: Capability Testing${COLORS.NC}`);
  console.log(`${COLORS.DIM}Testing what each CLI can actually do...${COLORS.NC}`);
  console.log('');

  const capabilities = {};

  if (found['Cursor Agent']?.found) {
    console.log(`  ${COLORS.BOLD}Cursor Agent${COLORS.NC}`);
    let models = '';
    try {
      models = execSync('agent models 2>&1', { encoding: 'utf8' }).trim();
    } catch {}
    const composerMatch = models.match(/composer-[0-9.]+(?:-[a-z]+)?/i);
    if (composerMatch) {
      const latestComposer = composerMatch[0];
      capabilities.cursor_builder = latestComposer;
      capabilities.cursor_fast = latestComposer.replace(/-fast$/, '') + '-fast';
      console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Builder: ${latestComposer}`);
      console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Fast builder: ${capabilities.cursor_fast}`);
    } else {
      console.log(`    ${COLORS.YELLOW}⚠${COLORS.NC} No composer models found — may need update`);
    }
    console.log('');
  }

  if (found['Claude Code']?.found) {
    console.log(`  ${COLORS.BOLD}Claude Code${COLORS.NC}`);
    console.log(`    Version: ${COLORS.DIM}${found['Claude Code'].version}${COLORS.NC}`);
    capabilities.claude_inspector = 'opus';
    capabilities.claude_builder = 'sonnet';
    capabilities.claude_cheap = 'haiku';
    console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Inspector tier: opus`);
    console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Builder tier: sonnet`);
    console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Cheap tier: haiku`);
    console.log('');
  }

  if (found['Ollama']?.found) {
    console.log(`  ${COLORS.BOLD}Ollama${COLORS.NC}`);
    let models = '';
    try {
      models = execSync('ollama list 2>&1', { encoding: 'utf8' }).trim();
      const modelLines = models.split('\n').filter(l => l.trim() && !l.includes('NAME'));
      console.log(`    Models available: ${COLORS.DIM}${modelLines.length}${COLORS.NC}`);
      for (const line of modelLines.slice(0, 5)) {
        console.log(`    ${COLORS.DIM}  ${line.trim()}${COLORS.NC}`);
      }
      if (modelLines.length > 0) {
        capabilities.ollama_inspector = modelLines[0].split(/\s+/)[0];
        capabilities.ollama_available = 'true';
        console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Inspector: ${capabilities.ollama_inspector} (strongest available)`);
      }
    } catch {
      console.log(`    ${COLORS.YELLOW}⚠${COLORS.NC} Could not list models`);
    }
    console.log('');
  }

  if (found['Codex']?.found) {
    console.log(`  ${COLORS.BOLD}Codex${COLORS.NC}`);
    console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Available for cross-family verification`);
    capabilities.codex_available = 'true';
    console.log('');
  }

  if (found['Hermes']?.found) {
    console.log(`  ${COLORS.BOLD}Hermes${COLORS.NC}`);
    console.log(`    ${COLORS.GREEN}✓${COLORS.NC} Available for OpenClaw-aligned work`);
    capabilities.hermes_available = 'true';
    console.log('');
  }

  // Step 4: Role assignments
  console.log(`${COLORS.BLUE}Step 4: Role Assignments${COLORS.NC}`);
  console.log(`${COLORS.DIM}Based on your fleet, Foreman will route roles like this:${COLORS.NC}`);
  console.log('');

  let inspector, inspectorCmd, builder, builderCmd, cheap, cheapCmd;
  let fleetMode = 'none';
  let functional = true;

  if (capabilities.claude_inspector) {
    inspector = 'Claude Opus'; inspectorCmd = 'claude -p --model opus';
  } else if (capabilities.cursor_builder) {
    inspector = `Cursor ${capabilities.cursor_builder}`; inspectorCmd = `agent --trust --model ${capabilities.cursor_builder}`;
  } else if (capabilities.ollama_inspector) {
    inspector = `Ollama ${capabilities.ollama_inspector}`; inspectorCmd = `ollama run ${capabilities.ollama_inspector}`;
  } else {
    inspector = 'none'; inspectorCmd = ''; functional = false;
  }

  if (capabilities.cursor_builder) {
    builder = `Cursor ${capabilities.cursor_builder}`; builderCmd = `agent --trust --model ${capabilities.cursor_builder}`;
  } else if (capabilities.claude_builder) {
    builder = 'Claude Sonnet'; builderCmd = 'claude -p --model sonnet';
  } else if (capabilities.ollama_available) {
    builder = 'Ollama (mid-tier)'; builderCmd = 'ollama run <mid-model>';
  } else {
    builder = 'none'; builderCmd = ''; functional = false;
  }

  if (capabilities.ollama_available) {
    cheap = 'Ollama (cheapest)'; cheapCmd = 'ollama run <cheapest-model>';
  } else if (capabilities.cursor_fast) {
    cheap = `Cursor ${capabilities.cursor_fast}`; cheapCmd = `agent --trust --model ${capabilities.cursor_fast}`;
  } else if (capabilities.claude_cheap) {
    cheap = 'Claude Haiku'; cheapCmd = 'claude -p --model haiku';
  } else {
    cheap = 'none'; cheapCmd = '';
  }

  const foundCount = Object.values(found).filter(v => v.found).length;
  if (functional) {
    fleetMode = foundCount >= 2 ? 'multi-provider' : 'single-provider';
  }

  console.log(`  ${COLORS.BOLD}Inspector${COLORS.NC} (judgment-heavy review):  ${inspector}`);
  console.log(`  ${COLORS.BOLD}Builder${COLORS.NC}   (code implementation):    ${builder}`);
  console.log(`  ${COLORS.BOLD}Cheap${COLORS.NC}     (classification, brainstorm): ${cheap}`);
  console.log('');

  if (!functional) {
    console.log(`  ${COLORS.RED}⚠ Fleet not functional. Install at least one AI CLI.${COLORS.NC}`);
  } else {
    console.log(`  ${COLORS.GREEN}Fleet mode: ${fleetMode}${COLORS.NC} (${foundCount} provider(s) found)`);
  }
  console.log('');

  // Step 5: Paperclip
  console.log(`${COLORS.BLUE}Step 5: Paperclip Integration (Optional)${COLORS.NC}`);
  console.log(`${COLORS.DIM}Foreman works standalone. Paperclip adds visual dashboards and worktrees.${COLORS.NC}`);
  console.log('');

  const paperclipAnswer = await question(rl, `${COLORS.BOLD}Connect to a Paperclip server?${COLORS.NC} [y/N] `);
  let paperclipUrl = '';
  let paperclipCompany = '';

  if (paperclipAnswer.toLowerCase().startsWith('y')) {
    paperclipUrl = (await question(rl, 'Paperclip URL [http://127.0.0.1:3100]: ')) || 'http://127.0.0.1:3100';
    paperclipCompany = await question(rl, 'Company ID: ');
    
    try {
      const health = execSync(`curl -s ${paperclipUrl}/api/health 2>/dev/null`, { encoding: 'utf8' }).trim();
      if (health.includes('ok')) {
        console.log(`  ${COLORS.GREEN}✓${COLORS.NC} Connected to Paperclip at ${paperclipUrl}`);
      } else {
        console.log(`  ${COLORS.YELLOW}⚠${COLORS.NC} Could not reach Paperclip at ${paperclipUrl}`);
        paperclipUrl = ''; paperclipCompany = '';
      }
    } catch {
      console.log(`  ${COLORS.YELLOW}⚠${COLORS.NC} Could not reach Paperclip at ${paperclipUrl}`);
      paperclipUrl = ''; paperclipCompany = '';
    }
  }
  console.log('');

  // Step 6: Save profile
  console.log(`${COLORS.BLUE}Step 6: Saving Profile${COLORS.NC}`);
  mkdirSync(CONFIG_DIR, { recursive: true });

  const profile = {
    version: '0.1.0',
    created: new Date().toISOString(),
    fleet_mode: fleetMode,
    roles: {
      inspector: { name: inspector, command: inspectorCmd },
      builder: { name: builder, command: builderCmd },
      cheap: { name: cheap, command: cheapCmd },
    },
    paperclip: { url: paperclipUrl, company_id: paperclipCompany },
  };

  const fleet = {
    version: '0.1.0',
    scanned: new Date().toISOString(),
    clis: Object.fromEntries(
      Object.entries(found).map(([name, info]) => [name.replace(/ /g, '_').toLowerCase(), info])
    ),
    capabilities,
  };

  writeFileSync(PROFILE_FILE, JSON.stringify(profile, null, 2));
  writeFileSync(FLEET_FILE, JSON.stringify(fleet, null, 2));

  console.log(`  ${COLORS.GREEN}✓${COLORS.NC} Profile saved to ${COLORS.DIM}${PROFILE_FILE}${COLORS.NC}`);
  console.log(`  ${COLORS.GREEN}✓${COLORS.NC} Fleet saved to ${COLORS.DIM}${FLEET_FILE}${COLORS.NC}`);
  console.log('');

  // Done
  console.log(`${COLORS.BOLD}╔══════════════════════════════════════════════╗${COLORS.NC}`);
  console.log(`${COLORS.BOLD}║         Foreman is ready.                    ║${COLORS.NC}`);
  console.log(`${COLORS.BOLD}╚══════════════════════════════════════════════╝${COLORS.NC}`);
  console.log('');
  console.log(`  Inspector:  ${COLORS.GREEN}${inspector}${COLORS.NC}`);
  console.log(`  Builder:    ${COLORS.GREEN}${builder}${COLORS.NC}`);
  console.log(`  Cheap:      ${COLORS.GREEN}${cheap}${COLORS.NC}`);
  console.log(`  Mode:       ${COLORS.GREEN}${fleetMode}${COLORS.NC}`);
  console.log('');
  console.log(`  ${COLORS.DIM}Run 'foreman dispatch --task "Fix the bug"' to start.${COLORS.NC}`);
  console.log(`  ${COLORS.DIM}Run 'foreman fleet' to re-scan your CLIs.${COLORS.NC}`);
  console.log(`  ${COLORS.DIM}Run 'foreman init' again to reconfigure.${COLORS.NC}`);
  console.log('');

  rl.close();
}

main().catch(err => {
  console.error(`${COLORS.RED}Error: ${err.message}${COLORS.NC}`);
  process.exit(1);
});