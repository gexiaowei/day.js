import SwiftUI
import PhotosUI
import AppKit

struct EventDetailView: View {
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                        Text("标题:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(event.title)
                            .font(.headline)
                    }
                    
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
        .navigationTitle(event.title)
        .toolbar {
            Button("编辑") {
                isEditing = true
            }
        }
        .popover(isPresented: $isEditing) {
            EditEventView(countdownStore: countdownStore, event: event)
                .frame(width: 350, height: 600)
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
} 