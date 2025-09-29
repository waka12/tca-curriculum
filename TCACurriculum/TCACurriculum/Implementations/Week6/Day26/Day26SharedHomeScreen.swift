//
//  Day26SharedHomeScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/29.
//

import SwiftUI
import ComposableArchitecture

struct Day26SharedHomeScreen: View {
    @Bindable var store: StoreOf<Day26SharedHomeFeature>
    var body: some View {
        VStack(spacing: 16) {
            Text("ユーザー名: \(store.userName)")
            Text("未読数: \(store.unreadCount)")
        }
        .preferredColorScheme(store.theme == .light ? .light : .dark)
    }
}

#Preview {
    Day26SharedHomeScreen(store: Store(initialState: Day26SharedHomeFeature.State()) {
        Day26SharedHomeFeature()
    })
}
