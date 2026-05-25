# Resolution Heartbeat and Office Hours

Foreman should not merely show that work is stuck. Foreman should keep the company moving until stuck work is resolved, escalated, or deliberately deferred.

Paperclip is optional visibility. Foreman owns follow-through.

```text
Paperclip shows the queue.
Foreman drains the queue.
Office hours protect the person.
```

## Product Promise

A human should not have to install or open Paperclip just to keep an agent company from leaving work in review.

Paperclip is the cockpit: useful for visibility, debugging, manual overrides, and watching execution. Foreman is the accountability layer: it inspects queues, retries safe failures, verifies completed work, and escalates only the things that truly need the owner.

The promise is not "humans are never needed." The promise is:

> Foreman minimizes human review to true judgment calls.

## Resolution Heartbeat

A normal heartbeat asks whether the system is alive.

A Foreman resolution heartbeat asks:

- What is stuck?
- Can Foreman safely fix it?
- Can Foreman retry it?
- Does it need another agent?
- Does it need a tool repair?
- Does it truly need human judgment?
- If it needs the human, when and how should they be interrupted?

The heartbeat should inspect every company queue:

- review
- approval
- blocked
- failed
- stale
- waiting on human
- waiting on agent
- waiting on tool
- customer support
- launch/deadline critical paths

Then it should classify each item and act.

### Classifications

```text
auto_resolve
safe_retry
needs_context
needs_tool_repair
needs_agent_review
needs_human_judgment
critical_escalation
hold_until_office_hours
```

### Actions

Foreman may:

- retry safe failed work;
- spawn an inspector/checker;
- ask a narrow human question when policy allows;
- requeue stale work;
- close false blockers;
- create follow-up tasks;
- repair or request missing tools;
- escalate critical issues immediately;
- defer noncritical interruptions until office hours.

A good heartbeat report should not say, "There are nine things in review."

It should say, "I found nine review items, resolved five, requeued one, escalated two, and one needs your actual decision."

## Office Hours

Foreman companies need humane operating schedules.

Some companies are genuinely 24/7. A support or incident-response company may need to watch every hour. But an author, course creator, or small publishing operation should not be woken up because an agent finished a metadata pass at 2:17 AM.

Foreman must separate four concepts:

1. **Work execution** — whether agents may keep working.
2. **Human interruption** — whether the owner may be pinged.
3. **Reporting** — whether updates are sent now or batched.
4. **Emergency escalation** — what breaks quiet hours.

## Schedule Modes

### Always Open

For support desks, launches, incidents, commerce, or any company that must operate 24/7.

```yaml
office_hours:
  mode: always_open
heartbeat:
  all_hours: every 15m
interruptions:
  all_hours: [urgent, critical]
```

### Calm Mode

For authors, creators, and normal operating companies.

```yaml
office_hours:
  timezone: America/Los_Angeles
  days: [Mon, Tue, Wed, Thu, Fri]
  start: "09:30"
  end: "16:30"
heartbeat:
  office_hours: every 20m
  off_hours: every 4h
  weekends: daily at 10:00
interruptions:
  office_hours: [normal, urgent, critical]
  off_hours: [critical]
  hold_noncritical_until_next_window: true
  morning_digest: true
```

### Launch Mode

For temporary high-alert windows.

```yaml
office_hours:
  mode: launch_window
  start: "2026-06-01T08:00:00-07:00"
  end: "2026-06-08T18:00:00-07:00"
heartbeat:
  launch_window: every 10m
  otherwise: every 30m
interruptions:
  launch_window: [urgent, critical]
  otherwise: [critical]
```

### Vacation Mode

For maximum quiet.

```yaml
office_hours:
  mode: vacation
heartbeat:
  off_hours: daily at 10:00
interruptions:
  all_hours: [critical]
automation:
  allow_safe_resolutions: true
  defer_human_questions: true
```

## Severity Levels

### Quiet

Do not ping the human.

Examples:

- routine task completed;
- metadata suggestion generated;
- nonblocking report updated;
- agent wants a preference but can continue with defaults.

Action: log, queue, and include in the next digest.

### Normal

Tell the human during the next office-hours heartbeat.

Examples:

- manuscript preference needed;
- blurb direction needs approval;
- a noncritical review item appeared;
- an agent requests a routine decision.

Action: hold until office hours.

### Urgent

Interrupt during office hours. Off-hours behavior is configurable.

Examples:

- scheduled newsletter failed;
- launch checklist has a blocker;
- store upload did not complete;
- support request is aging but not yet harmful.

Action: ping during office hours; off-hours hold unless company policy permits urgent alerts.

### Critical

Wake the human anytime.

Examples:

- customer cannot access a paid file;
- refund/payment problem needs immediate action;
- public site is down during launch;
- email campaign is sending broken links;
- private data is exposed;
- runaway spend or security incident.

Action: immediate escalation through configured channels.

## Escalation Channels

Foreman should support user-configurable escalation channels, from subtle to impossible to miss:

- Telegram/Discord/SMS;
- email;
- phone/push notification;
- Paperclip alert;
- smart-home signal such as HomeKit/Home Assistant lights;
- custom webhook.

Example:

```yaml
escalation_channels:
  critical:
    - telegram
    - sms
    - homeassistant:light.office_red
  urgent:
    - telegram
  normal:
    - morning_digest
```

A red light in the house is not a joke. It is a legitimate escalation interface if the human wants it.

## Company-Level Policy

Office hours are per company, not only global.

A publishing company may be quiet overnight. A customer support company may be always open. A launch company may temporarily enter launch mode. A software incident company may escalate 24/7.

Suggested company policy object:

```json
{
  "heartbeat_policy": {
    "office_hours": {
      "timezone": "America/Los_Angeles",
      "days": ["Mon", "Tue", "Wed", "Thu", "Fri"],
      "start": "09:30",
      "end": "16:30"
    },
    "frequency": {
      "office_hours": "every 20m",
      "off_hours": "every 4h"
    },
    "interruptions": {
      "office_hours": ["normal", "urgent", "critical"],
      "off_hours": ["critical"]
    },
    "digests": {
      "morning": true,
      "overnight": true
    }
  }
}
```

## Publishing Company Defaults

For a Personal Publishing House / author company, default to quality-of-life preservation:

- frequent heartbeat during office hours;
- off-hours quiet unless critical;
- overnight work may continue if safe;
- noncritical reports wait until morning;
- customer access/payment/refund issues can escalate immediately;
- launch weeks can temporarily increase sensitivity.

Example critical support event:

> A reader bought a book from the author's website, but the EPUB file appears corrupted and will not open on Kindle. They request a refund or a working file.

Foreman should treat this as critical because money, customer trust, and delivery failure are involved. It should try safe remediation first if allowed — verify the file, locate an alternate format, prepare a replacement link, draft the support reply — then escalate clearly.

## Implementation Notes

The resolution heartbeat can run on Hermes cron without requiring Paperclip.

Paperclip integration should expose the same state visually, but Foreman must be able to operate headlessly:

```text
Hermes cron → Foreman resolution heartbeat → queue inspection → safe action → escalation/digest
```

If Paperclip is present, Foreman reads and writes queue state through the adapter. If Paperclip is absent, Foreman uses local project/company state files and still produces reports.

## Non-Goals

- Do not spam the human with every agent update.
- Do not wake the human for routine creative preferences.
- Do not let agents perform destructive, public, financial, or reputation-sensitive actions without the company policy explicitly allowing it.
- Do not make Paperclip mandatory for users who only want outcomes.

## Design Rule

Foreman keeps the company alive without making the human live inside the company.
