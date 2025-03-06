//
//  day_jsApp.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
        
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏Dock栏图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏图标
        setupStatusBarItem()
    }
    
    func setupStatusBarItem() {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(named: "AppLogo")
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // 创建弹出窗口
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // 右键点击显示菜单
            let menu = NSMenu()
            
            menu.addItem(NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            
            // 使用完菜单后重置，以便下次左键点击能正常工作
            DispatchQueue.main.async {
                self.statusItem?.menu = nil
            }
        } else {
            // 左键点击显示弹出窗口
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(sender)
                } else {
                    if let button = statusItem?.button {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    }
                }
            }
        }
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let contentView = SettingsView()
            let hostingController = NSHostingController(rootView: contentView)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("Settings")
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.title = "设置"
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct day_jsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // 不在这里设置激活策略，完全依赖Info.plist中的LSUIElement设置
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
