import SwiftUI

@main
struct ControlBarXApp: App {
    @State private var keyboardBlocker = KeyboardBlocker()
    @State private var networkMonitor = NetworkMonitor()
    @State private var systemMonitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra("ControlBarX", systemImage: "bolt.fill") {
            MenuContentView(
                keyboardBlocker: $keyboardBlocker,
                networkMonitor: networkMonitor,
                systemMonitor: systemMonitor
            )
        }
        .menuBarExtraStyle(.window)
    }
}
