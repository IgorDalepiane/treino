import SwiftUI

@main
struct TreinoApp: App {
    @State private var store: GymStore

    init() {
        if ProcessInfo.processInfo.arguments.contains("-treino-reset") {
            try? FileManager.default.removeItem(at: GymStore.defaultURL)
        }
        _store = State(initialValue: GymStore.load())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
