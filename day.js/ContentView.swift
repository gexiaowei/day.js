//
//  ContentView.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var countdownStore = CountdownStore()
    @State private var showingAddEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEvent: CountdownEvent? = nil
    @State private var showingPopover = false
    @State private var popoverType: PopoverType = .add
    @State private var currentView: ViewType = .eventList
    
    enum PopoverType {
        case add
        case detail
        case edit
    }
    
    enum ViewType {
        case eventList
        case eventDetail
    }
    
    var body: some View {
        ZStack {
            // 事件列表视图
            if currentView == .eventList {
                eventListView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            
            // 事件详情视图
            if currentView == .eventDetail, let event = selectedEvent {
                eventDetailView(event: event)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentView)
        .popover(isPresented: $showingPopover) {
            VStack {
                if popoverType == .add {
                    AddEventView(countdownStore: countdownStore)
                        .frame(width: 300, height: 500)
                        .onDisappear {
                            // 在添加页面关闭后重新加载数据
                            countdownStore.load()
                        }
                } else if let event = selectedEvent {
                    if popoverType == .detail {
                        EventDetailView(countdownStore: countdownStore, event: event)
                            .frame(width: 300, height: 500)
                            .onDisappear {
                                // 在详情页关闭后重新加载数据
                                countdownStore.load()
                            }
                    } else if popoverType == .edit {
                        EditEventView(countdownStore: countdownStore, event: event)
                            .frame(width: 300, height: 600)
                            .onDisappear {
                                // 在编辑页面关闭后重新加载数据
                                countdownStore.load()
                            }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: popoverType)
            .presentationCompactAdaptation(.popover)
            .themeAware()
        }
        .themeAware()
        .onAppear {
            countdownStore.load()
            
            // 添加通知监听，当删除事件时返回到事件列表
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ReturnToEventList"),
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentView = .eventList
                    showingPopover = false
                }
            }
        }
    }
    
    // 事件列表视图
    private var eventListView: some View {
        VStack(spacing: 0) {
            // 顶部标题和添加按钮
            HStack {
                Text("倒计时")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    popoverType = .add
                    showingPopover = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
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
                    
                    Text("没有倒计时事件")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("点击右上角的+按钮添加新的倒计时事件")
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
                                    RoundedRectangle(cornerRadius: 16)
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
                                        if let index = countdownStore.events.firstIndex(where: { $0.id == event.id }) {
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
    }
    
    // 事件详情视图
    private func eventDetailView(event: CountdownEvent) -> some View {
        VStack(spacing: 0) {
            // 顶部标题和返回按钮
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .eventList
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    popoverType = .edit
                    showingPopover = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 倒计时显示
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("\(abs(event.daysRemaining))")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(Color(event.color))
                            
                            Text(event.isPast ? "天前" : "天后")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 24)
                    
                    // 如果有图片，显示图片
                    if let imageData = event.imageData, let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                    
                    // 事件信息
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            HStack(alignment: .top) {
                                Image(systemName: "calendar")
                                    .frame(width: 24)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("日历类型")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(event.calendarType.rawValue)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            HStack(alignment: .top) {
                                Image(systemName: "calendar.badge.clock")
                                    .frame(width: 24)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("日期")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if event.calendarType == .lunar {
                                        Text(formattedLunarDate(event.targetDate))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(formattedDate(event.targetDate))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            
                            // 如果是农历，显示对应的公历日期
                            if event.calendarType == .lunar {
                                HStack(alignment: .top) {
                                    Image(systemName: "calendar.day.timeline.left")
                                        .frame(width: 24)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("公历日期")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(formattedDate(event.targetDate))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            
                            HStack(alignment: .top) {
                                Image(systemName: "repeat")
                                    .frame(width: 24)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("重复周期")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(event.repeatCycle.rawValue)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            if event.repeatCycle != .none, let nextDate = event.nextOccurrence() {
                                HStack(alignment: .top) {
                                    Image(systemName: "calendar.badge.plus")
                                        .frame(width: 24)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("下次日期")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(formattedDate(nextDate))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                // 如果是农历，显示下次日期的农历表示
                                if event.calendarType == .lunar {
                                    HStack(alignment: .top) {
                                        Image(systemName: "calendar.badge.plus")
                                            .frame(width: 24)
                                            .foregroundColor(.secondary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("下次农历")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(formattedLunarDate(nextDate))
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !event.note.isEmpty {
                            HStack(alignment: .top) {
                                Image(systemName: "note.text")
                                    .frame(width: 24)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("备注")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(event.note)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    private func formattedLunarDate(_ date: Date) -> String {
        return LunarDateConverter.formatLunarDate(from: date)
    }
    
    private func deleteEvents(at offsets: IndexSet) {
        countdownStore.deleteEvent(at: offsets)
    }
}

#Preview {
    ContentView()
}
