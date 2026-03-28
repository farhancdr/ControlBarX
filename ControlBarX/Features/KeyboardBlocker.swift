import CoreGraphics
import Foundation
import Observation

@Observable
final class KeyboardBlocker {
    var isEnabled = false
    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
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

    // Always allow ESC to prevent lockout
    if keyCode == 53 {
        return Unmanaged.passRetained(event)
    }

    return nil
}
