#!/usr/bin/env python3
"""HEIDEE JoySpace public-source Librarian check. Offline only; no child data."""
import hashlib
import json
import re
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DRAW = ROOT / "docs/joyspace/index.html"
PDF = ROOT / "docs/joyspace/pdf-change-detective.html"
README = ROOT / "README.md"
assets = {p.name: p.read_bytes() for p in (DRAW, PDF, README)}
draw = assets[DRAW.name].decode("utf-8")
pdf = assets[PDF.name].decode("utf-8")
readme = assets[README.name].decode("utf-8")

class Resources(HTMLParser):
    def __init__(self):
        super().__init__()
        self.auto_external = []
        self.script_sources = []
        self.forms = []
    def handle_starttag(self, tag, attrs):
        props = dict(attrs)
        if tag == "script" and props.get("src"):
            self.script_sources.append(props["src"])
        if tag == "form":
            self.forms.append(props.get("action"))
        if tag in ("img", "iframe", "audio", "video", "source", "link") and (
            props.get("src", "").startswith(("https:", "http:")) or
            props.get("href", "").startswith(("https:", "http:"))
        ):
            self.auto_external.append((tag, props.get("src") or props.get("href")))

dparse, pparse = Resources(), Resources()
dparse.feed(draw)
pparse.feed(pdf)
checks = {
    "html_parser_completed": True,
    "creative_canvas_present": 'id="art"' in draw and "<canvas" in draw,
    "creative_undo_present": 'id="undo"' in draw and "ctx.putImageData" in draw,
    "creative_png_save_present": 'canvas.toDataURL("image/png")' in draw,
    "creative_print_present": "window.print()" in draw,
    "creative_share_not_upload": 'id="share"' in draw and "This page cannot post online." in draw,
    "creative_no_login_required_claim": "No wallet, account, token, or sign-in needed." in draw,
    "pdf_local_file_inputs": all(f'id="{ident}"' in pdf for ident in ("old", "new")),
    "pdf_cryptographic_hash": 'crypto.subtle.digest("SHA-256",bytes)' in pdf,
    "pdf_two_leaf_root": "joint(1,leafA,leafB)" in pdf and "joint(0,dehex(a.sha))" in pdf,
    "pdf_distinguishes_bytes_from_meaning": "Neither check authenticates the publisher or determines policy meaning." in pdf,
    "pdf_not_sent_notice": "Government delivery: NOT SENT." in pdf,
    "pdf_offline_witness_copy": "WITNESS COPY / NOT SENT" in pdf,
    "readme_declares_authority_false": "**Authority:** false" in readme,
    "readme_assigns_joyspace_to_heidee": "HEIDEE owns the child-specific JoySpace implementation." in readme,
    "no_external_script_src": not dparse.script_sources and not pparse.script_sources,
    "no_html_forms": not dparse.forms and not pparse.forms,
    "no_auto_external_resources": not dparse.auto_external and not pparse.auto_external,
    "no_network_api_invocations": all(not re.search(pattern, draw + "\n" + pdf) for pattern in (
        r"\bfetch\s*\(", r"\bXMLHttpRequest\b", r"\bWebSocket\s*\(",
        r"\bsendBeacon\s*\(", r"\bserviceWorker\.register\s*\(")),
}
report = {
    "schema": "heidee-joyspace-librarian-static-gate-v1",
    "scope": "public source code static checks only; synthetic/read-only",
    "test_count": len(checks),
    "passed": sum(checks.values()),
    "failures": [key for key, passed in checks.items() if not passed],
    "checks": checks,
    "source_sha256": {
        "docs/joyspace/index.html": hashlib.sha256(DRAW.read_bytes()).hexdigest(),
        "docs/joyspace/pdf-change-detective.html": hashlib.sha256(PDF.read_bytes()).hexdigest(),
        "README.md": hashlib.sha256(README.read_bytes()).hexdigest(),
    },
    "browser_runtime_verification": "NOT_RUN",
    "guardian_publication_approval": "NOT_ESTABLISHED",
    "public_http_source_parity": "UNKNOWN",
    "child_private_data_read": False,
    "authority_created": False,
    "production_write": False,
    "external_anchor": False,
    "deployment": False,
    "production_ledger": "HOLD",
}
print(json.dumps(report, indent=2, sort_keys=True))
raise SystemExit(1 if report["failures"] else 0)
