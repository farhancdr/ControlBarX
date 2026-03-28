import Testing
@testable import ControlBarX

@Suite("SystemMonitor Tests")
struct SystemMonitorTests {

    // MARK: - formatBytes

    @Test("formats bytes to GB string")
    func formatBytes() {
        let oneGB: UInt64 = 1024 * 1024 * 1024
        #expect(SystemMonitor.formatBytes(oneGB) == "1.0 GB")
        #expect(SystemMonitor.formatBytes(oneGB * 16) == "16.0 GB")
        #expect(SystemMonitor.formatBytes(0) == "0.0 GB")
    }

    // MARK: - memoryUsagePercent

    @Test("memoryUsagePercent computes correctly")
    func memoryPercent() {
        let monitor = SystemMonitor()
        #expect(monitor.memoryUsagePercent == 0)
    }

    // MARK: - Monitor lifecycle

    @Test("starts and stops monitoring")
    func startStop() {
        let monitor = SystemMonitor()
        #expect(!monitor.isMonitoring)

        monitor.start()
        #expect(monitor.isMonitoring)

        monitor.stop()
        #expect(!monitor.isMonitoring)
        #expect(monitor.cpuUsage == 0)
        #expect(monitor.memoryUsed == 0)
    }

    @Test("toggle switches monitoring state")
    func toggle() {
        let monitor = SystemMonitor()
        monitor.toggle()
        #expect(monitor.isMonitoring)
        monitor.toggle()
        #expect(!monitor.isMonitoring)
    }

    @Test("start is idempotent")
    func startIdempotent() {
        let monitor = SystemMonitor()
        monitor.start()
        monitor.start()
        #expect(monitor.isMonitoring)
        monitor.stop()
    }

    // MARK: - System data

    @Test("getCPUUsage returns value in valid range")
    func cpuUsageRange() {
        let usage = SystemMonitor.getCPUUsage()
        #expect(usage >= 0)
        #expect(usage <= 100)
    }

    @Test("getMemoryInfo returns valid data")
    func memoryInfo() {
        let info = SystemMonitor.getMemoryInfo()
        #expect(info.total > 0)
        #expect(info.used > 0)
        #expect(info.used <= info.total)
    }
}
