import SwiftUI

struct CountdownCardView: View {
    let event: CountdownEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if event.repeatCycle != .none {
                    Image(systemName: "repeat")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.trailing, 4)
                }
                
                Circle()
                    .fill(Color(event.color))
                    .frame(width: 12, height: 12)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text("\(abs(event.daysRemaining))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(event.color))
                
                Text(event.isPast ? "天前" : "天后")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(event.calendarType.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if event.repeatCycle != .none {
                            Text("·")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(event.repeatCycle.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(formattedDate(event.targetDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
} 