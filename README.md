# HEIDEE

**Authority:** false  
**Purpose:** Public-safe family continuity surface for Heidee.

---

## JOYSPACE — metadata-driven runtime

`index.html` now runs from `metadata.json`.

Family relationship:

```text
JSON
  ↓ enables structure / fixtures / receipts
HEIDEE JOY
  ↓ chooses meaning with family
ATOMIC FAMILY INSTRUMENTS
  ↓ instrument of what?
JOY & FAMILY DECIDE
```

The metadata enables capabilities. It does **not** preassign meaning to the family's instruments.

The shipped fixture is intentionally blank: `fixtures/instrument.blank.json`.

### JOY gate

```text
PLAY → BUILD → TEST → RESULT → REFLECT → DID I ENJOY THAT?
                                                │
                           NO → preserve + stop │ YES
                                                ↓
                                      🟢 EASY BUTTON
                                      GENERATE MY STORY
```

Story lanes:

- WHAT I TRIED
- WHAT I DISCOVERED
- WHAT I BUILT
- WHAT MADE IT MINE

The reward is ownership of the reflection, not points.

### JOY AI

`joy-ai.html` is an alternative family-safe creative surface.

- optional on-device browser AI when available
- deterministic local JOY spark fallback when it is not
- no API key in the repo
- no automatic external sending
- no scoring, ranking, diagnosis, or authority claims
- AI suggestions cannot overwrite family words
- local browser storage only by default

### Receipt

`schema/joy_receipt.schema.json` defines the lightweight `JOY_RECEIPT`:

```text
session_id
fixtures_used
things_created
results_rendered
story_version
owner
anchor_optional
```

---

## Relationship Map

```json
{
  "repo": "jsonwisdom/HEIDEE",
  "local_surface": "HEIDEE JOY",
  "parent_layer": "JSON",
  "pattern_library": "jsonwisdom/JOY",
  "bounded_by": "jsonwisdom/AL",
  "coordinated_by": "jsonwisdom/COMPUTERWISDOM",
  "authority": false
}
```

---

## Public-safe boundary

No private family data.  
No secrets.  
No phone numbers, addresses, birthdates, private identifiers, passwords, or sensitive records.

JOY & Family choose the meaning. The schema only makes the choice replayable.

**Authority false.**
