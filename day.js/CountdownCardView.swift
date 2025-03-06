import SwiftUI
import AppKit

struct CountdownCardView: View {
    let event: CountdownEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(formattedDate(event.targetDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(event.color).opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text("\(abs(event.daysRemaining))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(event.color))
                }
            }
            
            if let imageData = event.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if event.repeatCycle != .none {
                // 如果没有图片但有重复周期，显示图标
                HStack {
                    Spacer()
                    
                    Image(systemName: cycleIcon(for: event.repeatCycle))
                        .font(.system(size: 40))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color(event.color))
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            HStack {
                Label {
                    Text(event.calendarType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if event.repeatCycle != .none {
                    Label {
                        Text(event.repeatCycle.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: cycleIcon(for: event.repeatCycle))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    private func cycleIcon(for cycle: RepeatCycle) -> String {
        switch cycle {
        case .none:
            return "xmark.circle"
        case .daily:
            return "clock"
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.clock"
        }
    }
} 