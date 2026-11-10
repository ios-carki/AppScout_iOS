import SwiftUI
import UIKit

/// 타이포그래피 스케일 (Pretendard).
///
/// - 크기와 행간은 pt 단위, 행간은 "줄 높이(line height)" 기준이다.
/// - `relativeTo`로 시스템 텍스트 스타일에 연결해서 Dynamic Type(글자 크기 설정)을 따른다.
///
/// ```swift
/// Text("검색").typography(.title1)
/// ```
public enum DSTypography: CaseIterable, Sendable {
    /// 28 / 36, Bold: 큰 화면 제목 (탭 루트의 large title 대체 용도)
    case display
    /// 22 / 30, Bold: 섹션 제목, 상세 화면 앱 이름
    case title1
    /// 20 / 28, SemiBold: 카드 제목
    case title2
    /// 17 / 24, SemiBold: 리스트 셀 제목, 버튼
    case headline
    /// 16 / 24, Regular: 본문
    case body
    /// 15 / 22, Medium: 보조 본문, 입력창
    case callout
    /// 13 / 18, Regular: 메타 정보(장르, 평점 수)
    case caption
    /// 11 / 14, Medium: 배지, 태그
    case caption2

    public var size: CGFloat {
        switch self {
        case .display: 28
        case .title1: 22
        case .title2: 20
        case .headline: 17
        case .body: 16
        case .callout: 15
        case .caption: 13
        case .caption2: 11
        }
    }

    public var lineHeight: CGFloat {
        switch self {
        case .display: 36
        case .title1: 30
        case .title2: 28
        case .headline: 24
        case .body: 24
        case .callout: 22
        case .caption: 18
        case .caption2: 14
        }
    }

    public var weight: DSFontWeight {
        switch self {
        case .display, .title1: .bold
        case .title2, .headline: .semiBold
        case .callout, .caption2: .medium
        case .body, .caption: .regular
        }
    }

    /// Dynamic Type 기준이 되는 시스템 텍스트 스타일
    public var textStyle: Font.TextStyle {
        switch self {
        case .display: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .caption: .caption
        case .caption2: .caption2
        }
    }

    /// 자간(tracking). 큰 글씨는 살짝 좁혀서 단단하게 보이게 한다.
    public var tracking: CGFloat {
        switch self {
        case .display: -0.4
        case .title1, .title2: -0.2
        default: 0
        }
    }

    public var font: Font {
        .custom(weight.fontName, size: size, relativeTo: textStyle)
    }

    /// `lineSpacing`에 넣을 값 = 원하는 줄 높이 - 폰트 자체 줄 높이
    var lineSpacing: CGFloat {
        let uiFont = UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
        return max(0, lineHeight - uiFont.lineHeight)
    }
}

/// Pretendard 굵기 (번들에 포함된 4종만)
public enum DSFontWeight: Sendable {
    case regular, medium, semiBold, bold

    public var fontName: String {
        switch self {
        case .regular: DesignSystemFontFamily.Pretendard.regular.name
        case .medium: DesignSystemFontFamily.Pretendard.medium.name
        case .semiBold: DesignSystemFontFamily.Pretendard.semiBold.name
        case .bold: DesignSystemFontFamily.Pretendard.bold.name
        }
    }
}

// MARK: - View Modifier

private struct TypographyModifier: ViewModifier {
    let style: DSTypography

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
            // lineSpacing은 줄 사이에만 들어가므로, 한 줄짜리 텍스트도 높이를 맞추기 위해 위아래로 반씩 보정
            .padding(.vertical, style.lineSpacing / 2)
    }
}

extension View {
    /// 디자인 시스템 타이포그래피(폰트, 자간, 행간)를 한 번에 적용한다.
    public func typography(_ style: DSTypography) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

// MARK: - 폰트 등록

public enum DesignSystem {
    /// 앱 시작 시 한 번 호출해서 번들에 포함된 Pretendard 폰트를 등록한다.
    /// (Info.plist의 UIAppFonts 대신 코드로 등록 → 프레임워크 번들 폰트도 사용 가능)
    public static func registerFonts() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
}
