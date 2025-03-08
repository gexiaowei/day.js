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
    @State var showingPopover: Bool = false {
        didSet {
            if !showingPopover {
                // 当 popover 关闭时重新加载数据
                countdownStore.load()
                // 重置当前视图状态
                currentView = .eventList
            } else if popoverType == .add {
                // 当显示 popover 且类型为 add 时，设置当前视图为添加事件
                currentView = .addEvent
            }
        }
    }
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
    
    // 添加一个公共方法用于显示添加事件界面
    public func showAddEvent() {
        showingPopover = true
        popoverType = .add
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
                            SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor).themeAware()
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("添加事件")
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
                            SFSymbolIcon(symbol: .checkCircle, size: 22, color: .green).themeAware()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    AddEventView(countdownStore: countdownStore)
                }
                .opacity(currentView == .addEvent ? 1 : 0)
                .offset(x: currentView == .addEvent ? 0 : 500)
                .zIndex(currentView == .addEvent ? 2 : 0)
            }
            
            // 编辑事件视图
            if let event = selectedEvent {
                editEventView(event: event)
                    .opacity(currentView == .editEvent ? 1 : 0)
                    .offset(x: currentView == .editEvent ? 0 : 500)
                    .zIndex(currentView == .editEvent ? 3 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentView)
        .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
            VStack {
                if popoverType == .add {
                    VStack(spacing: 0) {
                        // 顶部标题栏
                        HStack {
                            Text("添加事件")
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button {
                                countdownStore.load()
                                showingPopover = false
                            } label: {
                                SFSymbolIcon(symbol: .checkCircle, size: 22, color: .green).themeAware()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .background(Color(NSColor.windowBackgroundColor))
                        
                        AddEventView(countdownStore: countdownStore)
                    }
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
                Text("倒计时")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .addEvent
                    }
                } label: {
                    SFSymbolIcon(symbol: .plus, size: 22, color: .accentColor).themeAware()
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
                    SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor).themeAware()
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .editEvent
                    }
                } label: {
                    SFSymbolIcon(symbol: .pencil, size: 22, color: .accentColor).themeAware()
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
                                SFSymbolIcon(symbol: .calendar, size: 24, color: .secondary).themeAware()
                                    .frame(width: 24)
                                
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
                                SFSymbolIcon(symbol: .calendar, size: 24, color: .secondary).themeAware()
                                    .frame(width: 24)
                                
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
                                    SFSymbolIcon(symbol: .calendar, size: 24, color: .secondary).themeAware()
                                        .frame(width: 24)
                                    
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
                                SFSymbolIcon(symbol: .repeatIcon, size: 24, color: .secondary).themeAware()
                                    .frame(width: 24)
                                
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
                                    SFSymbolIcon(symbol: .calendar, size: 24, color: .secondary).themeAware()
                                        .frame(width: 24)
                                    
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
                                        SFSymbolIcon(symbol: .calendar, size: 24, color: .secondary).themeAware()
                                            .frame(width: 24)
                                        
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
                                SFSymbolIcon(symbol: .note, size: 24, color: .secondary).themeAware()
                                    .frame(width: 24)
                                
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
                
                Text("编辑事件")
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
                    SFSymbolIcon(symbol: .checkCircle, size: 22, color: .green).themeAware()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))
            
            EditEventView(countdownStore: countdownStore, event: event)
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
