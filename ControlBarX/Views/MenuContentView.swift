import SwiftUI
import ServiceManagement

struct MenuContentView: View {
    @Binding var keyboardBlocker: KeyboardBlocker
    var networkMonitor: NetworkMonitor
    var systemMonitor: SystemMonitor

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("ControlBarX")
                    .font(.headline)
                Spacer()
                Text("v1.0")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    KeyboardSection(blocker: $keyboardBlocker)
                    Divider().padding(.horizontal, 16)
                    NetworkSection(monitor: networkMonitor)
                    Divider().padding(.horizontal, 16)
                    SystemSection(monitor: systemMonitor)
                }
            }
            .frame(maxHeight: 400)

            Divider()

            // Footer
            HStack {
                Toggle(isOn: $launchAtLogin) {
                    Label("Launch at Login", systemImage: "power")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = !newValue
                    }
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 300)
    }
}
