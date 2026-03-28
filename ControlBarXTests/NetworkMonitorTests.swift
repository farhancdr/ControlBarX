import Testing
@testable import ControlBarX

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {

    // MARK: - formatSpeed

    @Test("formats bytes per second")
    func formatSpeedBytes() {
        #expect(NetworkMonitor.formatSpeed(0) == "0 B/s")
        #expect(NetworkMonitor.formatSpeed(512) == "512 B/s")
        #expect(NetworkMonitor.formatSpeed(1023) == "1023 B/s")
    }

    @Test("formats kilobytes per second")
    func formatSpeedKB() {
        #expect(NetworkMonitor.formatSpeed(1024) == "1.0 KB/s")
        #expect(NetworkMonitor.formatSpeed(1536) == "1.5 KB/s")
        #expect(NetworkMonitor.formatSpeed(1024 * 999) == "999.0 KB/s")
    }

    @Test("formats megabytes per second")
    func formatSpeedMB() {
        #expect(NetworkMonitor.formatSpeed(1024 * 1024) == "1.0 MB/s")
        #expect(NetworkMonitor.formatSpeed(1024 * 1024 * 1.5) == "1.5 MB/s")
    }

    @Test("formats gigabytes per second")
    func formatSpeedGB() {
        #expect(NetworkMonitor.formatSpeed(1024 * 1024 * 1024) == "1.00 GB/s")
    }

    // MARK: - Monitor lifecycle

    @Test("starts and stops monitoring")
    func startStop() {
        let monitor = NetworkMonitor()
        #expect(!monitor.isMonitoring)

        monitor.start()
        #expect(monitor.isMonitoring)

        monitor.stop()
        #expect(!monitor.isMonitoring)
        #expect(monitor.uploadSpeed == 0)
        #expect(monitor.downloadSpeed == 0)
    }

    @Test("toggle switches monitoring state")
    func toggle() {
        let monitor = NetworkMonitor()
        monitor.toggle()
        #expect(monitor.isMonitoring)
        monitor.toggle()
        #expect(!monitor.isMonitoring)
    }

    @Test("start is idempotent")
    func startIdempotent() {
        let monitor = NetworkMonitor()
        monitor.start()
        monitor.start()
        #expect(monitor.isMonitoring)
        monitor.stop()
    }

    // MARK: - getNetworkBytes

    @Test("getNetworkBytes returns non-negative values")
    func networkBytesNonNegative() {
        let (upload, download) = NetworkMonitor.getNetworkBytes()
        #expect(upload >= 0)
        #expect(download >= 0)
    }
}
