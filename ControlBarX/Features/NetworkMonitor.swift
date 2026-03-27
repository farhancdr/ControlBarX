import Foundation
import Observation

@Observable
final class NetworkMonitor {
    var uploadSpeed: Double = 0      // bytes per second
    var downloadSpeed: Double = 0    // bytes per second
    var isMonitoring = false

    private var timer: Timer?
    private var previousUpload: UInt64 = 0
    private var previousDownload: UInt64 = 0

    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true

        let (up, down) = Self.getNetworkBytes()
        previousUpload = up
        previousDownload = down

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.update()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        uploadSpeed = 0
        downloadSpeed = 0
    }

    func toggle() {
        if isMonitoring { stop() } else { start() }
    }

    private func update() {
        let (up, down) = Self.getNetworkBytes()

        if previousUpload > 0 {
            uploadSpeed = Double(up.subtractingReportingOverflow(previousUpload).partialValue)
            downloadSpeed = Double(down.subtractingReportingOverflow(previousDownload).partialValue)
        }

        previousUpload = up
        previousDownload = down
    }

    static func getNetworkBytes() -> (upload: UInt64, download: UInt64) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return (0, 0)
        }
        defer { freeifaddrs(ifaddr) }

        var totalUp: UInt64 = 0
        var totalDown: UInt64 = 0

        var ptr = firstAddr
        while true {
            let name = String(cString: ptr.pointee.ifa_name)

            // Only count active network interfaces (en*, lo*)
            if name.hasPrefix("en") || name.hasPrefix("lo") {
                if let data = ptr.pointee.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    totalUp += UInt64(networkData.ifi_obytes)
                    totalDown += UInt64(networkData.ifi_ibytes)
                }
            }

            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }

        return (totalUp, totalDown)
    }

    static func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.0f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        } else {
            return String(format: "%.2f GB/s", bytesPerSecond / (1024 * 1024 * 1024))
        }
    }

    deinit {
        stop()
    }
}
