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
    @State private var selectedEvent: CountdownEvent? = nil

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
                    selectedEvent = event
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventDetail
                    }
                }
            )
            .zIndex(0)

            // 事件详情视图
            if let event = selectedEvent {
                EventDetailView(
                    countdownStore: countdownStore,
                    event: event,
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
            Group {
                VStack(spacing: 0) {
                    // 顶部标题和返回按钮
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .eventList
                            }
                        } label: {
                            SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor)
                                .themeAware()
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("添加事件")
                            .font(.system(size: 20, weight: .bold))
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.primary)

                        Spacer()

                        Button {
                            countdownStore.load()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .eventList
                            }
                        } label: {
                            Text("保存")
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color(NSColor.windowBackgroundColor))

                    AddEventView(countdownStore: countdownStore)
                }
                .frame(maxWidth: .infinity)
                .opacity(currentView == .addEvent ? 1 : 0)
                .offset(x: currentView == .addEvent ? 0 : 500)
                .zIndex(currentView == .addEvent ? 2 : 0)
            }

            // 编辑事件视图
            if let event = selectedEvent {
                editEventView(event: event)
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

    // 编辑事件视图
    private func editEventView(event: CountdownEvent) -> some View {
        VStack(spacing: 0) {
            // 顶部标题和返回按钮
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventDetail
                    }
                } label: {
                    SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor)
                        .themeAware()
                }
                .buttonStyle(.plain)

                Spacer()

                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    countdownStore.load()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventDetail
                    }
                } label: {
                    Text("保存")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))

            EditEventView(countdownStore: countdownStore, event: event)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteEvents(at offsets: IndexSet) {
        countdownStore.deleteEvent(at: offsets)
    }
}

#Preview {
    ContentView()
}
