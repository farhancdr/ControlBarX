import SwiftUI

struct KeyboardSection: View {
    @Binding var blocker: KeyboardBlocker
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
                    Image(systemName: "keyboard")
                        .frame(width: 20)
                    Text("Keyboard Blocker")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Circle()
                        .fill(blocker.isEnabled ? .red : .gray.opacity(0.3))
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
                    // Main toggle
                    Toggle(isOn: Binding(
                        get: { blocker.isEnabled },
                        set: { _ in
                            blocker.toggle()
                            if !blocker.isEnabled { blocker.cancelTimer() }
                        }
                    )) {
                        Label("Block Keyboard", systemImage: "lock")
                    }
                    .toggleStyle(.switch)
                    .tint(.red)

                    // Allow ESC
                    Toggle(isOn: $blocker.allowEscape) {
                        Label("Allow ESC Key", systemImage: "escape")
                    }
                    .toggleStyle(.switch)

                    // Timer
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Auto-disable")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 6) {
                            ForEach([1, 5, 15, 30], id: \.self) { minutes in
                                Button("\(minutes)m") {
                                    blocker.startTimer(minutes: minutes)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .tint(blocker.timerActive && blocker.timerMinutes == minutes ? .blue : nil)
                            }
                            Spacer()
                            if blocker.timerActive {
                                Button {
                                    blocker.cancelTimer()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .controlSize(.mini)
                            }
                        }

                        if blocker.timerActive {
                            ProgressView(value: blocker.timerProgress)
                                .tint(.blue)
                            Text("Disables in \(blocker.formattedRemaining)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }
}
