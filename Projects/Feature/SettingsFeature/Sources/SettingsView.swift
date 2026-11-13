import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 설정 화면. 와이어프레임 S13~S14
public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section("화면") {
                Picker("화면 모드", selection: $store.theme.sending(\.themeChanged)) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: DSSpacing.s, leading: DSSpacing.m, bottom: DSSpacing.s, trailing: DSSpacing.m))
            }
            .listRowBackground(Color.dsSurface)

            Section("데이터") {
                Button {
                    store.send(.clearRecentKeywordsTapped)
                } label: {
                    Text("최근 검색어 전체 삭제")
                        .typography(.body)
                        .foregroundStyle(.dsError)
                        .frame(maxWidth: .infinity, minHeight: DSSize.minTouch, alignment: .leading)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(store.recentKeywordCount == 0)
                .opacity(store.recentKeywordCount == 0 ? 0.4 : 1)
            }
            .listRowBackground(Color.dsSurface)

            Section("정보") {
                DSListRow("앱 버전", value: Bundle.main.appVersion, showsChevron: false)
                #if DEBUG
                DSListRow("서버 주소", value: Bundle.main.apiHost, showsChevron: false)
                #endif
                NavigationLink {
                    LicensesView()
                } label: {
                    Text("오픈소스 라이선스")
                        .typography(.body)
                        .foregroundStyle(.dsTextPrimary)
                        .frame(minHeight: DSSize.minTouch)
                }
            }
            .listRowBackground(Color.dsSurface)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(.dsBackground)
        .navigationTitle("설정")
        .toolbarTitleDisplayMode(.inline)
        .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.onAppear).finish() }
    }
}

/// 오픈소스 라이선스 목록 (S14-B)
struct LicensesView: View {
    private let licenses: [(name: String, license: String)] = [
        ("Pretendard", "SIL OFL 1.1"),
        ("swift-composable-architecture", "MIT"),
        ("Alamofire", "MIT"),
        ("Kingfisher", "MIT"),
        ("sqlite-data", "MIT"),
        ("GRDB.swift", "MIT"),
    ]

    var body: some View {
        List(licenses, id: \.name) { item in
            DSListRow(item.name, value: item.license, showsChevron: false)
                .listRowBackground(Color.dsSurface)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(.dsBackground)
        .navigationTitle("오픈소스 라이선스")
        .toolbarTitleDisplayMode(.inline)
    }
}

extension AppTheme {
    /// nil이면 시스템 설정을 따른다
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

extension Bundle {
    /// "1.0.0 (1)"
    fileprivate var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }

    /// Info.plist `APIBaseURL`의 host:port
    fileprivate var apiHost: String {
        guard
            let value = infoDictionary?["APIBaseURL"] as? String,
            let url = URL(string: value),
            let host = url.host()
        else { return "-" }
        return url.port.map { "\(host):\($0)" } ?? host
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            }
        )
    }
}
