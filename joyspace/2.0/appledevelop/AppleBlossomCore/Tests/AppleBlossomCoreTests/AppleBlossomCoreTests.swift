import Testing
@testable import AppleBlossomCore

@Test("Gate 00 deterministic fallback is networkless, micless, external-provider-free, and receipted")
func gate00Fallback() async throws {
    let store = InMemoryReceiptStore()
    let provider = DeterministicFixtureProvider()
    let engine = AppleBlossomEngine(
        sessionID: "TEST_SESSION_A",
        provider: provider,
        receiptSink: store
    )

    #expect(provider.capabilities.requiresNetwork == false)
    #expect(provider.capabilities.requiresMicrophone == false)
    #expect(provider.capabilities.externalProvider == false)
    #expect(AudioPrivacyContract.v0_1.rawAudioPersistence == .memoryOnlyNeverDisk)

    let result = try await engine.startRound(text: "I love this.", inputKind: .fixture)
    #expect(result.state.translatedPhrase == "Me encanta esto.")
    #expect(result.receipt.fallbackUsed == true)
    #expect(result.receipt.disposition == .pass)
    #expect(result.receipt.authorityCreated == false)

    let receipts = await engine.receipts()
    #expect(receipts.count == 1)
}

@Test("Eject rotates the session and later start does not reactivate the ejected session")
func ejectThenStart() async throws {
    let store = InMemoryReceiptStore()
    let engine = AppleBlossomEngine(
        sessionID: "SESSION_OLD",
        provider: DeterministicFixtureProvider(),
        receiptSink: store
    )

    _ = try await engine.startRound(text: "I love this.", inputKind: .fixture)
    let eject = await engine.ejectSession(nextSessionID: "SESSION_NEW")
    #expect(eject.sessionID == "SESSION_OLD")

    let afterEject = await engine.snapshot()
    #expect(afterEject.sessionID == "SESSION_NEW")
    #expect(afterEject.ejected == true)

    let nextRound = try await engine.startRound(text: "I love this.", inputKind: .fixture)
    #expect(nextRound.receipt.sessionID == "SESSION_NEW")
    #expect(nextRound.receipt.sessionID != "SESSION_OLD")
}

@Test("Explicit replay after eject keeps the new session and references the old source session")
func replayAfterEject() async throws {
    let store = InMemoryReceiptStore()
    let engine = AppleBlossomEngine(
        sessionID: "SESSION_SOURCE",
        provider: DeterministicFixtureProvider(),
        receiptSink: store
    )

    _ = try await engine.startRound(text: "I love this.", inputKind: .fixture)
    _ = await engine.ejectSession(nextSessionID: "SESSION_AFTER_EJECT")

    let replay = await engine.replayLastRound()
    #expect(replay != nil)
    #expect(replay?.receipt.sessionID == "SESSION_AFTER_EJECT")
    #expect(replay?.receipt.sourceSessionID == "SESSION_SOURCE")
    #expect(replay?.receipt.sessionID != replay?.receipt.sourceSessionID)
}
