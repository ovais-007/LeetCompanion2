import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        //print("AppDelegate launched")

        // 🚫 Removes Dock icon
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "LeetCode Stats Icon")
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "LeetCode Stats Icon")



        }

        let popoverWidth: CGFloat = 360
        let popoverHeight: CGFloat = 580
        let contentView = DashboardView().frame(width: popoverWidth, height: popoverHeight)
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentSize = CGSize(width: popoverWidth, height: popoverHeight)
        popover.contentViewController = hostingController
        popover.behavior = .transient
    }

    @objc func togglePopover(_ sender: Any?) {
        //print("Menu bar icon clicked") // You SHOULD see this in the console
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}


