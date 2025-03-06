//
//  day_jsApp.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import SwiftUI

@main
struct day_jsApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    self.showSplash = false
                                }
                            }
                        }
                } else {
                    ContentView()
                }
            }
            .frame(minWidth: 400, minHeight: 500)
            .onAppear {
                // 设置窗口标题
                NSWindow.allowsAutomaticWindowTabbing = false
                if let window = NSApplication.shared.windows.first {
                    window.title = "倒计时"
                    window.titleVisibility = .visible
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
