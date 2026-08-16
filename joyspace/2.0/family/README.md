# Heidee's Family — Typed Layer

This directory stores versioned family claims without collapsing role, position, identity, or kinship.

## Current family replay

- `relationship_claims_v0_1.json` — preserved HEIDEE/AUNT_RANN HOLD fixture
- `relationship_claims_v0_2.json` — JoySpace for Families declared-edge ledger
- `family_math_v0_2.json` — preserved role/position/kinship separation
- `family_math_v0_3.json` — HEIDEE child-safe second-pass rules

## Types

- `ROLE_CARD` = functional/play role
- `PORCH_NODE` = structural position
- `RELATIONSHIP_CLAIM` = asserted relationship edge with independent evidence class and relationship state
- `PROTECTED_GAP` = intentionally unspecified relationship; no predicate is manufactured

## HEIDEE double-check

HEIDEE does not decide genealogy. HEIDEE checks that the family replay stays child-safe and typed:

```text
EVIDENCE_CLASS != RELATIONSHIP_STATE
EDGE_EXISTS != RELATIONSHIP_VERIFIED
USER_DECLARED_EDGE != VERIFIED_GENEALOGY
SHARED_CHILD != ADULT_RELATIONSHIP
ROLE_CARD != GENEALOGY_PROOF
PORCH_POSITION != KINSHIP
EDGE_PROMOTION_IS_LOCAL_ONLY
```

Identity guards remain explicit:

```text
LEEANN != LEANNE unless explicitly bound
BOSSBRE != BRE unless explicitly bound
LEEANN family node != LEEANN H. CHAVERS public person unless identity binding is established
```

A relationship object may exist while verification remains false. Family display, privacy, consent, and public release are separate gates.

`new_family_created=false`  
`authority_created=false`
