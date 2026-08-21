# AppleDevelop — Apple Blossom Family Build v0.1

**Observed:** 2026-08-20 19:40 America/Chicago  
**Repository:** `jsonwisdom/HEIDEE`  
**JoySpace rail:** PR #3 / `agent/joyspace-2.0-family-directories-first`  
**Apple Blossom source rail:** `jsonwisdom/COMPUTERWISDOM` PR #518  
**Mode:** `FAMILY_LOCAL_FIRST / REPLAYABLE / OPTIONAL_AI_PROVIDER / NO_AUTO_TRADE`  
**Authority created:** `false`

## Purpose

Turn Apple Blossom from a language-learning pattern into a family-safe Apple-platform product loop without collapsing:

- family meaning into model output;
- child memory into assistant logs;
- wallet/capital state into learner value;
- token price into learning progress;
- OpenAI or Apple model state into canonical family memory.

The core product is **family learning + replay**. Public creator surfaces and adult capital are optional downstream rails.

## Existing durable inputs

### Apple Blossom learning method

Source: `jsonwisdom/COMPUTERWISDOM` PR #518.

```text
SEE
→ HEAR
→ SAY
→ SWAP LANGUAGE
→ CONFIRM
→ REPLAY
```

Locked distinctions remain:

```text
MODEL_OUTPUT != LEARNER_MASTERY
TRANSLATION_OUTPUT != LEARNER_MASTERY
ASSISTANCE_USED MUST BE RECEIPTED
DELAYED_REPLAY MUST BE RECEIPTED
```

### JoySpace / Atomic Family

Source: `jsonwisdom/HEIDEE` PR #3.

```text
NODE OWNS VERSION
EDGE OWNS EXCHANGE RECEIPT
CHECKPOINT OWNS ACKNOWLEDGEMENT
NO OBJECT OWNS EVERYBODY'S TRUTH
```

Atomic Family exchange/checkpoint proof already demonstrates:

```text
A:v7 + B:v4 + C:v9
→ DIFFERENCE_RECEIPT
→ NO AUTO MERGE
→ A:v7 + B:v4 + C:v9
```

## AppleDevelop product loop

```text
FAMILY MEANING
      ↓
APPLE BLOSSOM ROUND
      ↓
LOCAL LEARNER RECEIPT
      ↓
DELAYED REPLAY
      ↓
FAMILY-OWNED STORY / ARTIFACT
      ↓ optional
PUBLIC CREATOR SURFACE
      ↓ optional, adult-controlled
ADULT CAPITAL / REINVESTMENT RAIL
      ↓
NEXT FAMILY BUILD
```

The flywheel is allowed to circulate resources. It may not convert money, attention, token value, or platform status into a learner score or family-authority claim.

## Hard financial/privacy boundaries

```text
WALLET_BALANCE != FAMILY_VALUE
TOKEN_PRICE != LEARNING_PROGRESS
CREATOR_COIN != CHILD_REPUTATION_SCORE
CHILD_DATA != WALLET_DATA
CHILD != FINANCIAL_ACTOR_BY_DEFAULT
FAMILY_MEMORY != PORTFOLIO_RECORD
ASSISTANT_LOG != CHILD_MEMORY
MODEL != FINANCIAL_ADVISOR
NO_AUTO_TRADE = TRUE
NO_AUTO_SELL = TRUE
NO_AUTO_BUY = TRUE
NO_CHILD_WALLET_ACTION = TRUE
```

Current wallet imagery supplied during design review is treated as a private current-turn observation. Exact balances are not copied into this public architecture artifact.

## Apple platform architecture

### 1. SwiftUI family experience

Primary screens:

```text
HOME / PORCH
APPLE BLOSSOM ROUND
REPLAY DECK
FAMILY STORY
MY RECEIPTS
PARENT BOUNDARY
```

The cultural interaction surface can retain the American-80s VCR controls:

```text
REW      = last locally valid / mutually acknowledged checkpoint
PLAY     = render this node's authored state + provenance
FF       = propose delta on proposer node only
TRACKING = compare MATCH | VARIANT | CONFLICT | HOLD
PAUSE    = preserve state / no mutation
EJECT    = end exchange / preserve independent nodes
```

### 2. Siri / App Intents

Candidate intents:

```text
StartBlossomRound
ReplayLastRound
SwapLanguage
ConfirmMeaning
ShowMyReceipt
EjectSession
```

Siri is a system interaction surface, not family authority.

```text
SIRI_CONTEXT != FAMILY_AUTHORITY
SIRI_OUTPUT != FAMILY_TRUTH
SIRI_KNOWS_RELATIONSHIP != CONSENT
```

### 3. Foundation Models provider layer

Default child-facing posture:

```text
LOCAL_FIRST
NETWORK_OPTIONAL
MODEL_PROVIDER_REPLACEABLE
```

Provider contract:

```text
LanguageProvider
  ├─ AppleFoundationModelProvider
  ├─ OpenAIRealtimeProvider
  └─ DeterministicFixtureProvider
```

The app must function in a bounded deterministic mode if no AI provider is available.

```text
AI_UNAVAILABLE != JOYSPACE_UNAVAILABLE
PROVIDER_CHANGE != MEMORY_MIGRATION
MODEL_SESSION != DURABLE_FAMILY_STATE
```

## OpenAI developer rail

OpenAI is an optional voice/translation/agent provider, not the product root.

Candidate uses:

```text
GPT-Realtime-Translate
= live language swap / translation rail

GPT-Realtime-2
= conversational pronunciation / turn-taking rail

Agents SDK
= bounded builder / replay / evaluation harness
```

Network/API use must sit behind the Parent Boundary and explicit provider policy.

```text
OPENAI_API_REQUIRED_FOR_CORE_LOOP = FALSE
OPENAI_MEMORY != CANON
OPENAI_CONVERSATION != FAMILY_MEMORY
OPENAI_OUTPUT != LEARNER_MASTERY
API_KEY_IN_REPO = FALSE
```

No API key is created or embedded by this artifact.

## Atomic Family data layout

```text
FamilyNode
  id
  authored_version
  local_receipts[]
  local_preferences[]

AssistNode
  provider
  assist_log_version
  assistance_used
  no_family_authority

ExchangeReceipt
  from_node
  to_node
  purpose
  scope
  consent_or_lawful_basis
  content_hash
  result

Checkpoint
  participant_versions
  acknowledged_at
  purpose
  scope
```

```text
CHECKPOINT != GLOBAL_TRUTH
SIGNED_RECEIPT != SHARED_MEMORY
DIVERGENCE != ERROR
RECONCILIATION != OVERWRITE
```

## Family flywheel

The useful economic flywheel is **build-driven**, not trade-driven:

```text
BUILD
→ LEARN
→ REPLAY
→ SHIP A FAMILY-SAFE ARTIFACT
→ OPTIONAL PUBLIC ATTENTION
→ OPTIONAL ADULT-CONTROLLED CAPITAL
→ REINVEST IN NEXT BUILD
→ BUILD AGAIN
```

Adult-controlled reinvestment can fund things such as:

- Apple Developer Program / distribution costs;
- domains / hosting;
- accessibility testing;
- translation/evaluation expenses;
- family-approved creative assets;
- limited provider/API usage;
- device/test hardware.

No portfolio percentage, buy/sell target, yield target, or token-price rule is defined by AppleDevelop v0.1.

## Development phases

### Phase A — deterministic prototype

```text
SwiftUI shell
+ local fixtures
+ Apple Blossom round state
+ Atomic Family receipt export
+ VCR replay controls
```

No network required.

### Phase B — Siri-native interaction

```text
App Intents
+ App Entities
+ Spotlight/Siri discoverability
+ confirmation before sensitive actions
```

### Phase C — local intelligence

```text
Foundation Models framework
+ prompt/evaluation fixtures
+ provider abstraction
```

### Phase D — optional OpenAI voice bridge

```text
Parent Boundary PASS
→ ephemeral server/session token
→ Realtime voice / translation
→ assistance receipt
→ local family replay state
```

No long-lived OpenAI secret ships inside the iOS app bundle.

### Phase E — public creator bridge

Optional export only:

```text
FAMILY-APPROVED ARTIFACT
→ REDACTION CHECK
→ PUBLIC CREATOR SURFACE
```

Public publishing must not expose private child, family, wallet, school, health, location, credential, or account data.

### Phase F — adult capital/reinvestment bridge

Optional adult-only ledger:

```text
PUBLIC WORK / CREATOR RECEIPT
→ ADULT CAPITAL EVENT
→ ADULT DECISION
→ REINVESTMENT RECEIPT
```

```text
CAPITAL_EVENT != FAMILY_MEANING
CAPITAL_EVENT != LEARNER_MASTERY
ADULT_DECISION_REQUIRED = TRUE
```

## First shippable AppleBuild

Minimum useful product:

```text
1. Pick ❤️ / 😂 / 😡 / ✅ / ⚠️.
2. Hear a short phrase.
3. Say it back.
4. Swap language.
5. Confirm intended meaning.
6. Record assistance actually used.
7. EJECT or REPLAY.
8. Replay later and compare.
9. Export a local receipt.
```

Success is not token appreciation or app engagement.

```text
SUCCESS = FAMILY CHOOSES TO REPLAY
        + LEARNING RECEIPT IS VALID
        + PRIVACY BOUNDARY HOLDS
```

## State

```text
APPLEDEVELOP_V0_1 = DRAFT_IMPLEMENTATION_SPEC
APPLE_BLOSSOM_0_3_1 = PRESERVED
JOYSPACE_PR_3 = CONTAINER
OPENAI_PROVIDER = OPTIONAL
APPLE_LOCAL_PROVIDER = PREFERRED_FIRST_IMPLEMENTATION
AUTO_GLOBAL_MERGE = FALSE
AUTO_TRADE = FALSE
AUTHORITY_CREATED = FALSE
MERGE_AUTHORIZED = FALSE
```
