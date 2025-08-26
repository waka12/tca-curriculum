//
//  Day8SearchScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/27.
//

import SwiftUI
import ComposableArchitecture

struct Day8SearchScreen: View {
    @Bindable var store: StoreOf<Day8SearchFeature>

    var body: some View {
        VStack(alignment: .leading) {
            if store.isSearching {
                ProgressView()
            }
            TextField("入力", text: $store.searchText)
            List(store.searchResults) { result in
                Text(result.title)
            }
        }
    }
}

#Preview {
    Day8SearchScreen(store: Store(initialState: Day8SearchFeature.State()) {
        Day8SearchFeature()
    })
}
