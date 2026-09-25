#!/usr/bin/env python3
"""Deterministic Atomic Family checkpoint verifier v0.1.

Usage:
  python joyspace/2.0/replay/verify_atomic_family_checkpoint_v0_1.py \
    joyspace/2.0/replay/fixtures/atomic_family_divergence_A7_B4_C9_v0_1.json

No network access, no external dependencies, no mutation of the input fixture.
"""

from __future__ import annotations

import json
import sys
from itertools import combinations
from pathlib import Path


def fail(message: str) -> None:
    raise SystemExit(f"VERIFY_REJECT: {message}")


def verify(fixture: dict) -> dict:
    if fixture.get("schema") != "ATOMIC_FAMILY_EXCHANGE_CHECKPOINT_V0_1":
        fail("unexpected schema")
    if fixture.get("authority_created") is not False:
        fail("authority_created must be false")

    policy = fixture.get("exchange_policy", {})
    if policy.get("auto_global_merge") is not False:
        fail("auto_global_merge must be false")
    if policy.get("divergence_policy") != "PRESERVE":
        fail("divergence_policy must be PRESERVE")

    nodes = fixture.get("nodes")
    if not isinstance(nodes, list) or len(nodes) < 2:
        fail("at least two nodes are required")

    node_ids = [node.get("node_id") for node in nodes]
    if len(set(node_ids)) != len(node_ids):
        fail("node_id values must be unique")

    before = {node["node_id"]: node["version"] for node in nodes}
    hashes = {node["node_id"]: node["content_hash"] for node in nodes}

    states = {(node["version"], node["content_hash"]) for node in nodes}
    disposition = "MATCH" if len(states) == 1 else "DIFFERENCE_RECEIPT"

    differences = []
    for left, right in combinations(nodes, 2):
        differences.append(
            {
                "left": left["node_id"],
                "right": right["node_id"],
                "version_delta": left["version"] - right["version"],
                "same_version": left["version"] == right["version"],
                "same_hash": left["content_hash"] == right["content_hash"],
            }
        )

    # The verifier never mutates node state. Snapshot again to prove it.
    after = {node["node_id"]: node["version"] for node in nodes}
    unchanged = before == after
    if not unchanged:
        fail("node versions changed during verification")

    expected = fixture.get("expected_result", {})
    if expected.get("disposition") != disposition:
        fail(
            f"expected disposition {expected.get('disposition')!r} "
            f"but verifier produced {disposition!r}"
        )
    if expected.get("auto_merge_performed") is not False:
        fail("fixture must expect auto_merge_performed=false")
    if expected.get("post_versions_unchanged") is not True:
        fail("fixture must expect post_versions_unchanged=true")

    return {
        "schema": "ATOMIC_FAMILY_DIFFERENCE_RECEIPT_V0_1",
        "version": "0.1.0",
        "event_id": fixture["event_id"],
        "replayed_at": fixture["observed_at"],
        "vcr_action": fixture["vcr_action"],
        "checkpoint_id": fixture["checkpoint"]["checkpoint_id"],
        "disposition": disposition,
        "node_versions_before": before,
        "node_hashes": hashes,
        "differences": differences,
        "auto_merge_performed": False,
        "node_versions_after": after,
        "post_versions_unchanged": unchanged,
        "divergence_preserved": True,
        "reconciliation": policy.get("reconciliation"),
        "authority_created": False,
    }


def main() -> None:
    if len(sys.argv) != 2:
        fail("provide exactly one fixture path")

    fixture_path = Path(sys.argv[1])
    fixture = json.loads(fixture_path.read_text(encoding="utf-8"))
    receipt = verify(fixture)
    print(json.dumps(receipt, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
