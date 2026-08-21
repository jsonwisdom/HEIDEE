import Foundation

public enum EvidenceDisposition: String, Codable, Sendable {
    case pass = "PASS"
    case hold = "HOLD"
    case conflict = "CONFLICT"
    case reject = "REJECT"
}

public enum RoundInputKind: String, Codable, Sendable {
    case fixture = "FIXTURE"
    case typed = "TYPED"
    case transcript = "TRANSCRIPT"
}

public enum RawAudioPersistencePolicy: String, Codable, Sendable {
    /// Raw audio may exist only in volatile memory while capture/transcription is active.
    /// The application must never intentionally write the raw audio buffer to disk,
    /// including temporary files, caches, Application Support, or receipts.
    case memoryOnlyNeverDisk = "MEMORY_ONLY_NEVER_DISK"
}

public struct AudioPrivacyContract: Codable, Equatable, Sendable {
    public let rawAudioPersistence: RawAudioPersistencePolicy
    public let crashBehavior: String

    public init(
        rawAudioPersistence: RawAudioPersistencePolicy = .memoryOnlyNeverDisk,
        crashBehavior: String = "RAW_AUDIO_MAY_BE_LOST_ON_CRASH_AND_MUST_NOT_BE_RECOVERABLE_FROM_APP_DISK"
    ) {
        self.rawAudioPersistence = rawAudioPersistence
        self.crashBehavior = crashBehavior
    }

    public static let v0_1 = AudioPrivacyContract()
}

public struct ProviderCapabilities: Codable, Equatable, Sendable {
    public let requiresNetwork: Bool
    public let requiresMicrophone: Bool
    public let externalProvider: Bool

    public init(requiresNetwork: Bool, requiresMicrophone: Bool, externalProvider: Bool) {
        self.requiresNetwork = requiresNetwork
        self.requiresMicrophone = requiresMicrophone
        self.externalProvider = externalProvider
    }
}

public protocol LanguageProvider: Sendable {
    var id: String { get }
    var capabilities: ProviderCapabilities { get }
    func translate(_ text: String, to language: String) async throws -> String
}

public struct DeterministicFixtureProvider: LanguageProvider {
    public let id = "DETERMINISTIC_FIXTURE"
    public let capabilities = ProviderCapabilities(
        requiresNetwork: false,
        requiresMicrophone: false,
        externalProvider: false
    )

    public init() {}

    public func translate(_ text: String, to language: String) async throws -> String {
        if text == "I love this." && language == "Spanish" { return "Me encanta esto." }
        if text == "I love this." && language == "French" { return "J’adore ça." }
        return "Fixture: \(text) in \(language)"
    }
}

public struct AppleBlossomState: Codable, Equatable, Sendable {
    public var sessionID: String
    public var currentPhrase: String
    public var translatedPhrase: String
    public var targetLanguage: String
    public var ejected: Bool

    public init(
        sessionID: String,
        currentPhrase: String = "I love this.",
        translatedPhrase: String = "Me encanta esto.",
        targetLanguage: String = "Spanish",
        ejected: Bool = false
    ) {
        self.sessionID = sessionID
        self.currentPhrase = currentPhrase
        self.translatedPhrase = translatedPhrase
        self.targetLanguage = targetLanguage
        self.ejected = ejected
    }
}

public enum ReceiptEvent: String, Codable, Sendable {
    case startRound = "START_ROUND"
    case swapLanguage = "SWAP_LANGUAGE"
    case confirmMeaning = "CONFIRM_MEANING"
    case replayLastRound = "REPLAY_LAST_ROUND"
    case ejectSession = "EJECT_SESSION"
}

public struct AppleBlossomReceipt: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let event: ReceiptEvent
    public let sessionID: String
    public let sourceSessionID: String?
    public let inputKind: RoundInputKind?
    public let originalText: String
    public let translatedText: String
    public let targetLanguage: String
    public let providerID: String?
    public let providerCapabilities: ProviderCapabilities?
    public let fallbackUsed: Bool
    public let disposition: EvidenceDisposition
    /// Non-authoritative receipt invariant. Callers cannot set this value.
    public let authorityCreated: Bool

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        event: ReceiptEvent,
        sessionID: String,
        sourceSessionID: String? = nil,
        inputKind: RoundInputKind? = nil,
        originalText: String,
        translatedText: String,
        targetLanguage: String,
        providerID: String? = nil,
        providerCapabilities: ProviderCapabilities? = nil,
        fallbackUsed: Bool,
        disposition: EvidenceDisposition
    ) {
        self.id = id
        self.timestamp = timestamp
        self.event = event
        self.sessionID = sessionID
        self.sourceSessionID = sourceSessionID
        self.inputKind = inputKind
        self.originalText = originalText
        self.translatedText = translatedText
        self.targetLanguage = targetLanguage
        self.providerID = providerID
        self.providerCapabilities = providerCapabilities
        self.fallbackUsed = fallbackUsed
        self.disposition = disposition
        self.authorityCreated = false
    }
}

public protocol ReceiptSink: Sendable {
    func append(_ receipt: AppleBlossomReceipt) async
    func allReceipts() async -> [AppleBlossomReceipt]
}

public actor InMemoryReceiptStore: ReceiptSink {
    private var receipts: [AppleBlossomReceipt] = []

    public init() {}

    public func append(_ receipt: AppleBlossomReceipt) {
        receipts.append(receipt)
    }

    public func allReceipts() -> [AppleBlossomReceipt] {
        receipts
    }
}

public struct RoundResult: Codable, Equatable, Sendable {
    public let state: AppleBlossomState
    public let receipt: AppleBlossomReceipt
}

public actor AppleBlossomEngine {
    private var state: AppleBlossomState
    private var provider: any LanguageProvider
    private let receiptSink: any ReceiptSink

    public init(
        sessionID: String = UUID().uuidString,
        provider: any LanguageProvider = DeterministicFixtureProvider(),
        receiptSink: any ReceiptSink = InMemoryReceiptStore()
    ) {
        self.state = AppleBlossomState(sessionID: sessionID)
        self.provider = provider
        self.receiptSink = receiptSink
    }

    public func snapshot() -> AppleBlossomState {
        state
    }

    public func setProvider(_ newProvider: any LanguageProvider) {
        provider = newProvider
    }

    public func providerDescriptor() -> (id: String, capabilities: ProviderCapabilities) {
        (provider.id, provider.capabilities)
    }

    public func startRound(
        text: String,
        inputKind: RoundInputKind = .typed
    ) async throws -> RoundResult {
        let translated = try await provider.translate(text, to: state.targetLanguage)
        state.currentPhrase = text
        state.translatedPhrase = translated
        state.ejected = false

        let receipt = makeReceipt(
            event: .startRound,
            inputKind: inputKind,
            providerID: provider.id,
            providerCapabilities: provider.capabilities,
            fallbackUsed: provider.id == "DETERMINISTIC_FIXTURE",
            disposition: .pass
        )
        await receiptSink.append(receipt)
        return RoundResult(state: state, receipt: receipt)
    }

    public func swapLanguage() async throws -> RoundResult {
        state.targetLanguage = state.targetLanguage == "Spanish" ? "French" : "Spanish"
        state.translatedPhrase = try await provider.translate(state.currentPhrase, to: state.targetLanguage)

        let receipt = makeReceipt(
            event: .swapLanguage,
            providerID: provider.id,
            providerCapabilities: provider.capabilities,
            fallbackUsed: provider.id == "DETERMINISTIC_FIXTURE",
            disposition: .pass
        )
        await receiptSink.append(receipt)
        return RoundResult(state: state, receipt: receipt)
    }

    public func confirmMeaning() async -> AppleBlossomReceipt {
        let normalized = state.translatedPhrase.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        let match = state.currentPhrase == "I love this." && (
            (state.targetLanguage == "Spanish" && normalized.contains("encanta")) ||
            (state.targetLanguage == "French" && normalized.contains("adore"))
        )

        let receipt = makeReceipt(
            event: .confirmMeaning,
            providerID: provider.id,
            providerCapabilities: provider.capabilities,
            fallbackUsed: provider.id == "DETERMINISTIC_FIXTURE",
            disposition: match ? .pass : .hold
        )
        await receiptSink.append(receipt)
        return receipt
    }

    /// EJECT closes the current tape and rotates to a new session.
    /// Durable receipts remain in the receipt sink; the old session is never reactivated implicitly.
    public func ejectSession(nextSessionID: String = UUID().uuidString) async -> AppleBlossomReceipt {
        let priorSessionID = state.sessionID
        let receipt = AppleBlossomReceipt(
            event: .ejectSession,
            sessionID: priorSessionID,
            sourceSessionID: priorSessionID,
            originalText: state.currentPhrase,
            translatedText: state.translatedPhrase,
            targetLanguage: state.targetLanguage,
            providerID: nil,
            providerCapabilities: nil,
            fallbackUsed: false,
            disposition: .pass
        )
        await receiptSink.append(receipt)

        state = AppleBlossomState(sessionID: nextSessionID, ejected: true)
        return receipt
    }

    /// Explicit replay can render a prior authored result into the current session,
    /// but it never restores or reactivates the source session ID.
    public func replayLastRound() async -> RoundResult? {
        let receipts = await receiptSink.allReceipts()
        guard let source = receipts.last(where: { $0.event == .startRound || $0.event == .swapLanguage }) else {
            return nil
        }

        state.currentPhrase = source.originalText
        state.translatedPhrase = source.translatedText
        state.targetLanguage = source.targetLanguage
        state.ejected = false

        let receipt = AppleBlossomReceipt(
            event: .replayLastRound,
            sessionID: state.sessionID,
            sourceSessionID: source.sessionID,
            originalText: state.currentPhrase,
            translatedText: state.translatedPhrase,
            targetLanguage: state.targetLanguage,
            providerID: source.providerID,
            providerCapabilities: source.providerCapabilities,
            fallbackUsed: source.fallbackUsed,
            disposition: .pass
        )
        await receiptSink.append(receipt)
        return RoundResult(state: state, receipt: receipt)
    }

    public func receipts() async -> [AppleBlossomReceipt] {
        await receiptSink.allReceipts()
    }

    private func makeReceipt(
        event: ReceiptEvent,
        inputKind: RoundInputKind? = nil,
        providerID: String?,
        providerCapabilities: ProviderCapabilities?,
        fallbackUsed: Bool,
        disposition: EvidenceDisposition
    ) -> AppleBlossomReceipt {
        AppleBlossomReceipt(
            event: event,
            sessionID: state.sessionID,
            inputKind: inputKind,
            originalText: state.currentPhrase,
            translatedText: state.translatedPhrase,
            targetLanguage: state.targetLanguage,
            providerID: providerID,
            providerCapabilities: providerCapabilities,
            fallbackUsed: fallbackUsed,
            disposition: disposition
        )
    }
}

public struct Gate00Receipt: Codable, Equatable, Sendable {
    public let schema: String
    public let gate: String
    public let disposition: EvidenceDisposition
    public let externalProviderActive: Bool
    public let networkRequired: Bool
    public let microphoneRequired: Bool
    public let foundationModelRequired: Bool
    public let fallbackUsed: Bool
    public let receiptCreated: Bool
    public let rawAudioPersistence: RawAudioPersistencePolicy
    public let initialSessionID: String
    public let ejectedSessionID: String
    public let postEjectSessionID: String
    public let oldSessionReactivated: Bool
    public let postEjectRoundCompleted: Bool
    public let authorityCreated: Bool

    public init(
        schema: String = "APPLE_BLOSSOM_GATE_00_RECEIPT_V0_1",
        gate: String = "00_SOURCE_ONLY_FALLBACK",
        disposition: EvidenceDisposition,
        externalProviderActive: Bool,
        networkRequired: Bool,
        microphoneRequired: Bool,
        foundationModelRequired: Bool,
        fallbackUsed: Bool,
        receiptCreated: Bool,
        rawAudioPersistence: RawAudioPersistencePolicy,
        initialSessionID: String,
        ejectedSessionID: String,
        postEjectSessionID: String,
        oldSessionReactivated: Bool,
        postEjectRoundCompleted: Bool,
        authorityCreated: Bool
    ) {
        self.schema = schema
        self.gate = gate
        self.disposition = disposition
        self.externalProviderActive = externalProviderActive
        self.networkRequired = networkRequired
        self.microphoneRequired = microphoneRequired
        self.foundationModelRequired = foundationModelRequired
        self.fallbackUsed = fallbackUsed
        self.receiptCreated = receiptCreated
        self.rawAudioPersistence = rawAudioPersistence
        self.initialSessionID = initialSessionID
        self.ejectedSessionID = ejectedSessionID
        self.postEjectSessionID = postEjectSessionID
        self.oldSessionReactivated = oldSessionReactivated
        self.postEjectRoundCompleted = postEjectRoundCompleted
        self.authorityCreated = authorityCreated
    }
}
