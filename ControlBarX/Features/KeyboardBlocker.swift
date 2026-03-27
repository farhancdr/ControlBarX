import CoreGraphics
import Foundation
import Observation

@Observable
final class KeyboardBlocker {
    var isEnabled = false
    var allowEscape = true

    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // Auto-disable timer
    var timerActive = false
    var timerMinutes: Int = 0
    var remainingSeconds: Int = 0
    private var timer: Timer?

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }

    func startTimer(minutes: Int) {
        cancelTimer()
        if !isEnabled { enable() }

        timerMinutes = minutes
        remainingSeconds = minutes * 60
        timerActive = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.disable()
                    self.cancelTimer()
                }
            }
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timerActive = false
        timerMinutes = 0
        remainingSeconds = 0
    }

    var timerProgress: Double {
        guard timerMinutes > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(timerMinutes * 60))
    }

    var formattedRemaining: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func enable() {
        guard eventTap == nil else { return }

        let nsSystemDefined = CGEventType(rawValue: 14)!
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << nsSystemDefined.rawValue)

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: keyboardCallback,
            userInfo: refcon
        ) else {
            print("[ControlBarX] Failed to create event tap. Is Accessibility permission granted?")
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        runLoopSource = source
        isEnabled = true
    }

    private func disable() {
        guard let tap = eventTap, let source = runLoopSource else { return }

        CGEvent.tapEnable(tap: tap, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)

        eventTap = nil
        runLoopSource = nil
        isEnabled = false
    }

    deinit {
        cancelTimer()
        disable()
    }
}

private func keyboardCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passRetained(event) }

    let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(refcon).takeUnretainedValue()

    if type == .tapDisabledByTimeout {
        if let tap = blocker.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passRetained(event)
    }

    if type == .tapDisabledByUserInput {
        return Unmanaged.passRetained(event)
    }

    let nsSystemDefined = CGEventType(rawValue: 14)!
    if type == nsSystemDefined {
        return Unmanaged.passRetained(event)
    }

    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

    if keyCode == 53 && blocker.allowEscape {
        return Unmanaged.passRetained(event)
    }

    return nil
}
