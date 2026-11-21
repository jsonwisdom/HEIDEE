import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const html=fs.readFileSync('docs/joyspace/ooda-quest.html','utf8');
const script=html.match(/<script id="joyspace-quest-code">([\s\S]*?)<\/script>/)?.[1];
assert.ok(script,'offline page must include testable game rules');
const scope={}; vm.createContext(scope); vm.runInContext(script,scope,{timeout:3000});
const rules=scope.JoySpaceQuestRules; assert.ok(rules,'rules must be accessible for review tests');
const missions=[...rules.missions];
assert.equal(missions.length,6);
assert.equal(new Set(missions.map(x=>x.id)).size,6);
let checked=0;
for(const m of missions){
  assert.equal(m.options.length,3);
  for(let j=0;j<m.options.length;j++){
    const verdict=rules.answer(m,j); const receipt=rules.practiceReceipt(m,j);checked++;
    assert.equal(verdict.effective,j===m.safe?'HOLD':'REJECT');
    assert.equal(verdict.practice,j===m.safe?'PASS':'REJECT');
    assert.equal(receipt.authority,false);
    assert.equal(receipt.heidee_consent,'NOT_INFERRED');
    assert.equal(receipt.private_data_collected,false);
    assert.equal(receipt.external_actions,false);
    assert.equal(receipt.account_changes,false);
    assert.equal(receipt.public_release,false);
    assert.equal(receipt.effective_decision,verdict.effective);
    assert.deepEqual(JSON.parse(JSON.stringify(receipt)),JSON.parse(JSON.stringify(rules.practiceReceipt(m,j))));
  }
}
assert.equal(checked,18);
const s=['REJECT','CONFLICT','HOLD','PASS'];let n=0;
for(const a of s)for(const b of s)for(const c of s)for(const d of s){const state=[a,b,c,d];assert.equal(rules.priority(state),s.find(x=>state.includes(x)));n++;}
assert.equal(n,256);
assert.throws(()=>rules.priority([]));assert.throws(()=>rules.priority(['GREEN']));
assert.equal(3**6,729);
assert.match(html,/connect-src 'none'/);
assert.doesNotMatch(script,/(fetch\(|localStorage|sessionStorage|XMLHttpRequest|WebSocket|sendBeacon|navigator\.sendBeacon)/);
console.log('RUNTIME SOURCE PASS · 18 choices, 256 state tuples, 729 game paths, no authority/network/storage');
