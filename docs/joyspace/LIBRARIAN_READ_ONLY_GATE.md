# HEIDEE JoySpace — Librarian Read-Only Verification

This is a **source-only verification gate**, not a child profile, publication approval, or deployment. JoySpace belongs to the HEIDEE repository. JOY may link to sources and suggest verification paths, but cannot acquire child publishing or account authority.

The Librarian's role is **Acknowledge → Locate → Membrane-check → Suggest**, not a final judge or autonomous publisher. It asks for a source, a receipt, and a stop condition.

Run from the HEIDEE repository root:

    python3 tests/joyspace_librarian_gate.py
    node SCHOOL_OF_WISDOM_LYRICAL_AUDIT_TEST.mjs

The Python checker confirms source markers and source SHA-256 digests for the creative drawing page, PDF comparison page, and README. It rejects external script declarations, forms, obvious network API calls and automatic off-site resources in the two source HTML documents. The Node tests execute an existing School of Wisdom Worker against synthetic Request objects.

**Limitations:** Static source analysis is not a browser usability, accessibility, behavioral, security, or public deployment audit. Source-content markers are not evidence of parental consent. The Node test is separate from the drawing and PDF pages and cannot certify those browser workflows. Navigation links to official document publishers are permitted; none of these static checks proves no network interactions occur at runtime. Manual real-device check and independent HTTP readback remain OPEN.

The child-facing page has not been modified by this gate. Do not publish art, profiles, or private details. Adult approval remains separate.

LOCAL_SOURCE_GATE=TESTABLE
PUBLIC_GREEN=false
AUTHORITY_CREATED=false
DEPLOYMENT=false
PRODUCTION_WRITE=false
EXTERNAL_ANCHOR=false
