#!/usr/bin/env python3
"""JOY -> ALMS -> LeeLoo evidence adapter. Offline, read-only, authority=False.

Inputs must be local clones of jsonwisdom/JOY and jsonwisdom/AL. Sources are
pinned by Git blob SHA-1. A successful source verification is always HOLD,
not permission, family approval, production integration, or deployment.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

PINNED = {
    "joy_md": ("JOY", "FAMILY/receipts/ALABAMA_ALMS_BOSS_BRE_LIBRARIAN_HEIDEE_MERGE_V0_1.md", "de6c243360ba289d71906421ff7b80342f6ca0c2"),
    "joy_index": ("JOY", "FAMILY/receipts/ALABAMA_ALMS_BOSS_BRE_LIBRARIAN_HEIDEE_MERGE_INDEX_V0_1.json", "d65a71e5b075ad41123de06fd29c84a47423a02c"),
    "joy_checker": ("JOY", "FAMILY/receipts/replay_alabama_alms_role_membrane_v0_1.sh", "bad2265dc2ef4bf0a811ed96cf0533a72f5d6d3f"),
    "al_pointer": ("AL", "ALMS/vernacular/ALABAMA_ALMS_JOY_ROLE_MEMBRANE_POINTER_V0_1.md", "0a2aef8f15a217d6af611ab46e94089306cf6f09"),
    "al_multipass": ("AL", "constitution/multipass/LEELOO_DALLAS_MULTIPASS_V0_1.md", "3e0e2d459bfa1a02001e22e6d813e41bc3af73d3"),
}
PRIORITY = ("REJECT", "CONFLICT", "HOLD", "PASS")
REQUIRED_MD = (
    "MERGE_BRIDGE_ACTIVE", "ALABAMA_ALMS_REPLAY_ENGINE_LINKED",
    "BOSS_BRE_FAMILY_SIDE_LINKED", "LIBRARIAN_SUGGESTION_LAYER_LINKED",
    "HEIDEE_JOY_TRAINING_PURPOSE_LINKED", "FAMILY_GATE_SOVEREIGN",
    "AUTHORITY_FALSE", "NO_FAKE_GREEN_ACTIVE", "MERGE != FAMILY_APPROVAL",
    "MERGE != CHILD_CONSENT", "MERGE != AUTHORITY_TRUE",
    "MERGE != BACKGROUND_MONITORING",
)
REQUIRED_BOUNDARIES = (
    "MERGE != FAMILY_APPROVAL", "MERGE != CHILD_CONSENT",
    "MERGE != MRS_WISDOM_GATE_PASS", "MERGE != AUTHORITY_TRUE",
    "MERGE != PRIVATE_CHILD_DATA_PUBLICATION",
    "MERGE != BACKGROUND_MONITORING",
)

class GateRejected(ValueError):
    pass


def git_blob_sha1(raw):
    return hashlib.sha1(b"blob " + str(len(raw)).encode("ascii") + b"\0" + raw).hexdigest()


def pairs_without_duplicates(pairs):
    obj = {}
    for key, value in pairs:
        if key in obj:
            raise GateRejected("duplicate_json_key")
        obj[key] = value
    return obj


def parse_json_strict(raw):
    def bad_constant(_):
        raise GateRejected("invalid_json_constant")
    try:
        return json.loads(raw.decode("utf-8"), object_pairs_hook=pairs_without_duplicates, parse_constant=bad_constant)
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise GateRejected("malformed_json") from exc


def require(condition, reason):
    if not condition:
        raise GateRejected(reason)


def validate_index(index):
    require(type(index) is dict, "index_not_object")
    require(index.get("schema_version") == "ALABAMA_ALMS_BOSS_BRE_LIBRARIAN_HEIDEE_MERGE_INDEX_V0_1", "schema_mismatch")
    require(index.get("repo") == "jsonwisdom/JOY", "repo_mismatch")
    require(index.get("status") == "V0_1_LIVE", "status_mismatch")
    md = index.get("md_receipt")
    require(type(md) is dict and md.get("content_sha") == PINNED["joy_md"][2], "md_pointer_drift")
    ap = index.get("al_pointer")
    require(type(ap) is dict and ap.get("content_sha") == PINNED["al_pointer"][2] and ap.get("repo") == "jsonwisdom/AL", "al_pointer_drift")
    state = index.get("field_state")
    require(type(state) is dict, "missing_field_state")
    for key, expected in {"merge_bridge": "ACTIVE", "family_gate": "SOVEREIGN"}.items():
        require(type(state.get(key)) is str and state[key] == expected, "bad_" + key)
    for key, expected in {"authority": False, "verified": False, "private_child_data_publication": False, "background_monitoring": False, "no_fake_green": True}.items():
        require(type(state.get(key)) is bool and state[key] is expected, "bad_" + key)
    roles = index.get("roles")
    require(type(roles) is dict and type(roles.get("heidee_joy")) is dict, "heidee_role_missing")
    require(roles["heidee_joy"].get("authority") is False and roles["heidee_joy"].get("verified") is False, "heidee_autonomy_violation")
    require(type(index.get("routing")) is list and index["routing"][-1:] == ["RESOLUTION_ONLY"], "routing_invalid")
    boundaries = index.get("hard_boundaries")
    require(type(boundaries) is list and all(x in boundaries for x in REQUIRED_BOUNDARIES), "family_boundaries_missing")
    return True


def aggregate(states):
    if type(states) not in (list, tuple) or not states:
        return "REJECT"
    if any(type(s) is not str or s not in PRIORITY for s in states):
        return "REJECT"
    return next(status for status in PRIORITY if status in states)


def canonical_bytes(value):
    return json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode("utf-8")


def verify(joy_root, al_root):
    roots = {"JOY": Path(joy_root), "AL": Path(al_root)}
    content = {}
    sources = []
    for label, (repo, rel, expected) in PINNED.items():
        path = roots[repo] / rel
        try:
            raw = path.read_bytes()
        except OSError as exc:
            raise GateRejected("missing_source_" + label) from exc
        actual = git_blob_sha1(raw)
        require(actual == expected, "git_blob_mismatch_" + label)
        try:
            content[label] = raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise GateRejected("invalid_utf8_" + label) from exc
        sources.append({"label": label, "repo": "jsonwisdom/" + repo, "path": rel,
                        "git_blob_sha1": actual, "sha256": hashlib.sha256(raw).hexdigest()})
    for marker in REQUIRED_MD:
        require(marker in content["joy_md"], "missing_md_marker")
    require("AL_POINTER != FAMILY_APPROVAL" in content["al_pointer"], "al_family_boundary_missing")
    require("PRECEDENT_BOUND_PENDING_COMMIT" in content["al_multipass"], "al_multipass_provenance_missing")
    require("Human approval is required for state transitions." in content["al_multipass"], "human_approval_missing")
    require("ROLE_MEMBRANE_REPLAY_OK" in content["joy_checker"], "checker_marker_missing")
    validate_index(parse_json_strict(content["joy_index"].encode("utf-8")))
    return sources


def create_receipt(status, reasons, sources):
    receipt = {"schema": "JOY_LEELOO_PROOF_005_V1", "authority": False,
               "family_approval": False, "heidee_consent": "NOT_INFERRED",
               "leahprime_runtime": "HOLD", "production_integration": "HOLD",
               "source_verification": status, "effective_decision": "REJECT" if status == "REJECT" else "HOLD",
               "reasons": reasons, "sources": sources}
    receipt["receipt_sha256"] = hashlib.sha256(canonical_bytes(receipt)).hexdigest()
    return receipt


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--joy-root", required=True)
    ap.add_argument("--al-root", required=True)
    ap.add_argument("--receipt", help="write deterministic public-safe JSON receipt")
    args = ap.parse_args(argv)
    try:
        sources = verify(args.joy_root, args.al_root)
        receipt = create_receipt("PASS", ["source_pins_verified", "no_executable_leeloo_link", "no_human_gate_approval"], sources)
        exit_code = 0
    except GateRejected as exc:
        receipt = create_receipt("REJECT", [str(exc)], [])
        exit_code = 2
    print("SOURCE_VERIFICATION=" + receipt["source_verification"])
    print("EFFECTIVE_DECISION=" + receipt["effective_decision"])
    print("AUTHORITY=false; FAMILY_APPROVAL=false; LIVE_INTEGRATION=HOLD")
    print("RECEIPT_SHA256=" + receipt["receipt_sha256"])
    if args.receipt:
        Path(args.receipt).write_bytes(canonical_bytes(receipt) + b"\n")
    return exit_code

if __name__ == "__main__":
    sys.exit(main())
