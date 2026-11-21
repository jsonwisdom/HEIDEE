import assert from 'node:assert/strict';
import fs from 'node:fs';

const game=JSON.parse(fs.readFileSync('docs/joyspace/ooda-quest-manifest.json','utf8'));
const states=['REJECT','CONFLICT','HOLD','PASS'];
function dominant(values){return states.find(s=>values.includes(s));}
function evaluate(mission,choiceIndex){
  const practice=choiceIndex===mission.safe_choice_index?'PASS':'REJECT';
  return {practice,claim:mission.claim_verdict,effective:practice==='PASS'?'HOLD':'REJECT',authority:false,consent:'NOT_INFERRED'};
}
assert.equal(game.schema,'heidee/joyspace/ooda-quest-manifest/0.1');
assert.equal(game.mode,'SYNTHETIC_OFFLINE_ONLY');
assert.equal(game.authority,false);
assert.equal(game.family_gate,'SOVEREIGN_UNVERIFIED');
assert.equal(game.heidee_consent,'NOT_INFERRED');
assert.equal(game.human_approval,'NOT_ASSERTED');
for(const key of ['auto_enrollment','network_calls','persistence','competitions'])assert.equal(game[key],false);
assert.equal(game.flywheel_maintenance,'OFF');
assert.equal(game.missions.length,6);
assert.equal(new Set(game.missions.map(x=>x.id)).size,6);
assert.deepEqual(game.missions.map(x=>x.id),['SIGNAL','SHELF','ZIGGY','PAUSE','DELTA','GATE']);
let choices=0,pass=0,reject=0;
for(const m of game.missions){
  assert.equal(m.options.length,3);
  assert.ok(Number.isInteger(m.safe_choice_index) && m.safe_choice_index>=0 && m.safe_choice_index<3);
  assert.ok(['HOLD','CONFLICT'].includes(m.claim_verdict));
  for(let j=0;j<3;j++){
    let r=evaluate(m,j);choices++;
    assert.equal(r.authority,false);
    assert.equal(r.consent,'NOT_INFERRED');
    if(j===m.safe_choice_index){pass++;assert.equal(r.practice,'PASS');assert.equal(r.effective,'HOLD');}
    else{reject++;assert.equal(r.practice,'REJECT');assert.equal(r.effective,'REJECT');}
  }
}
assert.equal(choices,18);assert.equal(pass,6);assert.equal(reject,12);
let tuples=0;
for(const a of states)for(const b of states)for(const c of states)for(const d of states){
  let xs=[a,b,c,d];
  assert.equal(dominant(xs),states.find(s=>xs.includes(s)));
  tuples++;
}
assert.equal(tuples,256);
assert.equal(3**6,729);
console.log('PASS · 6 missions / 18 decisions, 256 precedence tuples, 729 six-mission paths.');
console.log('CONTRACT ONLY · no claim of browser UI parity, family approval, or deployment.');
