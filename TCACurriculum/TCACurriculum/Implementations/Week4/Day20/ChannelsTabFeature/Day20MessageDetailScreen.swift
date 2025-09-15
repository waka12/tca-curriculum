//
//  Day20MessageDetailScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20MessageDetailScreen: View {
    @Bindable var store: StoreOf<Day20MessageDetailFeature>
    var body: some View {
        Text(store.item.message)
    }
}

#Preview {
    Day20MessageDetailScreen(store: Store(initialState: Day20MessageDetailFeature.State(item: .init(id: UUID(), message: "hi"))) {
        Day20MessageDetailFeature()
    })
}
