//
//  ContentView.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var countdownStore = CountdownStore()
    @State private var showingAddEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEventId: UUID? = nil

    @State var popoverType: PopoverType = .add
    @State var currentView: ViewType = .eventList

    public enum PopoverType {
        case add
        case detail
        case edit
    }

    public enum ViewType {
        case eventList
        case eventDetail
        case addEvent
        case editEvent
    }

    var body: some View {
        ZStack {
            // 事件列表视图始终在最底层
            EventListView(
                countdownStore: countdownStore,
                onAddEventTapped: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .addEvent
                    }
                },
                onEventSelected: { event in
                    selectedEventId = event.id
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventDetail
                    }
                }
            )
            .zIndex(0)

            // 事件详情视图
            if let eventId = selectedEventId {
                EventDetailView(
                    countdownStore: countdownStore,
                    eventId: eventId,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .eventList
                        }
                    },
                    onEdit: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .editEvent
                        }
                    }
                )
                .opacity(currentView == .eventDetail ? 1 : 0)
                .offset(x: currentView == .eventDetail ? 0 : 500)
                .zIndex(currentView == .eventDetail ? 1 : 0)
            }

            // 添加事件视图
            EventAddView(
                countdownStore: countdownStore,
                onBack: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventList
                    }
                },
                onSave: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventList
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .opacity(currentView == .addEvent ? 1 : 0)
            .offset(x: currentView == .addEvent ? 0 : 500)
            .zIndex(currentView == .addEvent ? 2 : 0)

            // 编辑事件视图
            if let eventId = selectedEventId {
                EventEditView(
                    countdownStore: countdownStore,
                    eventId: eventId,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .eventDetail
                        }
                    },
                    onSave: {
                        countdownStore.load()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .eventDetail
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .opacity(currentView == .editEvent ? 1 : 0)
                .offset(x: currentView == .editEvent ? 0 : 500)
                .zIndex(currentView == .editEvent ? 3 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: currentView)
        .themeAware()
        .onAppear {
            countdownStore.load()

            // 添加通知监听，当删除事件时返回到事件列表
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("didDeleteEventNotification"),
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentView = .eventList
                }
            }
        }
        .onDisappear {
            // 移除通知监听
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        countdownStore.deleteEvent(at: offsets)
    }
}

#Preview {
    ContentView()
}
