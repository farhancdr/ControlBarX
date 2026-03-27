import Foundation
import Observation

@Observable
final class SystemMonitor {
    var cpuUsage: Double = 0         // percentage 0-100
    var memoryUsed: UInt64 = 0       // bytes
    var memoryTotal: UInt64 = 0      // bytes
    var isMonitoring = false

    private var timer: Timer?

    var memoryUsagePercent: Double {
        guard memoryTotal > 0 else { return 0 }
        return Double(memoryUsed) / Double(memoryTotal) * 100
    }

    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true
        update()

        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.update()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        cpuUsage = 0
        memoryUsed = 0
    }

    func toggle() {
        if isMonitoring { stop() } else { start() }
    }

    private func update() {
        cpuUsage = Self.getCPUUsage()
        let mem = Self.getMemoryInfo()
        memoryUsed = mem.used
        memoryTotal = mem.total
    }

    // MARK: - CPU Usage via host_processor_info

    private static var previousCPUInfo: processor_info_array_t?
    private static var previousCPUInfoCount: mach_msg_type_number_t = 0

    static func getCPUUsage() -> Double {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var cpuInfoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &cpuInfoCount
        )

        guard result == KERN_SUCCESS, let cpuInfo else { return 0 }

        var totalUsage: Double = 0

        for i in 0..<Int(numCPUs) {
            let offset = Int(CPU_STATE_MAX) * i
            let user = Double(cpuInfo[offset + Int(CPU_STATE_USER)])
            let system = Double(cpuInfo[offset + Int(CPU_STATE_SYSTEM)])
            let nice = Double(cpuInfo[offset + Int(CPU_STATE_NICE)])
            let idle = Double(cpuInfo[offset + Int(CPU_STATE_IDLE)])

            if let prev = previousCPUInfo {
                let prevUser = Double(prev[offset + Int(CPU_STATE_USER)])
                let prevSystem = Double(prev[offset + Int(CPU_STATE_SYSTEM)])
                let prevNice = Double(prev[offset + Int(CPU_STATE_NICE)])
                let prevIdle = Double(prev[offset + Int(CPU_STATE_IDLE)])

                let userDiff = user - prevUser
                let systemDiff = system - prevSystem
                let niceDiff = nice - prevNice
                let idleDiff = idle - prevIdle

                let totalTicks = userDiff + systemDiff + niceDiff + idleDiff
                if totalTicks > 0 {
                    totalUsage += (userDiff + systemDiff + niceDiff) / totalTicks * 100
                }
            }
        }

        if let prev = previousCPUInfo {
            let prevSize = vm_size_t(previousCPUInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prev), prevSize)
        }

        previousCPUInfo = cpuInfo
        previousCPUInfoCount = cpuInfoCount

        return numCPUs > 0 ? totalUsage / Double(numCPUs) : 0
    }

    // MARK: - Memory Info

    static func getMemoryInfo() -> (used: UInt64, total: UInt64) {
        let total = ProcessInfo.processInfo.physicalMemory

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return (0, total) }

        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(stats.active_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize

        let used = active + wired + compressed + inactive

        return (used, total)
    }

    static func formatBytes(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / (1024 * 1024 * 1024)
        return String(format: "%.1f GB", gb)
    }

    deinit {
        stop()
    }
}
