/* School of Wisdom · Lyrical Evidence Corridor v1.0.0
   Stateless education only. No copyrighted lyric corpus, credentials, wallets, payments, storage or authorization.
*/
const evidence=[
{claim:"Bob Dylan met Pope Leo XIV at the Vatican on November 4, 2026",verdict:"PASS",source:"Vatican News 2026-11-04",url:"https://www.vaticannews.va/en/pope/news/2026-11/pope-leo-receives-bob-dylan-at-the-vatican.html"},
{claim:"Pope Leo XIV had previously cited Bob Dylan's 1963 anti-nuclear work Go Away You Bomb",verdict:"PASS",source:"Vatican News 2026-11-04",url:"https://www.vaticannews.va/en/pope/news/2026-11/pope-leo-receives-bob-dylan-at-the-vatican.html"},
{claim:"The complete private conversation has an independently verified public verbatim transcript",verdict:"UNKNOWN",source:"No verbatim transcript established in this pilot",url:null},
{claim:"BlackBar Press imagined dialogue is a verbatim historical record",verdict:"FAIL",source:"BlackBar Press labels its dialogue satire",url:null}
];
const H={"content-type":"application/json; charset=utf-8","cache-control":"no-store","x-content-type-options":"nosniff","referrer-policy":"no-referrer"};
const reply=(o,s=200)=>new Response(JSON.stringify(o,null,2),{status:s,headers:H});
const norm=s=>s.normalize("NFKC").toLocaleLowerCase("en").replace(/[\p{P}\p{S}]+/gu," ").replace(/\s+/gu," ").trim();
const tok=s=>norm(s).match(/[\p{L}\p{N}]+/gu)||[];
const digest=async s=>Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256",new TextEncoder().encode(s))),b=>b.toString(16).padStart(2,"0")).join("");
const trigrams=t=>new Set(Array.from({length:Math.max(0,t.length-2)},(_,i)=>t.slice(i,i+3).join(" ")));
async function compare(a,b,ak="unspecified",bk="unspecified"){
 const x=norm(a),y=norm(b),ta=tok(a),tb=tok(b),A=trigrams(ta),B=trigrams(tb);
 const rawA=await digest(a),rawB=await digest(b),normalA=await digest(x),normalB=await digest(y);
 const intersection=[...A].filter(g=>B.has(g)).length,union=new Set([...A,...B]).size,score=union?intersection/union:null;
 return {schema:"school-of-wisdom/lyrical-evidence/1",version:"1.0.0",authority:false,content_retained:false,source_types:[ak,bk],
 sha256:{a_raw:rawA,b_raw:rawB,a_normalized:normalA,b_normalized:normalB},
 measurements:{a_words:ta.length,b_words:tb.length,shared_three_word_sequences:intersection,unique_three_word_sequences:union,three_word_jaccard:score===null?null:Number(score.toFixed(6))},
 checks:[{test:"same_supplied_utf8_text",verdict:rawA===rawB?"PASS":"FAIL"},
 {test:"same_normalized_text",verdict:normalA===normalB?"PASS":"FAIL"},
 {test:"enough_words_to_compare_trigrams",verdict:ta.length>=3&&tb.length>=3?"PASS":"UNKNOWN"},
 {test:"original_authorship_and_reuse_permissions",verdict:"UNKNOWN"},
 {test:"verbatim_private_dialogue",verdict:"UNKNOWN"}],
 shared_wording_review:score!==null&&score>=0.5&&! (rawA===rawB),note:"0.5 is a teaching heuristic, not a plagiarism threshold. Shared words do not prove authorship, copyright status, or intent."};
}
const page=['<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">',
'<title>School of Wisdom · Lyrical Evidence Corridor</title><style>body{margin:0;background:#101827;color:#eff7ff;font:17px/1.55 system-ui}main{max-width:800px;margin:auto;padding:24px}h1{line-height:1.1}a{color:#91e5ff}section{border:1px solid #67809b;border-radius:12px;padding:18px;margin:22px 0;background:#1b2b3f}textarea{width:100%;box-sizing:border-box;min-height:82px;background:#0c2035;color:white;font:inherit;padding:10px;border:1px solid #a2c4e0;border-radius:8px}button{padding:12px 20px;margin:12px 0;background:#a3f3d2;border:0;border-radius:8px;font-weight:700}pre{white-space:pre-wrap;overflow-wrap:anywhere;font-size:.8rem}small{color:#bdd2e6}</style></head><body><main>',
'<p>👓 COMPUTER WISDOM · CLASSES WITH GLASSES</p><h1>🎸 Lyrical Evidence Corridor</h1>',
'<p>A public-safe teaching path for HEIDEE / JoySpace. Today, and 50 years from now: verification before narrative.</p>',
'<section><b>PASS:</b> Bob Dylan met Pope Leo XIV on November 4, 2026.<p><b>UNKNOWN:</b> their complete private dialogue.</p><p><b>FAIL:</b> treating an imagined BlackBar Press exchange as a verbatim transcript.</p><a href="https://www.vaticannews.va/en/pope/news/2026-11/pope-leo-receives-bob-dylan-at-the-vatican.html">Read Vatican News source</a></section>',
'<h2>Compare two short text samples</h2><p>Original classroom samples are supplied. Do not paste full copyrighted lyrics. Inputs are processed without storage.</p>',
'<label for="a">Text A</label><textarea maxlength="500" id="a">The school preserves records and tests each claim.</textarea>',
'<label for="b">Text B</label><textarea maxlength="500" id="b">The school preserves records and checks each claim.</textarea>',
'<button id="run">Audit wording</button><p id="status" role="status"></p><pre id="out">Press Audit wording to compare.</pre>',
'<h2>Lesson purpose</h2><p>Separate songs, lyrics, transcripts, captions, news, and satire. Compare raw SHA-256, normalized SHA-256, and three-word overlaps. Preserve source dates and corrections. Similarity never establishes a true quotation, authorship, intention, or permission.</p>',
'<p><a href="/lesson.json">Evidence JSON</a> · <a href="/demo.json">Original demo</a> · <a href="/health">Health</a> · <a href="https://github.com/jsonwisdom/HEIDEE">HEIDEE GitHub</a> · <a href="https://github.com/jsonwisdom/COMPUTERWISDOM">Computer Wisdom GitHub</a></p>',
'<small>Read-only knowledge; stateless comparisons; no wallet, payments, or private family records. Authority false.</small>',
'</main><script>document.getElementById("run").onclick=async()=>{const out=document.getElementById("out"),status=document.getElementById("status");status.textContent="Analyzing...";try{const r=await fetch("/compare",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({a:document.getElementById("a").value,b:document.getElementById("b").value,a_kind:"original",b_kind:"original"})});out.textContent=JSON.stringify(await r.json(),null,2);status.textContent=r.ok?"Scope-limited audit complete.":"Invalid input."}catch{status.textContent="Comparison unavailable; no content retained."}}</script></body></html>'].join("");
export default {async fetch(request){
 const u=new URL(request.url);
 if(request.method==="GET"&&u.pathname==="/health")return reply({ok:true,service:"school-of-wisdom-lyric-audit",version:"1.0.0",scope:"PUBLIC_SAFE_EDUCATION",authority:false,privacy:"no_storage",payments:false,wallets:false,certification:"UNKNOWN"});
 if(request.method==="GET"&&u.pathname==="/lesson.json")return reply({schema:"school-of-wisdom/lyrical-lesson/1",evidence,copyright:"Original classroom text and short lawfully used excerpts only; no bulk lyrics redistribution",durability:"Preserve git commit IDs, dated original source URLs, correction records and open source code for 2076 replay",statements:{confirmed:"meeting documented",unverified:"private word-for-word dialogue",satire:"imagined BlackBar Press remarks"},authority:false});
 if(request.method==="GET"&&u.pathname==="/demo.json")return reply(await compare("The school preserves records and tests each claim.","The school preserves records and checks each claim.","original","original"));
 if(request.method==="GET"&&u.pathname==="/")return new Response(page,{headers:{"content-type":"text/html; charset=utf-8","cache-control":"no-store","x-content-type-options":"nosniff","referrer-policy":"no-referrer","content-security-policy":"default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'"}});
 if(request.method==="POST"&&u.pathname==="/compare"){
  if(request.headers.get("content-type")?.split(";")[0].trim()!=="application/json")return reply({error:"json_required"},415);
  if(Number(request.headers.get("content-length"))>8192)return reply({error:"payload_too_large"},413);
  let body;try{body=await request.text()}catch{return reply({error:"read_error"},400)}
  if(new TextEncoder().encode(body).length>8192)return reply({error:"payload_too_large"},413);
  let data;try{data=JSON.parse(body)}catch{return reply({error:"invalid_json"},400)}
  if(!data||typeof data!=="object"||Array.isArray(data)||typeof data.a!=="string"||typeof data.b!=="string"||!data.a.trim()||!data.b.trim()||data.a.length>500||data.b.length>500)return reply({error:"two_short_nonempty_texts_required"},400);
  const kinds=["original","lyric","transcript","caption","news","satire"];
  return reply(await compare(data.a,data.b,kinds.includes(data.a_kind)?data.a_kind:"unspecified",kinds.includes(data.b_kind)?data.b_kind:"unspecified"));
 }
 return reply({error:"not_found"},404);
}};
