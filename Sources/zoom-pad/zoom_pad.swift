import ApplicationServices
import Foundation

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

@main
struct zoom_pad {
    static func main() {
        requestAccessibility()
    }
}
