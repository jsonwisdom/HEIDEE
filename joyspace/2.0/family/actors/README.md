# HEIDEE Family Actors — Replay Cast v0.1

This directory defines reusable family **replay actors/characters** for future JoySpace scenes.

Actors are presentation and routing objects. They do not create identity, genealogy, consent, custody, biography, employment, military status, or family authority.

## Actor classes

- `FAMILY_NODE_ACTOR` — a replay character bound only to a declared/protected family node.
- `SYNTHETIC_REPLAY_ACTOR` — a system/story helper such as Ziggy, Gray Baby, or LeahPrime.

## Core law

```text
ACTOR_CARD != PERSON_PROOF
ACTOR_ROLE != RELATIONSHIP_EDGE
ACTOR_RELATIONSHIP_REF != VERIFIED_GENEALOGY
STORY_VOICE != REAL_PERSON_QUOTE
FAMILY_CONTEXT != PUBLIC_IDENTITY_BINDING
SYNTHETIC_ACTOR != FAMILY_MEMBER
```

Relationship references may point only to versioned relationship-claim objects. A future replay may display a declared relationship but may not promote it.

## Replay order

```text
SOURCE / USER DECLARATION
        ↓
RELATIONSHIP LEDGER
        ↓
HEIDEE FAMILY MATH
        ↓
ACTOR CARD
        ↓
SCENE / STORY / GAME
        ↓
ZIGGY GAP CHECK
        ↓
BOSSBRE PRIVACY / ROOM-SAFETY CHECK
        ↓
RECEIPT / REPLAY
```

The cast is defined in `family_actors_v0_1.json`.

`new_family_created=false`  
`relationship_verification_performed=false`  
`authority_created=false`
