import ApplicationServices
import Foundation

// ref: https://developer.apple.com/documentation/coregraphics/quartz-event-services

private func requestAccessibility() {
    // prompt for accessibility permission
    let opts =
        [
            "AXTrustedCheckOptionPrompt" as CFString: true
        ] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(opts)

    if trusted {
        return print("Access granted")
    } else {
        return print("Follow prompt to allow access")
    }
    // ref: https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions

}
// show held modifier keys
func flagsDescription(_ f: CGEventFlags) -> String {
    var parts: [String] = []
    if f.contains(.maskShift) {
        parts.append("⇧")
    }
    if f.contains(.maskControl) {
        parts.append("⌃")
    }
    if f.contains(.maskAlternate) {
        parts.append("⌥")
    }
    if f.contains(.maskCommand) {
        parts.append("⌘")
    }

    return parts.isEmpty ? "(none)" : parts.joined()
}

func setupScrollLogger() {
    let maskBits = CGEventMask(1 << CGEventType.scrollWheel.rawValue)

    guard
        let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,  // listen to current user session
            place: .headInsertEventTap,  // intercept events early
            options: .defaultTap,  // can observe and modify events
            eventsOfInterest: maskBits,
            callback: { _, type, event, _ in
                // ensure scroll event
                guard type == .scrollWheel else {
                    return Unmanaged.passUnretained(event)
                }

                // scroll data
                // pointDelta: high-resolution (trackpad), supports decimals
                // lineDelta: traditional (mouse), typically whole numbers
                let pointDelta = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)
                let lineDelta = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                let flags = event.flags

                print(
                    String(
                        format: "Scroll: point=%.2f line=%ld flags=%@",
                        pointDelta,
                        lineDelta,
                        flagsDescription(flags)
                    ))

                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )
    else {
        fputs("ERROR: Failed to create event tap. Check Accessibility permissions.\n", stderr)
        exit(1)
    }

    // keeps listening
    let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)

    print("scroll logger active")
}

@main
struct zoom_pad {
    static func main() {
        requestAccessibility()
        setupScrollLogger()
        RunLoop.current.run()
    }
}
