import SwiftUI

/// 시맨틱 컬러 토큰.
///
/// 색상 값은 `Resources/Colors.xcassets`에 라이트/다크 쌍으로 정의돼 있고,
/// 코드에서는 항상 이 토큰 이름으로만 접근한다. (`.black`, `Color(hex:)` 같은 고정 색 사용 금지)
///
/// ```swift
/// Text("제목").foregroundStyle(DSColor.textPrimary)
/// Text("제목").foregroundStyle(.dsTextPrimary)   // ShapeStyle 축약형
/// ```
public enum DSColor {
    // MARK: Brand
    /// 주요 액션, 선택 상태, 링크
    public static var brandPrimary: Color { DesignSystemAsset.brandPrimary.swiftUIColor }
    /// 보조 강조(장르 태그, 배지)
    public static var brandSecondary: Color { DesignSystemAsset.brandSecondary.swiftUIColor }
    /// brandPrimary 위에 올라가는 텍스트·아이콘
    public static var onBrand: Color { DesignSystemAsset.onBrand.swiftUIColor }

    // MARK: Surface
    /// 화면 기본 배경
    public static var background: Color { DesignSystemAsset.background.swiftUIColor }
    /// 카드, 검색창, 리스트 그룹 배경
    public static var surface: Color { DesignSystemAsset.surface.swiftUIColor }
    /// 시트, 팝오버 등 떠 있는 면
    public static var surfaceElevated: Color { DesignSystemAsset.surfaceElevated.swiftUIColor }
    /// 구분선, 입력창 테두리
    public static var border: Color { DesignSystemAsset.border.swiftUIColor }

    // MARK: Text
    /// 본문, 제목
    public static var textPrimary: Color { DesignSystemAsset.textPrimary.swiftUIColor }
    /// 보조 설명, 메타 정보
    public static var textSecondary: Color { DesignSystemAsset.textSecondary.swiftUIColor }
    /// 플레이스홀더, 비활성 상태 전용. 대비가 낮으므로 본문에 쓰지 않는다.
    public static var textTertiary: Color { DesignSystemAsset.textTertiary.swiftUIColor }

    // MARK: Status
    public static var success: Color { DesignSystemAsset.success.swiftUIColor }
    public static var warning: Color { DesignSystemAsset.warning.swiftUIColor }
    public static var error: Color { DesignSystemAsset.error.swiftUIColor }
    /// 별점 아이콘
    public static var rating: Color { DesignSystemAsset.rating.swiftUIColor }
}

// MARK: - ShapeStyle 축약형

extension ShapeStyle where Self == Color {
    public static var dsBrandPrimary: Color { DSColor.brandPrimary }
    public static var dsBrandSecondary: Color { DSColor.brandSecondary }
    public static var dsOnBrand: Color { DSColor.onBrand }
    public static var dsBackground: Color { DSColor.background }
    public static var dsSurface: Color { DSColor.surface }
    public static var dsSurfaceElevated: Color { DSColor.surfaceElevated }
    public static var dsBorder: Color { DSColor.border }
    public static var dsTextPrimary: Color { DSColor.textPrimary }
    public static var dsTextSecondary: Color { DSColor.textSecondary }
    public static var dsTextTertiary: Color { DSColor.textTertiary }
    public static var dsSuccess: Color { DSColor.success }
    public static var dsWarning: Color { DSColor.warning }
    public static var dsError: Color { DSColor.error }
    public static var dsRating: Color { DSColor.rating }
}
