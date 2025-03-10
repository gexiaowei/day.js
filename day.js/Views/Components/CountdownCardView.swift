import AppKit
import Foundation
import RegexBuilder
import SwiftUI

struct CountdownCardView: View {
    let event: CountdownEvent
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 16) {
            // 左侧图标
            Group {
                if let imageData = event.imageData,
                    let nsImage = NSImage(data: imageData)
                {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .background(Color(event.color))
                        .clipShape(Circle())

                } else {
                    Image(systemName: "gift.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color(event.color))
                        .clipShape(Circle())
                }
            }

            // 中间标题和日期
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    if event.repeatCycle != .none {
                        Text(event.repeatCycle.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Text(
                        event.calendarType == .lunar
                            ? DateFormatUtils.formattedLunarDate(
                                event.targetDate, repeatCycle: event.repeatCycle)
                            : DateFormatUtils.formattedDate(
                                event.targetDate, repeatCycle: event.repeatCycle)
                    )
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }

                if event.repeatCycle != .none, let nextDate = event.nextOccurrence() {
                    HStack(spacing: 4) {
                        Text(
                            DateFormatUtils.formattedDate(nextDate, repeatCycle: .none)
                        )
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()

            // 右侧天数
            VStack(alignment: .trailing) {
                Text("\(abs(event.daysRemaining))天")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                Text(event.daysRemaining < 0 ? "过期" : "剩余")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(NSColor.windowBackgroundColor).opacity(isHovering ? 0.8 : 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            isHovering ? Color(event.color).opacity(0.3) : Color.clear, lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(isHovering ? 0.1 : 0.05), radius: 5, x: 0, y: 2)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}
