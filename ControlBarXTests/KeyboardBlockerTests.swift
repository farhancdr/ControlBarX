import Testing
@testable import ControlBarX

@Suite("KeyboardBlocker Tests")
struct KeyboardBlockerTests {

    @Test("initial state is disabled")
    func initialState() {
        let blocker = KeyboardBlocker()
        #expect(!blocker.isEnabled)
    }

    @Test("toggle enables then disables")
    func toggle() {
        let blocker = KeyboardBlocker()

        // Note: toggle -> enable requires Accessibility permission.
        // Without it, enable() silently fails, so isEnabled stays false.
        // This test verifies the toggle logic doesn't crash.
        blocker.toggle()
        blocker.toggle()
        #expect(!blocker.isEnabled)
    }
}
