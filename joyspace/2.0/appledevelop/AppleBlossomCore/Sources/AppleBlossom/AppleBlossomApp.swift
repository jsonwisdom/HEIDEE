import SwiftUI
import AppIntents
import AppleBlossomCore

struct Gate02StartBlossomIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Apple Blossom"

    func perform() async throws -> some IntentResult {
        let engine = AppleBlossomEngine(sessionID: "GATE02_INTENT_SESSION")
        _ = await engine.snapshot()
        return .result()
    }
}

struct AppleBlossomGate02View: View {
    private let state = AppleBlossomState(sessionID: "GATE02_UI_SESSION")

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.pink)

                Text(state.currentPhrase)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(state.translatedPhrase)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("UI observes AppleBlossomCore state. Core owns replay semantics.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Apple Blossom")
        }
    }
}

@main
struct AppleBlossomGate02App: App {
    var body: some Scene {
        WindowGroup {
            AppleBlossomGate02View()
        }
    }
}
