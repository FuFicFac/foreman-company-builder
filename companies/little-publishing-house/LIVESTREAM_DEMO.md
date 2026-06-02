# Little Publishing House Livestream Demo

Purpose: show Little Publishing House as a tester-ready Foreman company package, not a finished publishing SaaS.

## What to show tomorrow

1. **Position it in one sentence**
   - "Little Publishing House is a publishing-specific Foreman package: a README-first workspace for drafts, assets, heartbeats, and verification."

2. **Create a workspace live**
   ```bash
   ./scripts/foreman lph new /tmp/patreon-pilot \
     --title "Patreon Pilot" \
     --stage "lead magnet" \
     --mode hermes \
     --goal "book project map"
   ```

3. **Open the generated README**
   - Show that the README is the operating brief.
   - Emphasize that Hermes can run from this README, or Paperclip can mirror it as the Kanban/company board.

4. **Show the folder shape**
   - `drafts/`: manuscript/excerpt/notes being developed.
   - `assets/`: cover notes, reference images, source material.
   - `heartbeats/`: updates for patrons/viewers/testers.
   - `outputs/`: project maps, revision plans, metadata packages, launch checklists.
   - `foreman-lph.json`: simple metadata for tools.

5. **Run the health check**
   ```bash
   ./scripts/foreman lph doctor /tmp/patreon-pilot
   ```

6. **Generate a heartbeat**
   ```bash
   ./scripts/foreman lph heartbeat /tmp/patreon-pilot
   ```
   Paste or describe how this becomes the Patreon/Discord/newsletter update.

7. **Show the first-day checklist**
   - `docs/little-publishing-house-first-day-checklist.md`

## What to offer Patreon testers

- Early access to the Little Publishing House package.
- A first-day checklist for setting up one real publishing project.
- A feedback request: where did the README help, where did it need more structure, and what publishing step was missing?
- Permission to use either mode:
  - Hermes-only: run Foreman from the README.
  - Paperclip-assisted: use Paperclip as the external Kanban board.

## What not to overpromise

- Do not call it a finished publishing platform.
- Do not promise Patreon/Substack/Amazon integrations.
- Do not promise automated layout, cover generation, payments, analytics, or scheduling.
- Do not imply Paperclip is required.
- Do not imply Foreman replaces human editorial judgment.

## Close with this ask

"If you want to test this, grab the package, create one Little Publishing House workspace for one real draft, run `doctor`, generate a heartbeat, and tell me where the README stopped being enough."
