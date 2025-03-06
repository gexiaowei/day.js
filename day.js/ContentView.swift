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
                    List {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(countdownStore: countdownStore, event: event)) {
                                CountdownCardView(event: event)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        }
                        .onDelete(perform: deleteEvents)
                    }
                    .listStyle(.plain)
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
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(countdownStore: countdownStore)
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
