import AppKit
import Foundation
import RegexBuilder
import SwiftUI

struct CountdownCardView: View {
    let event: CountdownEvent
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            // 左侧图标
            Image(systemName: "gift.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color(event.color))
                .clipShape(Circle())

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
                        Text("下一个.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
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
                    .font(.system(size: isHovering ? 22 : 18, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                Text(event.daysRemaining < 0 ? "过期" : "剩余")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .cornerRadius(4)
        .onHover { hovering in
            isHovering = hovering
        }
    }

}
