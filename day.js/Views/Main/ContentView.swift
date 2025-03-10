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
            eventListView
                .zIndex(0)

            // 事件详情视图
            if let event = selectedEvent {
                eventDetailView(event: event)
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

    // 事件列表视图
    private var eventListView: some View {
        VStack(spacing: 0) {
            // 顶部标题和添加按钮
            HStack {
                Spacer()

                Text("DAY✦")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .addEvent
                    }
                } label: {
                    SFSymbolIcon(symbol: .plus, size: 18, color: .accentColor).themeAware()
                }
                .id("addButton")
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))

            // 主内容区域
            if countdownStore.events.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 70))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)

                    Text("没有事件")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("点击右上角的+按钮添加新的事件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(countdownStore.events) { event in
                            CountdownCardView(event: event)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(NSColor.windowBackgroundColor))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(event.color).opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    selectedEvent = event
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentView = .eventDetail
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        if let index = countdownStore.events.firstIndex(where: {
                                            $0.id == event.id
                                        }) {
                                            countdownStore.deleteEvent(at: IndexSet([index]))
                                        }
                                    }) {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // 事件详情视图
    private func eventDetailView(event: CountdownEvent) -> some View {
        VStack(spacing: 0) {
            // 顶部标题和返回按钮
            HStack(alignment: .center) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventList
                    }
                } label: {
                    SFSymbolIcon(symbol: .chevronLeft, size: 18, color: .accentColor).themeAware()
                }
                .buttonStyle(.plain)

                Spacer()

                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                HStack(alignment: .bottom, spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .editEvent
                        }
                    } label: {
                        Text("编辑")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .editEvent
                        }
                    } label: {
                        SFSymbolIcon(symbol: .squareAndArrowUp, size: 20, color: .accentColor)
                            .themeAware()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))

            EventDetailView(countdownStore: countdownStore, event: event)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor).themeAware()
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
