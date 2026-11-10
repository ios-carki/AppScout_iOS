import CoreGraphics

/// 간격 토큰 (4pt 그리드)
public enum DSSpacing {
    /// 4
    public static let xxs: CGFloat = 4
    /// 8
    public static let xs: CGFloat = 8
    /// 12
    public static let s: CGFloat = 12
    /// 16: 리스트 셀 내부 여백
    public static let m: CGFloat = 16
    /// 20: 화면 좌우 기본 여백
    public static let l: CGFloat = 20
    /// 24: 섹션 간격
    public static let xl: CGFloat = 24
    /// 32
    public static let xxl: CGFloat = 32

    /// 화면 좌우 기본 여백
    public static let screenHorizontal: CGFloat = l
}

/// 모서리 반경 토큰
public enum DSRadius {
    /// 6: 태그, 배지
    public static let xs: CGFloat = 6
    /// 10: 입력창, 버튼
    public static let s: CGFloat = 10
    /// 14: 카드
    public static let m: CGFloat = 14
    /// 20: 시트, 큰 카드
    public static let l: CGFloat = 20

    /// iOS 앱 아이콘 모양 비율 (아이콘 한 변 × 0.2237)
    public static func appIcon(size: CGFloat) -> CGFloat { size * 0.2237 }
}

/// 컴포넌트 크기 토큰
public enum DSSize {
    /// 최소 터치 영역 (HIG 44pt)
    public static let minTouch: CGFloat = 44
    /// 검색창 높이
    public static let searchBar: CGFloat = 44
    /// 기본 버튼 높이
    public static let button: CGFloat = 52
    /// 리스트 셀 앱 아이콘
    public static let iconList: CGFloat = 60
    /// 상세 화면 앱 아이콘
    public static let iconDetail: CGFloat = 100
    /// 프로필 이미지
    public static let avatar: CGFloat = 88
}
