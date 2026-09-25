# Receipt Schemas

Only schemas that type DELTA Training Family Edition math receipts belong here.

A schema may define required fields and allowable states. It may not promote a game result into a family fact, school grade, USAF curriculum claim, military training claim, or authority state.

Required conceptual separations:
- `PROBLEM_CONTEXT != AUTHORITY`
- `PLAYER_ATTEMPT != VERIFIED_FACT`
- `CHECK_RESULT != PERSON_EVALUATION`
- `DELTA != CAUSATION`
- `REPLAY != AUTHORITY`

`authority_created=false`
