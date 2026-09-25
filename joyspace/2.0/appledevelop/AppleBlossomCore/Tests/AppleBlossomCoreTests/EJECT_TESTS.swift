import Testing
@testable import AppleBlossomCore

@Suite("AppleBlossomEjectTests")
struct AppleBlossomEjectTests {
    @Test("EJECT rotates the active session and does not reactivate the old session")
    func ejectRotatesSession() async throws {
        let store = InMemoryReceiptStore()
        let engine = AppleBlossomEngine(
            sessionID: "GATE01_SESSION_OLD",
            provider: DeterministicFixtureProvider(),
            receiptSink: store
        )

        _ = try await engine.startRound(text: "I love this.", inputKind: .fixture)
        let eject = await engine.ejectSession(nextSessionID: "GATE01_SESSION_NEW")

        #expect(eject.sessionID == "GATE01_SESSION_OLD")

        let afterEject = await engine.snapshot()
        #expect(afterEject.sessionID == "GATE01_SESSION_NEW")
        #expect(afterEject.ejected == true)

        let nextRound = try await engine.startRound(text: "I love this.", inputKind: .fixture)
        #expect(nextRound.receipt.sessionID == "GATE01_SESSION_NEW")
        #expect(nextRound.receipt.sessionID != "GATE01_SESSION_OLD")
        #expect(nextRound.receipt.authorityCreated == false)
    }

    @Test("Explicit replay after EJECT references old provenance without restoring the old session")
    func replayAfterEjectPreservesCurrentSession() async throws {
        let store = InMemoryReceiptStore()
        let engine = AppleBlossomEngine(
            sessionID: "GATE01_SOURCE_SESSION",
            provider: DeterministicFixtureProvider(),
            receiptSink: store
        )

        _ = try await engine.startRound(text: "I love this.", inputKind: .fixture)
        _ = await engine.ejectSession(nextSessionID: "GATE01_AFTER_EJECT")

        let replay = await engine.replayLastRound()
        #expect(replay != nil)
        #expect(replay?.receipt.sessionID == "GATE01_AFTER_EJECT")
        #expect(replay?.receipt.sourceSessionID == "GATE01_SOURCE_SESSION")
        #expect(replay?.receipt.sessionID != replay?.receipt.sourceSessionID)
        #expect(replay?.receipt.authorityCreated == false)
    }
}
