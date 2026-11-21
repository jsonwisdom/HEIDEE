import copy
import json
import tempfile
import unittest
from pathlib import Path
from joy_leeloo_adapter import (GateRejected, PINNED, aggregate, create_receipt,
                                git_blob_sha1, parse_json_strict, validate_index, verify)

class Decisions(unittest.TestCase):
    def test_all_pass(self): self.assertEqual(aggregate(["PASS", "PASS"]), "PASS")
    def test_hold_over_pass(self): self.assertEqual(aggregate(["PASS", "HOLD"]), "HOLD")
    def test_conflict_over_hold(self): self.assertEqual(aggregate(["HOLD", "CONFLICT"]), "CONFLICT")
    def test_reject_over_conflict(self): self.assertEqual(aggregate(["CONFLICT", "REJECT"]), "REJECT")
    def test_empty_rejected(self): self.assertEqual(aggregate([]), "REJECT")
    def test_unknown_rejected(self): self.assertEqual(aggregate(["GREEN"]), "REJECT")
    def test_lowercase_rejected(self): self.assertEqual(aggregate(["pass"]), "REJECT")
    def test_nonstring_rejected(self): self.assertEqual(aggregate(["PASS", True]), "REJECT")
    def test_nonlist_rejected(self): self.assertEqual(aggregate("PASS"), "REJECT")

class Gate(unittest.TestCase):
    def sample(self):
        return {"schema_version":"ALABAMA_ALMS_BOSS_BRE_LIBRARIAN_HEIDEE_MERGE_INDEX_V0_1",
          "repo":"jsonwisdom/JOY", "status":"V0_1_LIVE",
          "md_receipt":{"content_sha":PINNED["joy_md"][2]},
          "al_pointer":{"content_sha":PINNED["al_pointer"][2],"repo":"jsonwisdom/AL"},
          "field_state":{"merge_bridge":"ACTIVE","family_gate":"SOVEREIGN",
                         "authority":False,"verified":False,"private_child_data_publication":False,
                         "background_monitoring":False,"no_fake_green":True},
          "roles":{"heidee_joy":{"authority":False,"verified":False}},
          "routing":["FAMILY_GATE_SOVEREIGN_BOUNDARY","RESOLUTION_ONLY"],
          "hard_boundaries":["MERGE != FAMILY_APPROVAL","MERGE != CHILD_CONSENT",
           "MERGE != MRS_WISDOM_GATE_PASS","MERGE != AUTHORITY_TRUE",
           "MERGE != PRIVATE_CHILD_DATA_PUBLICATION","MERGE != BACKGROUND_MONITORING"]}
    def test_valid_gate(self): self.assertTrue(validate_index(self.sample()))
    def test_duplicate_key(self):
        with self.assertRaisesRegex(GateRejected,"duplicate_json_key"):
            parse_json_strict(b'{"authority":false,"authority":true}')
    def test_malformed_json(self):
        with self.assertRaisesRegex(GateRejected,"malformed_json"):
            parse_json_strict(b'{')
    def test_nan_rejected(self):
        with self.assertRaisesRegex(GateRejected,"invalid_json_constant"):
            parse_json_strict(b'{"x":NaN}')
    def test_authority_true(self):
        data=self.sample();data["field_state"]["authority"]=True
        with self.assertRaises(GateRejected): validate_index(data)
    def test_string_false_rejected(self):
        data=self.sample();data["field_state"]["authority"]="false"
        with self.assertRaises(GateRejected): validate_index(data)
    def test_family_gate_corrupted(self):
        data=self.sample();data["field_state"]["family_gate"]="BYPASSED"
        with self.assertRaises(GateRejected): validate_index(data)
    def test_heidee_authority_true(self):
        data=self.sample();data["roles"]["heidee_joy"]["authority"]=True
        with self.assertRaises(GateRejected): validate_index(data)
    def test_privacy_violation(self):
        data=self.sample();data["field_state"]["private_child_data_publication"]=True
        with self.assertRaises(GateRejected): validate_index(data)
    def test_background_monitoring(self):
        data=self.sample();data["field_state"]["background_monitoring"]=True
        with self.assertRaises(GateRejected): validate_index(data)
    def test_pointer_drift(self):
        data=self.sample();data["al_pointer"]["content_sha"]="0"*40
        with self.assertRaises(GateRejected): validate_index(data)
    def test_missing_boundary(self):
        data=self.sample();data["hard_boundaries"].remove("MERGE != CHILD_CONSENT")
        with self.assertRaises(GateRejected): validate_index(data)
    def test_bad_git_blob(self): self.assertEqual(git_blob_sha1(b"test\n"),"9daeafb9864cf43055ae93beb0afd6c7d144bfa4")
    def test_missing_real_sources_fail_closed(self):
        with tempfile.TemporaryDirectory() as td:
            with self.assertRaisesRegex(GateRejected,"missing_source_joy_md"):
                verify(td,td)
    def test_human_gate_cannot_be_promoted(self):
        receipt=create_receipt("PASS",["pins_verified"],[])
        self.assertEqual(receipt["effective_decision"],"HOLD")
        self.assertIs(receipt["authority"],False)
        self.assertIs(receipt["family_approval"],False)
    def test_deterministic_receipt(self):
        a=create_receipt("PASS",["pins_verified"],[])
        b=create_receipt("PASS",["pins_verified"],[])
        self.assertEqual(a,b)

if __name__ == '__main__': unittest.main(verbosity=2)
