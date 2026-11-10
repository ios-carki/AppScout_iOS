import Testing
import UIKit
@testable import DesignSystem

@Suite("DesignSystem")
struct DesignSystemTests {
    @Test("번들에 포함된 Pretendard 4종이 등록된다")
    func fontsRegister() {
        DesignSystem.registerFonts()
        for weight in [DSFontWeight.regular, .medium, .semiBold, .bold] {
            #expect(UIFont(name: weight.fontName, size: 16) != nil, "\(weight.fontName) 미등록")
        }
    }

    @Test("줄 높이는 항상 글자 크기보다 크다")
    func lineHeightIsLargerThanSize() {
        for style in DSTypography.allCases {
            #expect(style.lineHeight > style.size)
        }
    }

    @Test("평가 수 축약 표기", arguments: [
        (980, "980"),
        (1_500, "1.5천"),
        (12_345, "1.2만"),
        (250_000_000, "2.5억"),
    ])
    func compactCount(count: Int, expected: String) {
        #expect(RatingView.compactCount(count) == expected)
    }
}
