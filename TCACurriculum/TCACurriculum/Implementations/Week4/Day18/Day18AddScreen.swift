//
//  Day18AddScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/10.
//

import SwiftUI
import ComposableArchitecture

struct Day18AddScreen: View {
    @Bindable var store: StoreOf<Day18AddFeature>

    var body: some View {
        Text("新規登録画面")
    }
}

#Preview {
    Day18AddScreen(store: Store(initialState: Day18AddFeature.State()) {
        Day18AddFeature()
    })
}
