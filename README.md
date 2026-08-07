# HEIDEE

**Authority:** false  
**Purpose:** Public-safe family continuity surface for Heidee.

---

## JOYSPACE — metadata-driven runtime

`index.html` runs from `metadata.json`.

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

### Public pages

- `index.html` — HEIDEE JOY runtime
- `joy-ai.html` — optional already-installed on-device AI helper + deterministic local fallback
- `parents.html` — **JoySpace Formal Verification for Parents Who Just Want the Kids to Be Safe (and Maybe Have a Little Fun)**

### JOY gate

```text
PLAY → BUILD → TEST → RESULT → REFLECT → DID I ENJOY THAT?
                                                │
                           NO → preserve + stop │ YES
                                                ↓
                                      🟢 EASY BUTTON
                                      GENERATE MY STORY
```

The reward is ownership of the reflection, not points.

### JOY_NETWORK_BOUNDARY_V1

```text
DEFAULT = DENY
ALLOWED_RUNTIME_READS = [
  "./metadata.json",
  "./fixtures/instrument.blank.json"
]
UNKNOWN NETWORK CAPABILITY = VALIDATION FAILURE
NEW RUNTIME RESOURCE = EXPLICIT METADATA DECLARATION REQUIRED
```

`tools/validate-runtime.mjs` is the tracked validator. It checks metadata invariants, declared reads, common browser network/resource escape paths, JOY AI's no-download gate, and receipt parity.

The validator is a **strong static boundary**, not a claim of exhaustive information-flow proof, model checking, or theorem-prover certification.

### JOY AI

JOY AI never auto-sends family words. It only creates a browser language-model session when `LanguageModel.availability()` reports the model is already `available`; it does not intentionally trigger a model download. Otherwise it uses the deterministic local JOY spark helper.

### Receipt

`schema/joy_receipt.schema.json` defines `JOY_RECEIPT` with:

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

## Public-safe boundary

No private family data. No secrets. No phone numbers, addresses, birthdates, private identifiers, passwords, or sensitive records.

JOY & Family choose the meaning. The schema only makes the choice replayable.

**Authority false. PR #2 remains a draft until an explicit merge decision.**
