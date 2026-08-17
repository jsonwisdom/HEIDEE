# Parental Process Pincer Pinky Promise Protocol

Status: READY_NOT_ROLLED  
Scope: JOYSPACE_FOR_FAMILIES  
Lane: CRISSCROSS_CONSTITUTION_EXECUTIVE  
Family-ready: TRUE  
Authority created: FALSE

## Purpose

A parent-controlled dice game for asking hard questions about Executive Branch actions without turning a government claim, executive document, family question, or dice result into law, family fact, or authority.

## The Pincer

```text
LEFT PINCER                         RIGHT PINCER
What executive action?             What authority is cited?
        \                           /
         \                         /
          RECEIPT + LIMIT CHECK
                  ↓
          PARENTAL PRIVACY GATE
                  ↓
      PASS | HOLD | CONFLICT | OUTSIDE_SCOPE
                  ↓
                REPLAY
```

## Pinky Promise

We promise to:

- ASK_BEFORE_INFER
- SOURCE_BEFORE_SCORE
- SEPARATE_ORDER_FROM_LAW
- SEPARATE_ENFORCEMENT_FROM_LEGISLATION
- KEEP_FAMILY_PRIVACY_SEALED
- PRESERVE_UNKNOWN_AS_HOLD
- NEVER_PROMOTE_DICE_TO_FACT

```text
PARENTAL_AUTHORITY      = TRUE
SYSTEM_AUTHORITY        = FALSE
INSTITUTIONAL_AUTHORITY = FALSE
```

## Five Dice

### 1. Executive Action Die

`EXECUTIVE_ORDER | PROCLAMATION | MEMORANDUM | AGENCY_ACTION | ENFORCEMENT_ACTION | PUBLIC_STATEMENT`

### 2. Authority Die

`ARTICLE_II | ACT_OF_CONGRESS | SHARED_POWER | DELEGATED_AUTHORITY | CLAIMED_INHERENT_POWER | UNKNOWN`

### 3. Receipt Die

`FEDERAL_REGISTER | STATUTE_TEXT | CONSTITUTION_ANNOTATED | COURT_RECORD | AGENCY_RECORD | MISSING`

### 4. Checks Die

`CONGRESS | COURT | SENATE_ADVICE_CONSENT | APPROPRIATIONS | STATUTORY_LIMIT | NOT_YET_BOUND`

### 5. Family Die

`ASK | LEARN | COMPARE | REPAIR | HOLD | REPLAY`

## Constitutional membrane

Article II establishes the federal Executive Branch, vests executive power in the President, identifies specified presidential powers, and requires the President to take care that the laws are faithfully executed. Executive authority exists inside the Constitution's separated-powers structure and does not become unlimited merely because an action is labeled presidential or executive.

```text
EXECUTIVE_ORDER != ACT_OF_CONGRESS
PRESIDENTIAL_STATEMENT != LAW
AGENCY_ACTION != FAMILY_AUTHORITY
COMMANDER_IN_CHIEF != GENERAL_DOMESTIC_LAWMAKING_POWER
EXECUTIVE_POWER != UNLIMITED_POWER
ENFORCEMENT != LEGISLATION
DICE_ROLL != CONSTITUTIONALITY_RULING
FAMILY_QUESTION != ACCUSATION
PARENTAL_PROCESS != GOVERNMENT_AUTHORITY
```

## Official receipt rails

1. Constitution Annotated / Article II
2. Federal Register presidential documents and executive actions
3. Statutory text when Congress is cited as the source of authority
4. Court records when judicial review is relevant
5. Agency records when an agency action is the actual object being tested

A source label is not enough. The specific document must be bound to the specific question before promotion.

## Privacy + family guards

- Family details default to `FAMILY_RESTRICTED`.
- No private biography is inferred from a government record.
- No public-person identity is bound to a family node without a separate receipt.
- No relationship edge is created by this game.
- A family member may ask a question without making an accusation.
- Unknown remains `HOLD`.
- Human/parent approval remains the final family gate.

```text
GAME_STATE != FAMILY_FACT
DICE_ROLL != VERDICT
EXECUTIVE_DOCUMENT != FAMILY_RECORD
OFFICIAL_SOURCE != CLAIM_TRUE
JAY_APPROVAL_REQUIRED = TRUE
RELATIONSHIP_EDGES_CREATED = 0
AUTHORITY_CREATED = FALSE
SOURCE_MUTATED = FALSE
```

## Round 2

```text
STATE   = READY_NOT_ROLLED
OUTCOME = UNASSIGNED
```

No dice outcome is manufactured before the family rolls.
