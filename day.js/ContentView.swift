//
//  ContentView.swift
//  day.js
//
//  Created by 戈晓伟 on 2025/3/6.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var countdownStore = CountdownStore()
    @State private var showingAddEvent = false
    
    var body: some View {
        VStack {
            // 顶部标题和添加按钮
            HStack {
                Text("倒计时")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showingAddEvent = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 0, y: 2)
                }
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
                            NavigationLink(destination: EventDetailView(countdownStore: countdownStore, event: event)) {
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
                            }
                            .buttonStyle(PlainButtonStyle())
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
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(countdownStore: countdownStore)
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
