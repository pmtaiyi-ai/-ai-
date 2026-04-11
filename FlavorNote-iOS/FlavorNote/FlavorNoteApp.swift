import SwiftUI

@main
struct FlavorNoteApp: App {
    @StateObject private var store = DrinkStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
