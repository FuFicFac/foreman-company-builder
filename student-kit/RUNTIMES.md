# Using the kit in your AI workspace

The kit supplies Markdown instructions. Your existing AI product supplies the model, file access, tools, and any task delegation. No runtime is bundled or automatically configured.

## A conversation with attachments

Attach all six files from your working company folder, plus the source material needed for the pilot. Ask the assistant to identify which files it can read and follow `SKILL.md`. After each milestone, save the returned artifacts and updated project/task records yourself if the assistant cannot write to your folder.

For a separate Inspector pass, open a new conversation with the task, source evidence, artifact, and the protocol. This can be a manual handoff; automatic agent-to-agent communication is not required.

## A local agent workspace

Open your copied company folder in the agent workspace. Explicitly ask it to read all six files. Confirm that its reported paths are real and that it can write only where intended. If your tool has a documented way to install skills or project instructions, you may use that mechanism, but do not assume a folder named `company-template` installs itself.

The `SKILL.md` file includes a conventional name and description header for tools that support that format. This download does not certify a particular host's skill discovery or installation behavior.

## Mapping the same instructions to other hosts

| Host style | Put the instructions here | Confirm before work |
|---|---|---|
| Hosted bot, including Grok Bot | The host's supported instructions and knowledge attachments | It can read the uploaded current files; local Mac paths are not cloud attachments |
| Local engine, including Hermes | The host's supported workspace and skill mechanism | File access, available tools, and whether delegation is enabled |
| Team room, including Buzz | The host's supported agent instructions and shared context | Which agent has which tools and source access; room membership alone is not a security guarantee |

These are conceptual mappings, not tested installation recipes. Use the host's current official documentation for setup. An agent following these instructions cannot grant itself missing filesystem permissions, paid access, integrations, or other agents.

## First-run check

Ask Foreman to name the company, read back the requested pilot, list the six files it read, identify missing source inputs, and describe how inspection will happen. If it cannot establish those facts, fix the setup before assigning production work.
