//
//  day_jsApp.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
    var settingsViewController: NSHostingController<AnyView>?
    var settingsState = SettingsState()
    let themeManager = ThemeManager.shared
    let iconConfig = NSImage.SymbolConfiguration(pointSize: 20, weight: .regular)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏Dock栏图标
        NSApp.setActivationPolicy(.accessory)

        // 创建状态栏图标
        setupStatusBarItem()
        // 绑定通知
        bindNotification()
        // 应用主题设置
        themeManager.applyTheme()
    }

    func setupStatusBarItem() {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(named: "MenubarIconDark")
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 创建弹出窗口
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 350, height: 500)
        popover?.behavior = .transient

        // 创建内容视图并应用主题感知修饰器
        let contentView = ContentView().themeAware()
        popover?.contentViewController = NSHostingController(rootView: contentView)
    }

    func bindNotification() {
        // 添加图片选择完成后的通知处理
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("didSelectImageNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }

            // 关闭当前popover
            self.popover?.performClose(nil)

            // 重新显示popover
            if let button = self.statusItem?.button {
                self.popover?.show(
                    relativeTo: button.bounds,
                    of: button,
                    preferredEdge: .minY)
            }
        }

    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            // 右键点击显示菜单
            let menu = NSMenu()

            // 添加菜单项
            menu.addItem(
                NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(
                NSMenuItem(
                    title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            )

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

    // 打开添加事件页面
    @objc func openSettings() {
        if settingsWindow == nil {
            // 重置选项卡状态
            settingsState.selectedTab = 0

            // 创建设置视图并应用环境对象
            let contentView = AnyView(SettingsView().environmentObject(settingsState))

            // 创建视图控制器
            settingsViewController = NSHostingController(rootView: contentView)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable, .miniaturizable],  // 系统标题栏
                backing: .buffered,
                defer: false
            )

            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("Settings")
            settingsWindow?.contentViewController = settingsViewController
            settingsWindow?.title = "设置"  // 设置窗口标题
            settingsWindow?.isReleasedWhenClosed = false

            // 创建工具栏
            let toolbar = NSToolbar(identifier: "SettingsToolbar")
            toolbar.allowsUserCustomization = false
            toolbar.displayMode = .iconAndLabel  // 同时显示图标和标签
            toolbar.delegate = self

            // 设置工具栏
            settingsWindow?.toolbar = toolbar

            // 默认选中第一个标签页
            DispatchQueue.main.async {
                self.selectGeneralTab(self)
            }
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // 标签页切换方法
    @objc func selectGeneralTab(_ sender: Any) {
        // 更新状态
        settingsState.selectedTab = 0

        // 更新工具栏项的选中状态
        if let toolbar = settingsWindow?.toolbar {
            for item in toolbar.items {

                if item.itemIdentifier.rawValue == "General" {
                    item.image = NSImage(
                        systemSymbolName: "gear",
                        accessibilityDescription: "通用")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "Sync" {
                    item.image = NSImage(
                        systemSymbolName: "arrow.triangle.2.circlepath.circle",
                        accessibilityDescription: "同步")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "About" {
                    item.image = NSImage(
                        systemSymbolName: "info.circle",
                        accessibilityDescription: "关于")?
                        .withSymbolConfiguration(iconConfig)
                }
            }
        }
    }

    @objc func selectSyncTab(_ sender: Any) {
        // 更新状态
        settingsState.selectedTab = 1

        // 更新工具栏项的选中状态
        if let toolbar = settingsWindow?.toolbar {
            for item in toolbar.items {

                if item.itemIdentifier.rawValue == "Sync" {
                    item.image = NSImage(
                        systemSymbolName: "arrow.triangle.2.circlepath.circle.fill",
                        accessibilityDescription: "同步")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "General" {
                    item.image = NSImage(
                        systemSymbolName: "gear",
                        accessibilityDescription: "通用")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "About" {
                    item.image = NSImage(
                        systemSymbolName: "info.circle",
                        accessibilityDescription: "关于")?
                        .withSymbolConfiguration(iconConfig)
                }
            }
        }
    }

    @objc func selectAboutTab(_ sender: Any) {
        // 更新状态
        settingsState.selectedTab = 2

        // 更新工具栏项的选中状态
        if let toolbar = settingsWindow?.toolbar {
            for item in toolbar.items {
                if item.itemIdentifier.rawValue == "About" {
                    item.image = NSImage(
                        systemSymbolName: "info.circle.fill",
                        accessibilityDescription: "关于")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "General" {
                    item.image = NSImage(
                        systemSymbolName: "gear",
                        accessibilityDescription: "通用")?
                        .withSymbolConfiguration(iconConfig)
                } else if item.itemIdentifier.rawValue == "Sync" {
                    item.image = NSImage(
                        systemSymbolName: "arrow.triangle.2.circlepath.circle",
                        accessibilityDescription: "同步")?
                        .withSymbolConfiguration(iconConfig)
                }
            }
        }
    }

    // NSToolbarDelegate 方法
    func toolbar(
        _ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)

        if itemIdentifier == NSToolbarItem.Identifier("General") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "通用"
            item.paletteLabel = "通用"
            item.toolTip = "通用设置"
            item.image = NSImage(
                systemSymbolName: "gear",
                accessibilityDescription: "通用")?
                .withSymbolConfiguration(symbolConfig)
            item.action = #selector(selectGeneralTab(_:))
            item.target = self
            item.isBordered = true
            return item

        } else if itemIdentifier == NSToolbarItem.Identifier("Sync") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "同步"
            item.paletteLabel = "同步"
            item.toolTip = "同步设置"
            item.image = NSImage(
                systemSymbolName: "arrow.triangle.2.circlepath.circle",
                accessibilityDescription: "同步")?
                .withSymbolConfiguration(symbolConfig)
            item.action = #selector(selectSyncTab(_:))
            item.target = self
            item.isBordered = true
            return item

        } else if itemIdentifier == NSToolbarItem.Identifier("About") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "关于"
            item.paletteLabel = "关于"
            item.toolTip = "关于应用"
            item.image = NSImage(
                systemSymbolName: "info.circle",
                accessibilityDescription: "关于")?
                .withSymbolConfiguration(symbolConfig)
            item.action = #selector(selectAboutTab(_:))
            item.target = self
            item.isBordered = true
            return item

        } else if itemIdentifier == NSToolbarItem.Identifier.flexibleSpace {
            return NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.flexibleSpace)
        }

        return nil
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            NSToolbarItem.Identifier("General"),
            NSToolbarItem.Identifier("Sync"),
            NSToolbarItem.Identifier("About"),
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
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
