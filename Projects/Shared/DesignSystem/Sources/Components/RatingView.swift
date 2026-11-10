import SwiftUI

/// 별점 + 평가 수 표시 (예: ★★★★☆ 4.3 · 1.2만)
public struct RatingView: View {
    private let rating: Double
    private let count: Int?
    private let starSize: CGFloat

    /// - Parameters:
    ///   - rating: 0.0 ~ 5.0
    ///   - count: 평가 수 (nil이면 표시 안 함)
    public init(rating: Double, count: Int? = nil, starSize: CGFloat = 12) {
        self.rating = min(max(rating, 0), 5)
        self.count = count
        self.starSize = starSize
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: symbol(for: index))
                        .font(.system(size: starSize, weight: .semibold))
                        .foregroundStyle(.dsRating)
                }
            }
            Text(rating, format: .number.precision(.fractionLength(1)))
                .typography(.caption)
                .foregroundStyle(.dsTextSecondary)
            if let count {
                Text("· \(Self.compactCount(count))")
                    .typography(.caption)
                    .foregroundStyle(.dsTextSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 0.75 { return "star.fill" }
        if value >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }

    private var accessibilityText: String {
        let base = "별점 \(String(format: "%.1f", rating))점"
        guard let count else { return base }
        return base + ", 평가 \(count)개"
    }

    /// 12345 → "1.2만", 980 → "980"
    public static func compactCount(_ count: Int) -> String {
        switch count {
        case 100_000_000...: String(format: "%.1f억", Double(count) / 100_000_000)
        case 10_000...: String(format: "%.1f만", Double(count) / 10_000)
        case 1_000...: String(format: "%.1f천", Double(count) / 1_000)
        default: "\(count)"
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DSSpacing.s) {
        RatingView(rating: 4.6, count: 123_456)
        RatingView(rating: 3.2, count: 87)
        RatingView(rating: 0)
    }
    .padding()
}
