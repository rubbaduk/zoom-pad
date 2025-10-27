import ApplicationServices
import Carbon.HIToolbox
import Foundation

// ref: https://developer.apple.com/documentation/coregraphics/quartz-event-services

let triggerModifier: CGEventFlags = .maskCommand
let invertScroll: Bool = false
let stepThreshold: Double = 85.0

private func requestAccessibility() {
    // prompt for accessibility permission
    let opts =
        [
            "AXTrustedCheckOptionPrompt" as CFString: true
        ] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(opts)
    // ref: https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions
}

func sendKey(_ key: CGKeyCode, flags: CGEventFlags) {
    if let down = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true) {
        down.flags = flags
        down.post(tap: .cghidEventTap)
    }
    if let up = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false) {
        up.flags = flags
        up.post(tap: .cghidEventTap)
    }

}

func zoomIn() {
    sendKey(CGKeyCode(kVK_ANSI_Equal), flags: .maskCommand)
}
func zoomOut() {
    sendKey(CGKeyCode(kVK_ANSI_Minus), flags: .maskCommand)
}

nonisolated(unsafe) var eventTap: CFMachPort?
nonisolated(unsafe) var runLoopSource: CFRunLoopSource?
nonisolated(unsafe) var accum: Double = 0.0

func setupTap() {
    let mask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)

    let tap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: mask,
        callback: { _, type, event, _ in
            // re-enable tap if originally disabled
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let t = eventTap {
                    CGEvent.tapEnable(tap: t, enable: true)
                }
                return Unmanaged.passUnretained(event)
            }

            guard type == .scrollWheel else {
                return Unmanaged.passUnretained(event)
            }

            // only log when modifier is pressed
            if !event.flags.contains(triggerModifier) {
                return Unmanaged.passUnretained(event)
            }

            // use whatever scroll data is present
            // pixel - double vals from trackpad
            // line - int64 vals from scrollwheel

            var delta = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)
            if delta == 0 {
                delta = Double(event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1))
            }

            if invertScroll {
                delta = -delta
            }

            accum += delta

            while accum >= stepThreshold {
                zoomIn()
                accum -= stepThreshold
            }
            while accum <= -stepThreshold {
                zoomOut()
                accum += stepThreshold
            }

            return nil
        },
        userInfo: nil
    )

    guard let tap = tap else {
        fputs("ERROR: Failed to create event tap. Check Accessibility permissions.\n", stderr)
        exit(1)
    }

    eventTap = tap
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)

    print("scroll logger active - to test: hold modifier and scroll")
}

@main
struct zoom_pad {
    static func main() {
        requestAccessibility()
        setupTap()
        RunLoop.current.run()
    }
}
