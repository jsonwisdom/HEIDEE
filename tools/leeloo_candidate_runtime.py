#!/usr/bin/env python3
"""Proof 007 — offline, public-safe candidate executable LeeLoo decision membrane.

This is a NEW proposed interface. It is NOT the original LeeLoo service and
does NOT authenticate humans, authorize transfers, enroll children, or run agents.
Source verification PASS can produce at most EFFECTIVE_DECISION=HOLD.
"""
import argparse
import hashlib
import sys
from pathlib import Path

from joy_leeloo_adapter import (
    GateRejected, aggregate, canonical_bytes, git_blob_sha1,
    parse_json_strict, require, verify,
)

REQUEST_SCHEMA = "leeloo/review-candidate/1"
RECEIPT_SCHEMA = "joyspace/proof007/1"
LANES = (
    "computer_wisdom_public",
    "joy_wisdom_public",
    "al_wisdom_public",
    "replay_trinity",
)
PROTOCOL_PATH = "constitution/multipass/LEELOO_DALLAS_MULTIPASS_V0_1.md"
RECEIPT_PATH = "receipts/multipass/EV-009-LEELOO-DALLAS-MULTIPASS-RECEIPT.json"
PROTOCOL_BLOB = "3e0e2d459bfa1a02001e22e6d813e41bc3af73d3"
RECEIPT_BLOB = "328daab27376dd70a1299b4ba08becaa55e4caa1"
PROTOCOL_SHA256 = "2f619d628e86cc8d6a6bedad45e2762b33a088445ac761b9ba0b9764cff0884b"
MAX_REQUEST_BYTES = 4096


def validate_request(req):
    require(type(req) is dict, "request_not_object")
    require(set(req) == {
        "schema", "family_gate", "authority", "human_approval",
        "heidee_consent", "lanes",
    }, "request_keys_invalid")
    require(req["schema"] == REQUEST_SCHEMA, "request_schema_mismatch")
    require(type(req["family_gate"]) is str and req["family_gate"] == "SOVEREIGN", "family_gate_invalid")
    require(type(req["authority"]) is bool and req["authority"] is False, "authority_not_false")
    require(req["human_approval"] == "NOT_GRANTED", "human_approval_unverified")
    require(req["heidee_consent"] == "NOT_INFERRED", "heidee_consent_unverified")
    lanes = req["lanes"]
    require(type(lanes) is dict and set(lanes) == set(LANES), "lane_set_invalid")
    require(all(type(lanes[k]) is str and lanes[k] in ("REJECT", "CONFLICT", "HOLD", "PASS") for k in LANES), "invalid_lane_state")
    return aggregate([lanes[k] for k in LANES])


def verify_ev009(al_root):
    root = Path(al_root)
    try:
        protocol_bytes = (root / PROTOCOL_PATH).read_bytes()
        receipt_bytes = (root / RECEIPT_PATH).read_bytes()
    except OSError as exc:
        raise GateRejected("ev009_source_missing") from exc
    require(git_blob_sha1(protocol_bytes) == PROTOCOL_BLOB, "ev009_protocol_git_blob_drift")
    require(git_blob_sha1(receipt_bytes) == RECEIPT_BLOB, "ev009_receipt_git_blob_drift")
    raw_sha256 = hashlib.sha256(protocol_bytes).hexdigest()
    require(raw_sha256 == PROTOCOL_SHA256, "ev009_protocol_sha256_mismatch")
    record = parse_json_strict(receipt_bytes)
    require(type(record) is dict and set(record) == {
        "docket", "artifact", "path", "sha256", "status",
        "no_fake_green", "human_approval_required",
    }, "ev009_receipt_schema_invalid")
    require(record["docket"] == "EV-009" and
            record["artifact"] == "LEELOO_DALLAS_MULTIPASS_V0_1" and
            record["path"] == PROTOCOL_PATH, "ev009_identity_mismatch")
    require(record["sha256"] == raw_sha256, "ev009_receipt_digest_mismatch")
    require(record["status"] == "PRECEDENT_BOUND_PENDING_PUBLIC_GREEN", "ev009_status_invalid")
    require(record["no_fake_green"] is True and record["human_approval_required"] is True,
            "ev009_approval_boundary_invalid")
    return {
        "docket": "EV-009",
        "protocol_git_blob_sha1": PROTOCOL_BLOB,
        "protocol_sha256": raw_sha256,
        "receipt_git_blob_sha1": RECEIPT_BLOB,
        "status": record["status"],
    }


def make_result(candidate_state="REJECT", reason="invalid_or_unverified", ev009=None):
    require(candidate_state in ("REJECT", "CONFLICT", "HOLD", "PASS"), "internal_bad_state")
    effective = candidate_state if candidate_state != "PASS" else "HOLD"
    result = {
        "schema": RECEIPT_SCHEMA,
        "interface": "CANDIDATE_EXECUTABLE_ONLY",
        "candidate_state": candidate_state,
        "effective_decision": effective,
        "authority": False,
        "family_approval": False,
        "heidee_consent": "NOT_INFERRED",
        "human_approval": "NOT_GRANTED",
        "leahprime_runtime": "HOLD",
        "live_leeloo_integration": "HOLD",
        "deployment": "NONE",
        "reason": reason,
        "ev009": ev009,
    }
    result["receipt_sha256"] = hashlib.sha256(canonical_bytes(result)).hexdigest()
    return result


def execute(request_bytes, joy_root, al_root):
    try:
        require(len(request_bytes) <= MAX_REQUEST_BYTES, "request_too_large")
        parsed = parse_json_strict(request_bytes)
        candidate_state = validate_request(parsed)
        # Previous source checker and original provenance must BOTH pass.
        verify(joy_root, al_root)
        ev009 = verify_ev009(al_root)
        return make_result(
            candidate_state,
            "all_lanes_pass_but_human_approval_absent" if candidate_state == "PASS"
            else "four_state_decision_preserved",
            ev009,
        )
    except GateRejected as exc:
        return make_result(reason=str(exc))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request", required=True, help="local synthetic JSON only")
    parser.add_argument("--joy-root", required=True)
    parser.add_argument("--al-root", required=True)
    parser.add_argument("--receipt", help="write deterministic public-safe receipt")
    args = parser.parse_args(argv)
    try:
        request_bytes = Path(args.request).read_bytes()
    except OSError:
        request_bytes = b""
    result = execute(request_bytes, args.joy_root, args.al_root)
    print("INTERFACE=CANDIDATE_EXECUTABLE_ONLY")
    print("CANDIDATE_STATE=" + result["candidate_state"])
    print("EFFECTIVE_DECISION=" + result["effective_decision"])
    print("AUTHORITY=false; HEIDEE_CONSENT=NOT_INFERRED; LIVE_LEELOO_INTEGRATION=HOLD")
    print("RECEIPT_SHA256=" + result["receipt_sha256"])
    if args.receipt:
        try:
            Path(args.receipt).write_bytes(canonical_bytes(result) + b"\n")
        except OSError:
            return 2
    return {"REJECT": 2, "CONFLICT": 3, "HOLD": 0, "PASS": 2}[result["effective_decision"]]


if __name__ == "__main__":
    sys.exit(main())
