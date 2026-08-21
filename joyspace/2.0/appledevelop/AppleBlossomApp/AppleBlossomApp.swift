import Foundation
import SwiftUI
import AppIntents
import FoundationModels

// MARK: - Atomic Family Data Model
struct LearningReceipt: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let originalText: String
    let translatedText: String
    let targetLanguage: String
    let timestamp: Date
    let assistanceUsed: [String]
    let sessionID: String

    init(
        id: UUID = UUID(),
        originalText: String,
        translatedText: String,
        targetLanguage: String,
        timestamp: Date = Date(),
        assistanceUsed: [String],
        sessionID: String
    ) {
        self.id = id
        self.originalText = originalText
        self.translatedText = translatedText
        self.targetLanguage = targetLanguage
        self.timestamp = timestamp
        self.assistanceUsed = assistanceUsed
        self.sessionID = sessionID
    }
}

// MARK: - Durable Local Receipt Store
@MainActor
final class ReceiptStore: ObservableObject {
    @Published private(set) var receipts: [LearningReceipt] = []

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("AppleBlossom", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.fileURL = directory.appendingPathComponent("learning-receipts-v0.1.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        load()
    }

    func append(_ receipt: LearningReceipt) {
        receipts.append(receipt)
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([LearningReceipt].self, from: data) else {
            receipts = []
            return
        }
        receipts = decoded
    }

    private func persist() {
        guard let data = try? encoder.encode(receipts) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}

// MARK: - Providers
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

protocol LanguageProvider: Sendable {
    func translate(_ text: String, to language: String) async throws -> String
    func transcribeAudio() async throws -> String
}

struct AppleFoundationProvider: LanguageProvider {
    func translate(_ text: String, to language: String) async throws -> String {
        switch SystemLanguageModel.default.availability {
        case .available:
            let session = LanguageModelSession(instructions: """
                Translate the person's text into the requested target language.
                Preserve meaning. Return only the translation, with no explanation.
                """)
            let response = try await session.respond(
                to: "Translate into \(language): \(text)"
            )
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            throw ProviderError.appleModelUnavailable
        }
    }

    // v0.1 keeps speech capture deterministic. Replace with a microphone/Speech rail later.
    func transcribeAudio() async throws -> String {
        "I love this."
    }
}

struct OpenAIDeepVoiceProvider: LanguageProvider {
    // Deliberately disabled in the iOS client until a server broker mints a short-lived
    // Realtime client secret. Never embed OPENAI_API_KEY in an app binary.
    func translate(_ text: String, to language: String) async throws -> String {
        throw ProviderError.openAINotConfigured
    }

    func transcribeAudio() async throws -> String {
        throw ProviderError.openAINotConfigured
    }
}

struct DeterministicFixtureProvider: LanguageProvider {
    func translate(_ text: String, to language: String) async throws -> String {
        if text == "I love this." && language == "Spanish" { return "Me encanta esto." }
        if text == "I love this." && language == "French" { return "J’adore ça." }
        return "Fixture: \(text) in \(language)"
    }

    func transcribeAudio() async throws -> String {
        "I love this."
    }
}

// MARK: - Main View
struct AppleBlossomView: View {
    @StateObject private var receiptStore = ReceiptStore()

    @State private var currentPhrase = "I love this."
    @State private var translatedPhrase = "Me encanta esto."
    @State private var targetLanguage = "Spanish"
    @State private var isPlaying = false
    @State private var trackingOffset: Double = 0.0
    @State private var sessionID = UUID().uuidString
    @State private var showReceipts = false

    @State private var providerKind: ProviderKind = .appleLocal
    @State private var pendingProviderKind: ProviderKind?

    @State private var showGateHold = false
    @State private var gateMessage = ""
    @State private var statusMessage = "Ready."

    private var activeProvider: any LanguageProvider {
        switch providerKind {
        case .appleLocal: AppleFoundationProvider()
        case .openAIRealtime: OpenAIDeepVoiceProvider()
        case .fixture: DeterministicFixtureProvider()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink)
                    .padding(.top, 10)

                VStack(spacing: 8) {
                    Text(currentPhrase)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("⬇️ SWAP ⬇️")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(translatedPhrase)
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
                    Text(providerKind.label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(6)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Spacer()

                    Menu("🌐 Provider") {
                        Button("🍎 Apple Foundation (Local)") {
                            setProvider(.appleLocal)
                        }
                        Button("🎙️ OpenAI Realtime (Optional)") {
                            requestExternalProvider(.openAIRealtime)
                        }
                        Button("📼 Deterministic Fixture (No AI)") {
                            setProvider(.fixture)
                        }
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button(action: rewindAction) {
                        Image(systemName: "backward.fill")
                    }
                    .font(.title2)

                    Button(action: playAction) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    }
                    .font(.title)
                    .foregroundStyle(isPlaying ? .orange : .green)

                    Button(action: forwardAction) {
                        Image(systemName: "forward.fill")
                    }
                    .font(.title2)

                    Divider().frame(height: 30)

                    HStack(spacing: 4) {
                        Text("TRK").font(.caption)
                        Slider(
                            value: $trackingOffset,
                            in: -1.0...1.0,
                            step: 0.1,
                            onEditingChanged: { editing in
                                if !editing {
                                    appendReceipt(assistance: ["TRACKING_\(trackingOffset)"])
                                }
                            }
                        )
                        .frame(width: 70)
                    }

                    Divider().frame(height: 30)

                    Button(role: .destructive, action: ejectAction) {
                        Image(systemName: "eject.fill")
                    }
                    .font(.title2)
                }
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    IntentButton("Start Round", systemImage: "sparkles") { await startBlossomRound() }
                    IntentButton("Swap Lang", systemImage: "globe") { await swapLanguage() }
                    IntentButton("Confirm Meaning", systemImage: "checkmark.seal.fill") { await confirmMeaning() }
                    IntentButton("Show Receipt", systemImage: "list.bullet.rectangle") { showReceipts.toggle() }
                    IntentButton("Replay Last", systemImage: "arrow.clockwise") { await replayLastRound() }
                    IntentButton("Eject Session", systemImage: "door.left.hand.open") { ejectAction() }
                }
                .padding(.horizontal)

                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer()

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
                ReceiptListView(receipts: receiptStore.receipts)
            }
            .alert("🥊 Shock Glove", isPresented: $showGateHold) {
                Button("Allow External Provider") {
                    guard let pendingProviderKind else { return }
                    providerKind = pendingProviderKind
                    self.pendingProviderKind = nil
                    appendReceipt(assistance: ["GATE_PASSED", "PROVIDER_SWITCH_OPENAI"])
                    statusMessage = "External provider selected. Server broker still required."
                }
                Button("Hold / Cancel", role: .cancel) {
                    pendingProviderKind = nil
                    gateMessage = "Boundary held. No provider change occurred."
                    statusMessage = gateMessage
                }
            } message: {
                Text(gateMessage)
            }
        }
    }

    private func setProvider(_ kind: ProviderKind) {
        providerKind = kind
        pendingProviderKind = nil
        appendReceipt(assistance: ["PROVIDER_SWITCH_\(kind.rawValue.uppercased())"])
        statusMessage = "Provider: \(kind.label)"
    }

    private func requestExternalProvider(_ kind: ProviderKind) {
        pendingProviderKind = kind
        gateMessage = "External AI sends session content off-device. An adult-controlled boundary must explicitly allow that provider for this prototype. No family authority is created."
        showGateHold = true
    }

    private func startBlossomRound() async {
        do {
            let heardText = try await activeProvider.transcribeAudio()
            currentPhrase = heardText
            translatedPhrase = try await activeProvider.translate(heardText, to: targetLanguage)
            appendReceipt(assistance: ["START_ROUND", "AUDIO_CUE", providerKind.rawValue])
            statusMessage = "Round started."
        } catch {
            let fixture = DeterministicFixtureProvider()
            currentPhrase = (try? await fixture.transcribeAudio()) ?? currentPhrase
            translatedPhrase = (try? await fixture.translate(currentPhrase, to: targetLanguage)) ?? currentPhrase
            appendReceipt(assistance: ["FALLBACK_FIXTURE", "PROVIDER_ERROR_\(providerKind.rawValue)"])
            statusMessage = error.localizedDescription
        }
    }

    private func swapLanguage() async {
        targetLanguage = (targetLanguage == "Spanish") ? "French" : "Spanish"
        do {
            translatedPhrase = try await activeProvider.translate(currentPhrase, to: targetLanguage)
            appendReceipt(assistance: ["LANG_SWAP_\(targetLanguage)", providerKind.rawValue])
            statusMessage = "Language: \(targetLanguage)"
        } catch {
            let fixture = DeterministicFixtureProvider()
            translatedPhrase = (try? await fixture.translate(currentPhrase, to: targetLanguage)) ?? currentPhrase
            appendReceipt(assistance: ["LANG_SWAP_FALLBACK_\(targetLanguage)"])
            statusMessage = error.localizedDescription
        }
    }

    private func confirmMeaning() async {
        let normalized = translatedPhrase.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let isFixtureMatch = currentPhrase == "I love this." && (
            (targetLanguage == "Spanish" && normalized.contains("encanta")) ||
            (targetLanguage == "French" && normalized.contains("adore"))
        )
        appendReceipt(assistance: ["MEANING_CONFIRMATION_\(isFixtureMatch ? "MATCH" : "HOLD")"])
        statusMessage = isFixtureMatch ? "Meaning confirmed for this bounded fixture." : "Meaning needs learner confirmation."
    }

    private func replayLastRound() async {
        guard let last = receiptStore.receipts.last else {
            statusMessage = "No local receipt yet."
            return
        }
        currentPhrase = last.originalText
        translatedPhrase = last.translatedText
        targetLanguage = last.targetLanguage
        appendReceipt(assistance: ["REPLAY_SESSION_\(last.sessionID)"])
        statusMessage = "Last local receipt replayed."
    }

    private func rewindAction() {
        isPlaying = false
        trackingOffset = max(-1.0, trackingOffset - 0.2)
        appendReceipt(assistance: ["REW"])
    }

    private func playAction() {
        isPlaying.toggle()
        appendReceipt(assistance: [isPlaying ? "PLAY" : "PAUSE"])
    }

    private func forwardAction() {
        isPlaying = false
        trackingOffset = min(1.0, trackingOffset + 0.2)
        appendReceipt(assistance: ["FF"])
    }

    private func ejectAction() {
        isPlaying = false
        sessionID = UUID().uuidString
        currentPhrase = "I love this."
        translatedPhrase = "Me encanta esto."
        targetLanguage = "Spanish"
        trackingOffset = 0.0
        appendReceipt(assistance: ["EJECT_SESSION"])
        statusMessage = "Session ejected. Local receipts preserved."
    }

    private func appendReceipt(assistance: [String]) {
        receiptStore.append(
            LearningReceipt(
                originalText: currentPhrase,
                translatedText: translatedPhrase,
                targetLanguage: targetLanguage,
                assistanceUsed: assistance,
                sessionID: sessionID
            )
        )
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
    let receipts: [LearningReceipt]

    var body: some View {
        NavigationStack {
            List(Array(receipts.reversed())) { receipt in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(receipt.originalText) → \(receipt.translatedText)")
                        .font(.headline)
                    Text("Lang: \(receipt.targetLanguage)")
                        .font(.caption)
                    Text("Assist: \(receipt.assistanceUsed.joined(separator: ", "))")
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
// v0.1 registers the system actions. State mutation remains inside the app until
// the shared App-Intent command bridge is added in a later receipt.
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
