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
                        insertion: .opacity,
                        removal: .move(edge: .leading)
                    ))
            }
            
            // 事件详情视图
            if currentView == .eventDetail, let event = selectedEvent {
                eventDetailView(event: event)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentView)
        .popover(isPresented: $showingPopover) {
            TabView(selection: $popoverType) {
                AddEventView(countdownStore: countdownStore)
                    .frame(width: 300, height: 500)
                    .onDisappear {
                        // 在添加页面关闭后重新加载数据
                        countdownStore.load()
                    }
                    .tag(PopoverType.add)
                
                if let event = selectedEvent {
                    EventDetailView(countdownStore: countdownStore, event: event)
                        .frame(width: 300, height: 500)
                        .onDisappear {
                            // 在详情页关闭后重新加载数据
                            countdownStore.load()
                        }
                        .tag(PopoverType.detail)
                    
                    EditEventView(countdownStore: countdownStore, event: event)
                        .frame(width: 300, height: 600)
                        .onDisappear {
                            // 在编辑页面关闭后重新加载数据
                            countdownStore.load()
                        }
                        .tag(PopoverType.edit)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #else
            .tabViewStyle(.automatic)
            #endif
            .animation(.easeInOut(duration: 0.2), value: popoverType)
            .presentationCompactAdaptation(.popover)
        }
        .onAppear {
            countdownStore.load()
        }
    }
    
    // 事件列表视图
    private var eventListView: some View {
        VStack {
            // 顶部标题和添加按钮
            HStack {
                Text("倒计时")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    popoverType = .add
                    showingPopover = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .id("addButton")
            }
            .padding(.horizontal)
            
            // 主内容区域
            if countdownStore.events.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("没有倒计时事件")
                        .font(.title2)
                        .fontWeight(.medium)
                    
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
                                        .fill(Color.white.opacity(0.05))
                                        .shadow(color: Color(event.color).opacity(0.2), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(event.color).opacity(0.3), lineWidth: 1)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    selectedEvent = event
                                    withAnimation {
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
            }
        }
    }
    
    // 事件详情视图
    private func eventDetailView(event: CountdownEvent) -> some View {
        VStack {
            // 顶部标题和返回按钮
            HStack {
                Button {
                    withAnimation {
                        currentView = .eventList
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button {
                    popoverType = .edit
                    showingPopover = true
                } label: {
                    Text("编辑")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // 倒计时显示
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Text("\(abs(event.daysRemaining))")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(Color(event.color))
                            
                            Text(event.isPast ? "天前" : "天后")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 30)
                    
                    // 如果有图片，显示图片
                    if let imageData = event.imageData, let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Rectangle())
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // 事件信息
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("日历类型:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(event.calendarType.rawValue)
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("日期:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if event.calendarType == .lunar {
                                Text(formattedLunarDate(event.targetDate))
                                    .font(.headline)
                            } else {
                                Text(formattedDate(event.targetDate))
                                    .font(.headline)
                            }
                        }
                        
                        // 如果是农历，显示对应的公历日期
                        if event.calendarType == .lunar {
                            HStack {
                                Text("公历日期:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(formattedDate(event.targetDate))
                                    .font(.headline)
                            }
                        }
                        
                        HStack {
                            Text("重复周期:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(event.repeatCycle.rawValue)
                                .font(.headline)
                        }
                        
                        if event.repeatCycle != .none, let nextDate = event.nextOccurrence() {
                            HStack {
                                Text("下次日期:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(formattedDate(nextDate))
                                    .font(.headline)
                            }
                            
                            // 如果是农历，显示下次日期的农历表示
                            if event.calendarType == .lunar {
                                HStack {
                                    Text("下次农历:")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text(formattedLunarDate(nextDate))
                                        .font(.headline)
                                }
                            }
                        }
                        
                        if !event.note.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("备注:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(event.note)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
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
