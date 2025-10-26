import ApplicationServices
import Foundation

// ref: https://developer.apple.com/documentation/coregraphics/quartz-event-services

let triggerModifier: CGEventFlags = .maskCommand

private func requestAccessibility() {
    // prompt for accessibility permission
    let opts =
        [
            "AXTrustedCheckOptionPrompt" as CFString: true
        ] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(opts)
    // ref: https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions
}

nonisolated(unsafe) var eventTap: CFMachPort?
nonisolated(unsafe) var runLoopSource: CFRunLoopSource?

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

            // scroll data
            let pointDelta = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)
            let lineDelta = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)

            print(String(format: "⌘ modifier held — point=%.2f line=%ld", pointDelta, lineDelta))

            // TODO: zoom logic
            return Unmanaged.passUnretained(event)
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

    print("scroll logger active")
}

@main
struct zoom_pad {
    static func main() {
        requestAccessibility()
        setupTap()
        RunLoop.current.run()
    }
}
