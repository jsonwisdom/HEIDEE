import Foundation
import SwiftUI
import AppIntents
import FoundationModels
import AppleBlossomCore

// MARK: - iOS Provider Adapters
enum ProviderKind: String, CaseIterable, Identifiable, Sendable {
    case appleLocal
    case openAIRealtime
    case fixture

    var id: String { rawValue }

    var label: String {
        switch self {
        case .appleLocal: return "🍎 LOCAL"
        case .openAIRealtime: return "🎙️ OPENAI"
        case .fixture: return "📼 FIXTURE"
        }
    }
}

enum ProviderError: LocalizedError {
    case appleModelUnavailable
    case openAINotConfigured

    var errorDescription: String? {
        switch self {
        case .appleModelUnavailable:
            return "Apple Foundation Models are unavailable on this device or region."
        case .openAINotConfigured:
            return "OpenAI Realtime is not configured. Core JoySpace remains available."
        }
    }
}

struct AppleFoundationProvider: LanguageProvider {
    let id = "APPLE_FOUNDATION_LOCAL"
    let capabilities = ProviderCapabilities(
        requiresNetwork: false,
        requiresMicrophone: false,
        externalProvider: false
    )

    func translate(_ text: String, to language: String) async throws -> String {
        switch SystemLanguageModel.default.availability {
        case .available:
            let session = LanguageModelSession(instructions: """
                Translate the person's text into the requested target language.
                Preserve meaning. Return only the translation, with no explanation.
                """)
            let response = try await session.respond(to: "Translate into \(language): \(text)")
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            throw ProviderError.appleModelUnavailable
        }
    }
}

struct OpenAIDeepVoiceProvider: LanguageProvider {
    let id = "OPENAI_REALTIME_OPTIONAL"
    let capabilities = ProviderCapabilities(
        requiresNetwork: true,
        requiresMicrophone: false,
        externalProvider: true
    )

    // Deliberately disabled until a server broker mints a short-lived Realtime client secret.
    // Never embed OPENAI_API_KEY in the app binary.
    func translate(_ text: String, to language: String) async throws -> String {
        throw ProviderError.openAINotConfigured
    }
}

// MARK: - Durable Family-Local Engine Receipts
actor DiskReceiptStore: ReceiptSink {
    private var receipts: [AppleBlossomReceipt]
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("AppleBlossom", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("appleblossom-engine-receipts-v0.1.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? decoder.decode([AppleBlossomReceipt].self, from: data) {
            receipts = decoded
        } else {
            receipts = []
        }
    }

    func append(_ receipt: AppleBlossomReceipt) {
        receipts.append(receipt)
        persist()
    }

    func allReceipts() -> [AppleBlossomReceipt] {
        receipts
    }

    private func persist() {
        guard let data = try? encoder.encode(receipts) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}

// MARK: - Shared Engine Controller
@MainActor
final class AppleBlossomController: ObservableObject {
    @Published private(set) var state: AppleBlossomState
    @Published private(set) var receipts: [AppleBlossomReceipt] = []
    @Published private(set) var providerKind: ProviderKind = .appleLocal
    @Published var statusMessage = "Ready."

    private let receiptStore: DiskReceiptStore
    private let engine: AppleBlossomEngine

    init() {
        let sessionID = UUID().uuidString
        let store = DiskReceiptStore()
        receiptStore = store
        engine = AppleBlossomEngine(
            sessionID: sessionID,
            provider: AppleFoundationProvider(),
            receiptSink: store
        )
        state = AppleBlossomState(sessionID: sessionID)

        Task { await refreshFromEngine() }
    }

    func setProvider(_ kind: ProviderKind) async {
        switch kind {
        case .appleLocal:
            await engine.setProvider(AppleFoundationProvider())
        case .openAIRealtime:
            await engine.setProvider(OpenAIDeepVoiceProvider())
        case .fixture:
            await engine.setProvider(DeterministicFixtureProvider())
        }
        providerKind = kind
        statusMessage = "Provider: \(kind.label)"
    }

    func startRound() async {
        do {
            // Gate 00 / v0.1 intentionally does not request microphone access.
            let result = try await engine.startRound(text: "I love this.", inputKind: .fixture)
            state = result.state
            statusMessage = "Round started."
        } catch {
            await engine.setProvider(DeterministicFixtureProvider())
            providerKind = .fixture
            do {
                let result = try await engine.startRound(text: "I love this.", inputKind: .fixture)
                state = result.state
                statusMessage = "Local fallback used: \(error.localizedDescription)"
            } catch {
                statusMessage = "Fallback failed: \(error.localizedDescription)"
            }
        }
        await refreshReceipts()
    }

    func swapLanguage() async {
        do {
            let result = try await engine.swapLanguage()
            state = result.state
            statusMessage = "Language: \(state.targetLanguage)"
        } catch {
            await engine.setProvider(DeterministicFixtureProvider())
            providerKind = .fixture
            do {
                let result = try await engine.swapLanguage()
                state = result.state
                statusMessage = "Language fallback used: \(error.localizedDescription)"
            } catch {
                statusMessage = "Swap failed: \(error.localizedDescription)"
            }
        }
        await refreshReceipts()
    }

    func confirmMeaning() async {
        let receipt = await engine.confirmMeaning()
        statusMessage = receipt.disposition == .pass
            ? "Meaning confirmed for this bounded fixture."
            : "Meaning needs learner confirmation."
        await refreshReceipts()
    }

    func replayLastRound() async {
        guard let result = await engine.replayLastRound() else {
            statusMessage = "No local round receipt yet."
            return
        }
        state = result.state
        statusMessage = "Last local round replayed into the current session."
        await refreshReceipts()
    }

    func ejectSession() async {
        _ = await engine.ejectSession()
        await refreshFromEngine()
        statusMessage = "Session ejected. Old session not reactivated; receipts preserved."
    }

    private func refreshFromEngine() async {
        state = await engine.snapshot()
        await refreshReceipts()
    }

    private func refreshReceipts() async {
        receipts = await receiptStore.allReceipts()
    }
}

// MARK: - Main View
struct AppleBlossomView: View {
    @StateObject private var controller = AppleBlossomController()

    @State private var isPlaying = false
    @State private var trackingOffset: Double = 0.0
    @State private var showReceipts = false
    @State private var pendingProviderKind: ProviderKind?
    @State private var showGateHold = false
    @State private var gateMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink)
                    .padding(.top, 10)

                VStack(spacing: 8) {
                    Text(controller.state.currentPhrase)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("⬇️ SWAP ⬇️")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(controller.state.translatedPhrase)
                        .font(.title)
                        .foregroundStyle(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                HStack {
                    Text("Provider:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(controller.providerKind.label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(6)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Spacer()

                    Menu("🌐 Provider") {
                        Button("🍎 Apple Foundation (Local)") {
                            Task { await controller.setProvider(.appleLocal) }
                        }
                        Button("🎙️ OpenAI Realtime (Optional)") {
                            pendingProviderKind = .openAIRealtime
                            gateMessage = "External AI sends session content off-device. Explicit adult-controlled approval is required. No family authority is created."
                            showGateHold = true
                        }
                        Button("📼 Deterministic Fixture (No AI)") {
                            Task { await controller.setProvider(.fixture) }
                        }
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button {
                        isPlaying = false
                        trackingOffset = max(-1.0, trackingOffset - 0.2)
                    } label: {
                        Image(systemName: "backward.fill")
                    }
                    .font(.title2)

                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    }
                    .font(.title)
                    .foregroundStyle(isPlaying ? .orange : .green)

                    Button {
                        isPlaying = false
                        trackingOffset = min(1.0, trackingOffset + 0.2)
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                    .font(.title2)

                    Divider().frame(height: 30)

                    HStack(spacing: 4) {
                        Text("TRK").font(.caption)
                        Slider(value: $trackingOffset, in: -1.0...1.0, step: 0.1)
                            .frame(width: 70)
                    }

                    Divider().frame(height: 30)

                    Button(role: .destructive) {
                        Task { await controller.ejectSession() }
                    } label: {
                        Image(systemName: "eject.fill")
                    }
                    .font(.title2)
                }
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    IntentButton("Start Round", systemImage: "sparkles") { await controller.startRound() }
                    IntentButton("Swap Lang", systemImage: "globe") { await controller.swapLanguage() }
                    IntentButton("Confirm Meaning", systemImage: "checkmark.seal.fill") { await controller.confirmMeaning() }
                    IntentButton("Show Receipt", systemImage: "list.bullet.rectangle") { showReceipts.toggle() }
                    IntentButton("Replay Last", systemImage: "arrow.clockwise") { await controller.replayLastRound() }
                    IntentButton("Eject Session", systemImage: "door.left.hand.open") { await controller.ejectSession() }
                }
                .padding(.horizontal)

                Text(controller.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer()

                Text("RAW_AUDIO_PERSISTENCE = MEMORY_ONLY_NEVER_DISK")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("AI_UNAVAILABLE != JOYSPACE_UNAVAILABLE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("WALLET_BALANCE != FAMILY_VALUE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.pink)
            }
            .padding()
            .navigationTitle("🌸 Apple Blossom")
            .sheet(isPresented: $showReceipts) {
                ReceiptListView(receipts: controller.receipts)
            }
            .alert("🥊 Shock Glove", isPresented: $showGateHold) {
                Button("Allow External Provider") {
                    guard let pendingProviderKind else { return }
                    self.pendingProviderKind = nil
                    Task { await controller.setProvider(pendingProviderKind) }
                }
                Button("Hold / Cancel", role: .cancel) {
                    pendingProviderKind = nil
                    gateMessage = "Boundary held. No provider change occurred."
                }
            } message: {
                Text(gateMessage)
            }
        }
    }
}

// MARK: - UI Helpers
struct IntentButton: View {
    let title: String
    let systemImage: String
    let action: () async -> Void

    init(_ title: String, systemImage: String, action: @escaping () async -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct ReceiptListView: View {
    let receipts: [AppleBlossomReceipt]

    var body: some View {
        NavigationStack {
            List(Array(receipts.reversed())) { receipt in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(receipt.originalText) → \(receipt.translatedText)")
                        .font(.headline)
                    Text("Lang: \(receipt.targetLanguage)")
                        .font(.caption)
                    Text("Event: \(receipt.event.rawValue) · \(receipt.disposition.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Session: \(receipt.sessionID)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(receipt.timestamp, style: .time)
                        .font(.caption2)
                }
            }
            .navigationTitle("📼 Local Receipts")
        }
    }
}

// MARK: - App Intents
// Gate 05A/05B is intentionally NOT claimed yet. These register actions only;
// cold/warm durable engine invocation remains the next device-specific receipt.
struct StartBlossomRoundIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a Blossom round"
    func perform() async throws -> some IntentResult { .result(dialog: "Open Apple Blossom to start the round.") }
}

struct ReplayLastRoundIntent: AppIntent {
    static var title: LocalizedStringResource = "Replay my last round"
    func perform() async throws -> some IntentResult { .result(dialog: "Open Apple Blossom to replay the latest local receipt.") }
}

struct SwapLanguageIntent: AppIntent {
    static var title: LocalizedStringResource = "Swap the language"
    func perform() async throws -> some IntentResult { .result(dialog: "Open Apple Blossom to swap the language.") }
}

struct ConfirmMeaningIntent: AppIntent {
    static var title: LocalizedStringResource = "Confirm the meaning"
    func perform() async throws -> some IntentResult { .result(dialog: "Open Apple Blossom to confirm this round's meaning.") }
}

struct ShowReceiptIntent: AppIntent {
    static var title: LocalizedStringResource = "Show my receipt"
    func perform() async throws -> some IntentResult { .result(dialog: "Your receipts remain local to Apple Blossom.") }
}

struct EjectSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Eject the session"
    func perform() async throws -> some IntentResult { .result(dialog: "Open Apple Blossom to eject the active session.") }
}

// MARK: - App Entry Point
@main
struct AppleBlossomApp: App {
    var body: some Scene {
        WindowGroup {
            AppleBlossomView()
        }
    }
}
