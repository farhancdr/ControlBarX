import SwiftUI

struct NetworkSection: View {
    var monitor: NetworkMonitor
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "network")
                        .frame(width: 20)
                    Text("Network Speed")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Circle()
                        .fill(monitor.isMonitoring ? .green : .gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            if isExpanded {
                VStack(spacing: 10) {
                    Toggle(isOn: Binding(
                        get: { monitor.isMonitoring },
                        set: { _ in monitor.toggle() }
                    )) {
                        Label("Monitor Network", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .toggleStyle(.switch)
                    .tint(.green)

                    if monitor.isMonitoring {
                        HStack(spacing: 16) {
                            // Upload
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Upload")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(NetworkMonitor.formatSpeed(monitor.uploadSpeed))
                                        .font(.caption.monospaced())
                                }
                            }

                            Spacer()

                            // Download
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Download")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(NetworkMonitor.formatSpeed(monitor.downloadSpeed))
                                        .font(.caption.monospaced())
                                }
                            }
                        }
                        .padding(10)
                        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }
}
