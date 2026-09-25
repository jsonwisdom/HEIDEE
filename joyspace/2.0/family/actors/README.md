# HEIDEE Family Actors — Replay Cast

This directory defines reusable family **replay actors/characters** for future JoySpace scenes.

Actors are presentation and routing objects. They do not create identity, genealogy, consent, custody, biography, employment, military status, or family authority.

## Current cast

Current actor replay: `family_actors_v0_3.json`.

History remains readable:

- `family_actors_v0_1.json` — initial replay cast
- `family_actors_v0_2.json` — prior state with `MRS_WISDOM` and `MS_WISDOM` represented separately
- `family_actors_v0_3.json` — current state: `MS_WISDOM` is a variant of canonical `MRS_WISDOM`; the earlier split remains replay history

```text
CURRENT CANONICAL FAMILY ACTOR NODES = 11
MRS_WISDOM VARIANTS = [MS_WISDOM]
VARIANT != SECOND_PERSON_BY_DEFAULT
HISTORICAL_CONFLICT != CURRENT_IDENTITY_SPLIT
```

## Actor classes

- `FAMILY_NODE_ACTOR` — a replay character bound only to a declared/protected family node.
- `SYNTHETIC_REPLAY_ACTOR` — a system/story helper such as Ziggy, Gray Baby, or LeahPrime.
- `IDENTITY_VARIANT` — alternate label carried by a canonical family actor; it is not a second actor/person by default.

## Core law

```text
ACTOR_CARD != PERSON_PROOF
ACTOR_ROLE != RELATIONSHIP_EDGE
ACTOR_RELATIONSHIP_REF != VERIFIED_GENEALOGY
STORY_VOICE != REAL_PERSON_QUOTE
FAMILY_CONTEXT != PUBLIC_IDENTITY_BINDING
SYNTHETIC_ACTOR != FAMILY_MEMBER
VARIANT_ACTOR != SECOND_PERSON
```

Relationship references may point only to versioned relationship-claim objects. A future replay may display a declared relationship but may not promote it.

## Directories-first replay order

```text
USER WORD / SOURCE / DECLARATION
        ↓
DIRECTORY + LINEAGE LOOKUP
        ↓
CURRENT RELATIONSHIP LEDGER
        ↓
HEIDEE FAMILY MATH
        ↓
ACTOR CARD
        ↓
SCENE / STORY / GAME
        ↓
ZIGGY GAP CHECK
        ↓
PRIVACY / ROOM-SAFETY CHECK
        ↓
RECEIPT / REPLAY
```

```text
WORD = PATH_TOKEN
REPEATED_WORD = INCREASE_LOOKUP_DEPTH
VARIANT = CHECK_LINEAGE_BEFORE_NEW_NODE
```

`new_family_created=false`  
`relationship_verification_performed=false`  
`authority_created=false`
