# Foreman Company Builder — Student Kit

Build a small agent company around work you already have. One Foreman coordinates the work, a Builder produces it, and an Inspector checks it against an agreed finish line.

**Version:** 0.1.0-preview.1 — course preview. These are portable instructions and editable templates. They do not install an agent runtime, create bots, or supply paid services or account access.

Maintained source: [FuFicFac/foreman-company-builder](https://github.com/FuFicFac/foreman-company-builder). This kit accompanies AI Matters to You's *Building with Astra: Ideas to Media Projects* course, Lesson 1. The ZIP is a versioned snapshot; your edited copy will not automatically update when GitHub changes.

## Start here

1. Unzip the download. Keep the original ZIP and copy `company-template` into a new folder named for your company. Preserve any existing project files.
2. Open that folder in an AI workspace you already use, or attach all six Markdown files to a conversation. See [runtime setup](RUNTIMES.md) for what this does and does not configure.
3. Fill in `COMPANY.md` with your audience, intended output, existing assets, and boundaries. Replace the `{{...}}` fields in `PROJECT.md` and `TASK.md` as you agree on one pilot. Do not invent missing facts to fill a box.
4. Ask the assistant to read all six files and use `SKILL.md` as its Foreman operating instructions. It must report which files it could actually read. Merely putting files in a folder does not guarantee an assistant will load them.
5. Start with this message:

   > Act as Foreman for this company. Read the six company files. Tell me what already exists, what stage we are at, and the smallest useful pilot. Use my stated objective if it is already clear; ask only for information that changes the work. Show the proposed finish line and first task. Do not create standing bots or publish anything from this setup request.

6. Follow the [agent protocol](PROTOCOL.md). Give a bounded task to a Builder. Have a separate Inspector examine the output and evidence. Foreman accepts it, assigns a correction, or reports a blocker. If you have only one conversation, use the manual review procedure below.

The first successful run should leave you with an artifact you can open, a record of its checks, and a clear next step. A plan or an agent's claim of success is not evidence that the artifact works.

## What each file does

| File | Purpose |
|---|---|
| `COMPANY.md` | Company purpose, audience, current assets, and limits |
| `TEAM.md` | Foreman, Builder, Inspector, and optional supporting roles |
| `AGENTS.md` | Shared working rules, ownership boundaries, and handoffs |
| `PROJECT.md` | One project's current state and definition of done |
| `TASK.md` | One bounded assignment and its evidence record |
| `SKILL.md` | Foreman's charter and operating procedure |

Keep these files together so their relative references continue to work. Copy `TASK.md` for later assignments rather than replacing the evidence from completed work.

## Try the course example

Read [the archive pilot](examples/archive-pilot/README.md). It uses a fictional archive and produces a pilot brief and sample script. It does not presume you have the instructor's tools, integrations, footage, or company data.

## Review with one account

You do not need a permanent roster of bots. You can perform the Builder and Inspector steps in separate conversations on one existing account, or have a person inspect the result. Give the Inspector the task, acceptance criteria, source material, artifact, and check results; ask it to examine them itself. Different conversations reduce shared context but do not guarantee independent judgment.

If the same conversation performs both steps, label the result **self-review**, not independent inspection. Foreman must disclose that limitation and leave any required independent acceptance pending.

## Before calling the pilot complete

- The requested files exist and open from the reported paths.
- Every acceptance criterion has evidence or is explicitly marked unverified.
- The Inspector's verdict names defects and the checks actually performed.
- Foreman's closeout names the output, verification, unresolved limitations, and next action.
- Any action requiring authorization has either been authorized and verified or remains clearly pending.

This preview was checked for package contents and document consistency. Runtime-specific installation and unattended multi-agent operation are not certified by this download. See [runtime setup](RUNTIMES.md).
