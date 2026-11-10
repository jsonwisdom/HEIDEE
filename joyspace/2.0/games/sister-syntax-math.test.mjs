// Fixed public-safe teaching fixtures only. No real family data.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';

const root=new URL('./',import.meta.url);
const fixtures=JSON.parse(readFileSync(new URL('sister-syntax-daughters-math-v0.1.json',root),'utf8'));
const game=readFileSync(new URL('sister-syntax-math.html',root),'utf8');
const homepage=readFileSync(new URL('../index.html',root),'utf8');

assert.equal(fixtures.schema_version,'SISTER_SYNTAX_DAUGHTERS_MATH_V0_1');
assert.equal(fixtures.status,'LOCAL_DRAFT_ONLY');
assert.deepEqual(fixtures.sister_math_commands,['QUESTION','FREEZE','TRANSFORM','CHECK','COMPARE','REVERSE','EXPLAIN','REPEAT']);
assert.deepEqual(fixtures.three_daughters_algorithm.stages,['PROTECT','PRESERVE','EXPAND']);
assert.equal(fixtures.three_daughters_algorithm.terminal_authority,false);
assert.equal(fixtures.three_daughters_algorithm.no_share_is_valid,true);

const m=fixtures.numeric_fixture;
assert.equal(m.initial+m.delta,m.transformed);
assert.equal(m.transformed-m.delta,m.recovered);
assert.equal(m.recovered,m.initial);
assert.equal(m.delta,m.transformed-m.initial);
assert.equal(m.transformed,m.initial+m.delta);
assert.equal((m.initial+m.delta)-m.delta,m.initial);

const route = scenario => {
  if(!scenario.privacy_public_safe)return 'PRIVATE_HOLD';
  if(!scenario.consent_explicit)return 'NO_SHARE';
  if(!scenario.human_review)return 'REVIEW_HOLD';
  return 'LOCAL_REPLAY_READY';
};
for(const scenario of fixtures.scenarios){
 assert.equal(route(scenario),scenario.expected,scenario.id);
}
assert.equal(route({privacy_public_safe:false,consent_explicit:false,human_review:true}),'PRIVATE_HOLD');
assert.equal(route({privacy_public_safe:true,consent_explicit:false,human_review:true}),'NO_SHARE');

for(const key of ['parental','ai','system','institutional','school_affiliation']){
  assert.equal(fixtures.authority[key],key==='parental');
}
for(const key of ['child_data','accounts','tracking','real_secrets','unconsented_sharing']){
  assert.equal(fixtures.privacy[key],false);
}
assert.equal(fixtures.privacy.local_only,true);
assert.equal(fixtures.theme.mode,'OPTIONAL_FICTIONAL_CLASSROOM_SKIN');
assert.equal(fixtures.theme.no_student_or_alumni_claim,true);
assert.equal(fixtures.theme.no_institutional_endorsement_claim,true);
assert.equal(fixtures.theme.rivals_are_not_enemies,true);
assert.ok(fixtures.proof_boundaries.includes('GAME_SCORE != SCHOOL_GRADE'));
assert.ok(fixtures.proof_boundaries.includes('CHILD_SILENCE != CONSENT'));
assert.match(homepage,/href="games\/sister-syntax-math\.html"/);
assert.match(game,/connect-src 'none'/);
assert.match(game,/NO_TRACKING/);
assert.match(game,/WAR EAGLE/);
assert.match(game,/ROLL TIDE/);
assert.match(game,/not a claim about any learner.s campus/i);
assert.doesNotMatch(game,/\bfetch\s*\(|XMLHttpRequest|sendBeacon|WebSocket|localStorage|sessionStorage|indexedDB|document\.cookie|<script[^>]+src=/i);
const scripts=[...game.matchAll(/<script>([\s\S]*?)<\/script>/gi)];
assert.equal(scripts.length,1);
new vm.Script(scripts[0][1],{filename:'sister-syntax-math-inline.js'});
console.log('SISTER_SYNTAX_MATH: PASS | reversible arithmetic | privacy routes | 3 daughters ordering | Auburn theme boundaries | no tracking');
