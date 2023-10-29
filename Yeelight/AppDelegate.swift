//
//  AppDelegate.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/19.
//

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private enum MenuItemType: CaseIterable {
        
        case reload
        case about
        case separator
        case quit
        
        var title: String {
            switch self {
            case .reload:
                return "Reload"
            case .about:
                return "About"
            case .quit:
                return "Quit"
            default:
                return ""
            }
        }
        
        var action: String {
            switch self {
            case .reload:
                return "reloadItemAction"
            case .about:
                return "aboutItemAction"
            case .quit:
                return "quitItemAction"
            default:
                return ""
            }
        }
        
        var isLine: Bool {
            switch self {
            case .separator:
                return true
            default:
                return false
            }
        }
        
        func menuItem(action selector: Selector?) -> NSMenuItem {
            
            switch self {
            case .separator:
                return NSMenuItem.separator()
            default:
                return NSMenuItem(title: title, action: selector, keyEquivalent: title)
            }
        }
    }
    
    private var eventMonitor: EventMonitor!
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var menu: NSMenu!
        
    func applicationDidFinishLaunching(_ notification: Notification) {
        
/// hidden window
//        if let window = NSApplication.shared.windows.first {
//            window.close()
//        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        popover = NSPopover()
        popover.appearance = NSAppearance(named: .aqua)
        popover.behavior = .transient
        popover.contentSize = CGSize(width: 500, height: 140)
        popover.contentViewController = NSHostingController(rootView: MainView())
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "lightbulb.2.fill", accessibilityDescription: "popButton")
            button.action = #selector(mouseClickHandler)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(event!)
            }
        }
        
        menu = NSMenu(title: "app.menu")
        menu.delegate = self
        menu.minimumWidth = 200
        
        MenuItemType.allCases.forEach { item in
            let menuItem = item.menuItem(action: #selector(itemAction(_:)))
            menu.addItem(menuItem)
        }
        
        Socket.shared.config()
    }
    
    
    
    @objc
    func showPopover(_ sender: AnyObject) {
        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            if let window = popover.contentViewController?.view.window {
                window.becomeKey()
                window.makeFirstResponder(popover.contentViewController)
            }
            eventMonitor.start()
        }
    }
    
    @objc
    func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        eventMonitor.stop()
    }
    
    @objc
    private func mouseClickHandler(_ sender: AnyObject) {
        if let event = NSApp.currentEvent {
            switch event.type {
            case .leftMouseUp:
                togglePopover(sender)
            default:
                statusItem.menu = menu
                statusItem.button?.performClick(nil)
            }
        }
    }
    
    @objc
    private func reloadItemAction() -> Void {
        NotificationCenter.default.post(name: NSNotification.reload, object: nil)
    }
    
    @objc
    private func aboutItemAction() -> Void {
        NSWorkspace.shared.open(URL(string: "https://github.com/xs0521/EasyYeelight")!)
    }
    
    
    @objc
    private func quitItemAction() {
        NSApplication.shared.terminate(self)
    }
    
    @objc
    private func itemAction(_ item: NSMenuItem) -> Void {
        guard let res = MenuItemType.allCases.first(where: {$0.title == item.title}) else { return }
        self.perform(Selector(res.action))
    }
    
    private func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }
}
