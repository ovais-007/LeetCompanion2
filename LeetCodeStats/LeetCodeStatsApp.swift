import SwiftUI
import AppKit

@main
struct LeetCodeStatsApp: App {
    // Retain objects
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No window UI – it's all in the menu bar
        Settings {
            EmptyView()
        }
    }
}


