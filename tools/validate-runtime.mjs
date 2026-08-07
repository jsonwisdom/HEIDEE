import fs from 'node:fs';
import assert from 'node:assert/strict';

const read = p => fs.readFileSync(p,'utf8');
const json = p => JSON.parse(read(p));
const M = json('metadata.json');
const fixture = json('fixtures/instrument.blank.json');
const receipt = json('schema/joy_receipt.schema.json');

assert.equal(M.project.authority,false);
assert.equal(M.family_tree.parent_layer,'JSON');
assert.equal(M.family_tree.child_experience,'HEIDEE JOY');
assert.equal(M.atomic_family.instrument_policy.chooser,'JOY_AND_FAMILY');
assert.equal(M.atomic_family.instrument_policy.meaning_is_not_preassigned,true);
assert.equal(M.joy_gate.question,'Did I enjoy that?');
assert.equal(M.joy_gate.no_behavior,'preserve_and_stop');
assert.equal(M.joy_gate.yes_behavior,'reveal_easy_button');
assert.equal(M.network_boundary.id,'JOY_NETWORK_BOUNDARY_V1');
assert.equal(M.network_boundary.default,'DENY');
assert.equal(M.network_boundary.validation_style,'ALLOWLIST_FIRST');
assert.equal(M.network_boundary.unknown_capability,'VALIDATION_FAILURE');
assert.deepEqual(M.network_boundary.allowed_runtime_reads,['./metadata.json','./fixtures/instrument.blank.json']);
assert.equal(M.ai.model_download_policy,'DO_NOT_TRIGGER_DOWNLOAD');
assert.equal(M.ai.browser_model_activation,'ONLY_IF_ALREADY_AVAILABLE');
assert.equal(fixture.chosen_by,'JOY_AND_FAMILY');
assert.equal(fixture.score_person,false);
assert.equal(fixture.remote_send,false);
assert.deepEqual(receipt.required,M.receipt.fields);

const pages = Object.values(M.public_pages);
assert.deepEqual(pages,['index.html','joy-ai.html','parents.html']);
for (const p of [...pages,...M.network_boundary.allowed_runtime_reads.map(x=>x.replace(/^\.\//,''))]) assert.ok(fs.existsSync(p),`declared resource missing: ${p}`);

const normalize = s => s.startsWith('./') ? s : './'+s;
const allowedReads = new Set(M.network_boundary.allowed_runtime_reads);
const allowedNav = new Set(pages.map(normalize));
const forbiddenJs = [
  /\bXMLHttpRequest\b/,/\bWebSocket\b/,/\bEventSource\b/,/navigator\s*\.\s*sendBeacon\b/,
  /\bSharedWorker\b/,/\bWorker\s*\(/,/navigator\s*\.\s*serviceWorker\b/,/\bimportScripts\s*\(/,
  /\bwindow\s*\.\s*open\s*\(/,/\blocation\s*\.\s*(assign|replace)\s*\(/,
  /\[\s*['"](?:fetch|XMLHttpRequest|WebSocket|EventSource|sendBeacon|Worker|SharedWorker|importScripts)['"]\s*\]/
];

function checkFetches(js,file){
  for(const m of js.matchAll(/\bfetch\s*\(\s*([^,\n\)]+)/g)){
    const arg=m[1].trim();
    const lit=arg.match(/^(['"`])([^'"`$]+)\1$/);
    if(lit){assert.ok(allowedReads.has(normalize(lit[2])),`${file}: fetch not allowlisted: ${lit[2]}`);continue;}
    if(arg==='M.atomic_family.instrument_policy.default_fixture'){
      assert.ok(allowedReads.has(normalize(M.atomic_family.instrument_policy.default_fixture)),`${file}: fixture fetch not declared`);continue;
    }
    assert.fail(`${file}: dynamic/unknown fetch capability: ${arg}`);
  }
}

function checkHtml(file){
  const html=read(file);
  assert.ok(!/https?:\/\//i.test(html),`${file}: external URL`);
  assert.ok(!/<form\b/i.test(html),`${file}: forms forbidden`);
  assert.ok(!/<base\b/i.test(html),`${file}: base tag forbidden`);
  assert.ok(!/<meta[^>]+http-equiv\s*=\s*['"]?refresh/i.test(html),`${file}: meta refresh forbidden`);
  assert.ok(!/url\s*\(\s*['"]?(?:https?:|\/\/)/i.test(html),`${file}: external CSS url`);

  for(const m of html.matchAll(/\b(src|href|action|poster)\s*=\s*(['"])(.*?)\2/gi)){
    const [_,attr,,value]=m;
    if(!value || value.startsWith('#')) continue;
    assert.ok(!/^[a-z][a-z0-9+.-]*:/i.test(value) && !value.startsWith('//'),`${file}: external ${attr}: ${value}`);
    if(attr.toLowerCase()==='href') assert.ok(allowedNav.has(normalize(value)),`${file}: undeclared navigation: ${value}`);
    else assert.ok(allowedReads.has(normalize(value)),`${file}: undeclared resource ${attr}: ${value}`);
  }

  for(const [,script] of html.matchAll(/<script>([\s\S]*?)<\/script>/gi)){
    new Function(script);
    for(const rule of forbiddenJs) assert.ok(!rule.test(script),`${file}: forbidden network capability ${rule}`);
    assert.ok(!/\bimport\s*\(/.test(script),`${file}: dynamic import forbidden`);
    for(const m of script.matchAll(/document\.createElement\s*\(\s*(['"])(.*?)\1\s*\)/g)) assert.equal(m[2].toLowerCase(),'a',`${file}: dynamic element forbidden: ${m[2]}`);
    checkFetches(script,file);
  }
}

for(const page of pages) checkHtml(page);

const joyAi=read('joy-ai.html');
assert.ok(joyAi.includes('LanguageModel.availability()'),'joy-ai: availability gate missing');
assert.ok(joyAi.includes("availability!=='available'"),'joy-ai: must refuse downloadable/downloading model');
assert.ok(joyAi.indexOf('LanguageModel.availability()') < joyAi.indexOf('LanguageModel.create('),'joy-ai: create occurs before availability check');

const workflow=read('.github/workflows/joyspace-runtime.yml');
assert.ok(!/upload-artifact|curl\s|wget\s/i.test(workflow),'workflow: artifact upload or ad-hoc network command forbidden');

console.log('JOYSPACE_RUNTIME=PASS');
console.log('JOY_NETWORK_BOUNDARY_V1=PASS');
console.log('AUTHORITY_CREATED=FALSE');
