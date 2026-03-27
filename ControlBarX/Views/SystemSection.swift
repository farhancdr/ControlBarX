import SwiftUI

struct SystemSection: View {
    var monitor: SystemMonitor
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
                    Image(systemName: "cpu")
                        .frame(width: 20)
                    Text("System Monitor")
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
                        Label("Monitor System", systemImage: "gauge.with.dots.needle.33percent")
                    }
                    .toggleStyle(.switch)
                    .tint(.green)

                    if monitor.isMonitoring {
                        VStack(spacing: 10) {
                            // CPU
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Label("CPU", systemImage: "cpu")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(String(format: "%.1f%%", monitor.cpuUsage))
                                        .font(.caption.monospaced().weight(.medium))
                                        .foregroundStyle(cpuColor)
                                }
                                ProgressView(value: min(monitor.cpuUsage, 100), total: 100)
                                    .tint(cpuColor)
                            }

                            // Memory
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Label("RAM", systemImage: "memorychip")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(SystemMonitor.formatBytes(monitor.memoryUsed)) / \(SystemMonitor.formatBytes(monitor.memoryTotal))")
                                        .font(.caption.monospaced().weight(.medium))
                                        .foregroundStyle(memoryColor)
                                }
                                ProgressView(value: min(monitor.memoryUsagePercent, 100), total: 100)
                                    .tint(memoryColor)
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

    private var cpuColor: Color {
        if monitor.cpuUsage > 80 { return .red }
        if monitor.cpuUsage > 50 { return .orange }
        return .green
    }

    private var memoryColor: Color {
        if monitor.memoryUsagePercent > 85 { return .red }
        if monitor.memoryUsagePercent > 65 { return .orange }
        return .blue
    }
}
