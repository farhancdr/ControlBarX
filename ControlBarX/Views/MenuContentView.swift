import SwiftUI
import ServiceManagement

struct MenuContentView: View {
    @Binding var keyboardBlocker: KeyboardBlocker
    var networkMonitor: NetworkMonitor
    var systemMonitor: SystemMonitor

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            // Keyboard Blocker
            HStack {
                Image(systemName: "keyboard")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                Text("Block Keyboard")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { keyboardBlocker.isEnabled },
                    set: { _ in keyboardBlocker.toggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
                .tint(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().padding(.horizontal, 16)

            // Network Speed
            HStack {
                Image(systemName: "network")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                Text("↓")
                    .foregroundStyle(.blue)
                Text(NetworkMonitor.formatSpeed(networkMonitor.downloadSpeed))
                    .font(.subheadline.monospaced())
                Text("/")
                    .foregroundStyle(.tertiary)
                Text(NetworkMonitor.formatSpeed(networkMonitor.uploadSpeed))
                    .font(.subheadline.monospaced())
                Text("↑")
                    .foregroundStyle(.orange)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().padding(.horizontal, 16)

            // System Stats
            HStack {
                Image(systemName: "cpu")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                Text("RAM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(SystemMonitor.formatBytes(systemMonitor.memoryUsed)) / \(SystemMonitor.formatBytes(systemMonitor.memoryTotal))")
                    .font(.subheadline.monospaced())
                    .foregroundStyle(systemMonitor.memoryUsagePercent > 85 ? .red : systemMonitor.memoryUsagePercent > 65 ? .orange : .primary)
                Spacer()
                Text("CPU")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", systemMonitor.cpuUsage))
                    .font(.subheadline.monospaced())
                    .foregroundStyle(systemMonitor.cpuUsage > 80 ? .red : systemMonitor.cpuUsage > 50 ? .orange : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

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
        .frame(width: 280)
    }
}
