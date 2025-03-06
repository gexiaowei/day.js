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
    
    enum PopoverType {
        case add
        case detail
    }
    
    var body: some View {
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
                                    popoverType = .detail
                                    showingPopover = true
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
        .popover(isPresented: $showingPopover) {
            if popoverType == .add {
                AddEventView(countdownStore: countdownStore)
                    .frame(width: 400, height: 500)
                    .onDisappear {
                        // 在添加页面关闭后重新加载数据
                        countdownStore.load()
                    }
            } else if popoverType == .detail, let event = selectedEvent {
                EventDetailView(countdownStore: countdownStore, event: event)
                    .frame(width: 400, height: 500)
                    .onDisappear {
                        // 在详情页关闭后重新加载数据
                        countdownStore.load()
                    }
            }
        }
        .onAppear {
            countdownStore.load()
        }
    }
    
    private func deleteEvents(at offsets: IndexSet) {
        countdownStore.deleteEvent(at: offsets)
    }
}

#Preview {
    ContentView()
}
