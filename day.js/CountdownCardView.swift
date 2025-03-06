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
                
                Text(formattedDate(event.targetDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
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