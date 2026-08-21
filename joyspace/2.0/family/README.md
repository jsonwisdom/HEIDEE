# Heidee's Family — Typed Layer

This directory stores versioned family claims and replay actors without collapsing role, position, identity, kinship, consent, or story voice.

## Rule 01 — directories first

Project/family vocabulary is navigational state.

```text
DIRECTORIES_FIRST
WORD = PATH_TOKEN
REPEATED_WORD = INCREASE_LOOKUP_DEPTH
VARIANT = CHECK_LINEAGE_BEFORE_NEW_NODE
KNOWN_TERM = REPLAY_EXISTING_SEMANTICS_THEN_APPLY_DELTA
```

A new family node, role layer, parental abstraction, or actor must not be invented until the existing directory/ledger lineage has been checked.

## Current family replay

- `relationship_claims_v0_1.json` — preserved HEIDEE/AUNT_RANN HOLD fixture
- `relationship_claims_v0_2.json` — JoySpace for Families declared-edge ledger
- `relationship_claims_v0_3.json` — preserved prior registry state, including the historical `MRS_WISDOM != MS_WISDOM` split
- `relationship_claims_v0_4.json` — current replay: `MS_WISDOM` is a variant of `MRS_WISDOM`, not a separately inferred person; v0.3 conflict remains visible
- `family_math_v0_2.json` — preserved role/position/kinship separation
- `family_math_v0_3.json` — HEIDEE child-safe second-pass rules
- `actors/README.md` — actor/character boundary
- `actors/family_actors_v0_1.json` — preserved actor history
- `actors/family_actors_v0_2.json` — preserved prior separate-node actor state
- `actors/family_actors_v0_3.json` — current actor replay with `MS_WISDOM` as a variant of `MRS_WISDOM`

## Current identity/variant posture

```text
CANONICAL FAMILY NODES = 11
MRS_WISDOM = CANONICAL NODE
MS_WISDOM = USER-DIRECTED VARIANT
MRS_WISDOM != MS_WISDOM = PRESERVED HISTORICAL CONFLICT, NOT CURRENT IDENTITY SPLIT
```

Other user-directed resolutions remain:

```text
LEEANN -> LEANNE
BE -> BRAE
BOSSBRE -> BRE
```

Resolution is local to identity labels. It does not automatically create or verify relationship edges.

## Types

- `ROLE_CARD` = functional/play role
- `PORCH_NODE` = structural position
- `RELATIONSHIP_CLAIM` = asserted relationship edge with independent evidence class and relationship state
- `PROTECTED_GAP` = intentionally unspecified relationship; no predicate is manufactured
- `FAMILY_NODE_ACTOR` = a replay character bound only to an existing family node and versioned relationship references
- `SYNTHETIC_REPLAY_ACTOR` = a non-family helper such as Ziggy, Gray Baby, or LeahPrime
- `IDENTITY_VARIANT` = another label for a canonical node; not a second person by default

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
ACTOR_CARD != PERSON_PROOF
ACTOR_ROLE != RELATIONSHIP_EDGE
STORY_VOICE != REAL_PERSON_QUOTE
SYNTHETIC_ACTOR != FAMILY_MEMBER
VARIANT != SECOND_PERSON_BY_DEFAULT
HISTORICAL_CONFLICT != CURRENT_IDENTITY_SPLIT
```

Identity guards remain explicit:

```text
LEEANN -> LEANNE only by the recorded user-directed alias resolution
BOSSBRE -> BRE only by the recorded user-directed alias resolution
MS_WISDOM -> MRS_WISDOM by the current user-directed variant resolution
LEEANN family node != LEEANN H. CHAVERS public person unless identity binding is established
```

A relationship object may exist while verification remains false. An actor may exist while identity, genealogy, and public biography remain unverified. Family display, privacy, consent, and public release are separate gates.

`new_family_created=false`  
`relationship_verification_performed=false`  
`authority_created=false`
