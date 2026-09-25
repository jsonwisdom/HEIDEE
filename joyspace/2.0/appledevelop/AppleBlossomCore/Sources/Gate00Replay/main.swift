import Foundation
import AppleBlossomCore

@main
struct Gate00Replay {
    static func main() async throws {
        let store = InMemoryReceiptStore()
        let provider = DeterministicFixtureProvider()
        let initialSession = "GATE00_SESSION_A"
        let nextSession = "GATE00_SESSION_B"

        let engine = AppleBlossomEngine(
            sessionID: initialSession,
            provider: provider,
            receiptSink: store
        )

        let round = try await engine.startRound(text: "I love this.", inputKind: .fixture)
        _ = await engine.confirmMeaning()
        let ejectReceipt = await engine.ejectSession(nextSessionID: nextSession)
        let postEjectRound = try await engine.startRound(text: "I love this.", inputKind: .fixture)
        let receipts = await engine.receipts()
        let state = await engine.snapshot()

        let gateReceipt = Gate00Receipt(
            disposition: .pass,
            externalProviderActive: provider.capabilities.externalProvider,
            networkRequired: provider.capabilities.requiresNetwork,
            microphoneRequired: provider.capabilities.requiresMicrophone,
            foundationModelRequired: false,
            fallbackUsed: round.receipt.fallbackUsed,
            receiptCreated: !receipts.isEmpty,
            rawAudioPersistence: AudioPrivacyContract.v0_1.rawAudioPersistence,
            initialSessionID: initialSession,
            ejectedSessionID: ejectReceipt.sessionID,
            postEjectSessionID: state.sessionID,
            oldSessionReactivated: state.sessionID == initialSession,
            postEjectRoundCompleted: postEjectRound.receipt.disposition == .pass
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(gateReceipt)
        FileHandle.standardOutput.write(data)
        FileHandle.standardOutput.write(Data("\n".utf8))
    }
}
