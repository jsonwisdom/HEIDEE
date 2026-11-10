// Run locally: node joyspace/2.0/games/ziggy-math-lab.test.mjs
// Tests verify fixed, public-safe fixtures only. No child information is accepted or written.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import vm from 'node:vm';
const root=new URL('./',import.meta.url);
const fixtures=JSON.parse(readFileSync(new URL('ziggy-math-fixtures-v0.1.json',root),'utf8'));
const html=readFileSync(new URL('ziggy-math-lab.html',root),'utf8');
const homepage=readFileSync(new URL('../index.html',root),'utf8');
const canonical=s=>JSON.stringify({acorns:s.acorns,map_pieces:s.map_pieces,clock_ticks:s.clock_ticks});
const sha=s=>createHash('sha256').update(canonical(s),'utf8').digest('hex');
let s={...fixtures.initial_state};
assert.deepEqual(s,{acorns:5,map_pieces:2,clock_ticks:3});
s={...s,acorns:s.acorns+3,clock_ticks:s.clock_ticks+1};
assert.deepEqual(s,fixtures.steps[0].expected_state);
assert.equal(sha(s),fixtures.steps[0].sha256);
s={...s,acorns:s.acorns/2,clock_ticks:s.clock_ticks+1};
assert.deepEqual(s,fixtures.steps[1].expected_state);
assert.equal(sha(s),fixtures.steps[1].sha256);
for(const f of fixtures.probability_fixtures){
 assert.equal(f.outcomes,2**f.flips);
 assert.equal(f.each_path_probability,'1/'+f.outcomes);
 assert.equal(f.outcomes*(1/f.outcomes),1);
}
assert.equal(fixtures.die_fixture.each_face_probability,'1/6');
assert.equal(6*(1/6),1);
assert.equal(fixtures.authority.parental,true);
assert.equal(fixtures.authority.ai,false);
assert.equal(fixtures.privacy.tracking,false);
assert.match(homepage,/href="games\/ziggy-math-lab.html"/);
assert.match(html,/connect-src 'none'/);
assert.match(html,/<option value="5" selected>5 flips<\/option>/);
assert.doesNotMatch(html,/fetch\s*\(|XMLHttpRequest|sendBeacon|WebSocket|localStorage|sessionStorage|indexedDB|document\.cookie|<script[^>]+src=/i);
const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/gi)];
assert.equal(scripts.length,1);
new vm.Script(scripts[0][1],{filename:'ziggy-math-lab-inline.js'});
console.log('ZIGGY_MATH_LAB_V01: PASS | 2 SHA-256 fixtures | 2-5 flip probability | local-only boundaries | script syntax | homepage link');
