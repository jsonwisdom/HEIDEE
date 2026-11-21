import copy
import json
import unittest
from unittest.mock import patch

from joy_leeloo_adapter import GateRejected
from leeloo_candidate_runtime import (
    LANES, MAX_REQUEST_BYTES, RECEIPT_SCHEMA, REQUEST_SCHEMA,
    execute, make_result, validate_request,
)

def good_request():
    return {
        "schema": REQUEST_SCHEMA,
        "family_gate": "SOVEREIGN",
        "authority": False,
        "human_approval": "NOT_GRANTED",
        "heidee_consent": "NOT_INFERRED",
        "lanes": {key: "PASS" for key in LANES},
    }

def raw(x):
    return json.dumps(x, separators=(",", ":")).encode("utf-8")

class RequestValidation(unittest.TestCase):
    def test_four_pass(self):
        self.assertEqual(validate_request(good_request()), "PASS")

    def test_hold_over_pass(self):
        r=good_request();r["lanes"]["replay_trinity"]="HOLD"
        self.assertEqual(validate_request(r), "HOLD")

    def test_conflict_over_hold(self):
        r=good_request()
        r["lanes"]["al_wisdom_public"]="HOLD"
        r["lanes"]["joy_wisdom_public"]="CONFLICT"
        self.assertEqual(validate_request(r), "CONFLICT")

    def test_reject_over_conflict(self):
        r=good_request()
        r["lanes"]["replay_trinity"]="CONFLICT"
        r["lanes"]["joy_wisdom_public"]="REJECT"
        self.assertEqual(validate_request(r), "REJECT")

    def test_corrupt_family_gate(self):
        r=good_request();r["family_gate"]="BYPASSED"
        with self.assertRaisesRegex(GateRejected,"family_gate_invalid"): validate_request(r)

    def test_wrong_bool_authority(self):
        r=good_request();r["authority"]="false"
        with self.assertRaisesRegex(GateRejected,"authority_not_false"): validate_request(r)

    def test_true_authority(self):
        r=good_request();r["authority"]=True
        with self.assertRaises(GateRejected): validate_request(r)

    def test_fake_human_approval(self):
        r=good_request();r["human_approval"]="GRANTED"
        with self.assertRaises(GateRejected): validate_request(r)

    def test_fake_heidee_consent(self):
        r=good_request();r["heidee_consent"]="GRANTED"
        with self.assertRaises(GateRejected): validate_request(r)

    def test_missing_lane(self):
        r=good_request();r["lanes"].pop("joy_wisdom_public")
        with self.assertRaises(GateRejected): validate_request(r)

    def test_extra_lane(self):
        r=good_request();r["lanes"]["private_child"]= "PASS"
        with self.assertRaises(GateRejected): validate_request(r)

    def test_extra_request_key_rejected(self):
        r=good_request();r["private_name"]="SENSITIVE"
        with self.assertRaises(GateRejected): validate_request(r)

    def test_unknown_lane_state(self):
        r=good_request();r["lanes"]["al_wisdom_public"]="GREEN"
        with self.assertRaises(GateRejected): validate_request(r)

class ExecutionBoundaries(unittest.TestCase):
    def run_mocked(self, value):
        with patch("leeloo_candidate_runtime.verify", return_value=[]), \
             patch("leeloo_candidate_runtime.verify_ev009",
                   return_value={"docket":"EV-009","status":"PRECEDENT_BOUND_PENDING_PUBLIC_GREEN"}):
            return execute(raw(value), "not-used", "not-used")

    def test_good_input_mechanical_pass_effective_hold(self):
        output=self.run_mocked(good_request())
        self.assertEqual(output["candidate_state"],"PASS")
        self.assertEqual(output["effective_decision"],"HOLD")
        self.assertIs(output["authority"],False)
        self.assertIs(output["family_approval"],False)
        self.assertEqual(output["live_leeloo_integration"],"HOLD")

    def test_corruption_reject(self):
        r=good_request();r["family_gate"]="BYPASSED"
        output=self.run_mocked(r)
        self.assertEqual(output["effective_decision"],"REJECT")
        self.assertIsNone(output["ev009"])

    def test_reject_does_not_downgrade(self):
        r=good_request();r["lanes"]["al_wisdom_public"]="REJECT"
        output=self.run_mocked(r)
        self.assertEqual(output["effective_decision"],"REJECT")

    def test_conflict_does_not_downgrade(self):
        r=good_request();r["lanes"]["al_wisdom_public"]="CONFLICT"
        output=self.run_mocked(r)
        self.assertEqual(output["effective_decision"],"CONFLICT")

    def test_duplicate_json_reject(self):
        raw_request=b'{"schema":"x","schema":"y"}'
        self.assertEqual(execute(raw_request,".",".")["effective_decision"],"REJECT")

    def test_nan_reject(self):
        self.assertEqual(execute(b'{"x":NaN}',".",".")["effective_decision"],"REJECT")

    def test_oversize_reject(self):
        self.assertEqual(execute(b'x'*(MAX_REQUEST_BYTES+1),".",".")["effective_decision"],"REJECT")

    def test_missing_source_reject(self):
        self.assertEqual(execute(raw(good_request()),"/missing/joy","/missing/al")["effective_decision"],"REJECT")

    def test_provenance_drift_reject(self):
        with patch("leeloo_candidate_runtime.verify",side_effect=GateRejected("git_blob_mismatch_joy_md")):
            o=execute(raw(good_request()),".",".")
        self.assertEqual(o["effective_decision"],"REJECT")

    def test_ev009_digest_drift_reject(self):
        with patch("leeloo_candidate_runtime.verify",return_value=[]),\
             patch("leeloo_candidate_runtime.verify_ev009",side_effect=GateRejected("ev009_receipt_digest_mismatch")):
            o=execute(raw(good_request()),".",".")
        self.assertEqual(o["effective_decision"],"REJECT")

    def test_hash_determinism(self):
        self.assertEqual(make_result("PASS","source_verified"),make_result("PASS","source_verified"))

    def test_public_safe_receipt_no_family_payload(self):
        r=good_request();r["private_name"]="SECRET_VALUE"
        o=self.run_mocked(r)
        self.assertNotIn("SECRET_VALUE",json.dumps(o))
        self.assertEqual(o["schema"],RECEIPT_SCHEMA)

if __name__=="__main__":
    unittest.main(verbosity=2)
