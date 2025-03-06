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
    @State private var searchText = ""
    @State private var showingAbout = false
    
    var filteredEvents: [CountdownEvent] {
        if searchText.isEmpty {
            return countdownStore.events
        } else {
            return countdownStore.events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if countdownStore.events.isEmpty {
                    ContentUnavailableView(
                        "没有倒计时事件",
                        systemImage: "calendar.badge.clock",
                        description: Text("点击右上角的+按钮添加新的倒计时事件")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
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
                    .searchable(text: $searchText, prompt: "搜索事件")
                }
            }
            .navigationTitle("倒计时")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .padding(8)
                            .background(Circle().fill(Color.blue))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(countdownStore: countdownStore)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
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
