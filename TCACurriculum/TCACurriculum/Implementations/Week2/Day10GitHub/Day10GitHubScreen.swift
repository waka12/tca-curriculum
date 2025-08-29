//
//  Day10GitHubScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/29.
//

import SwiftUI
import ComposableArchitecture

struct Day10GitHubScreen: View {
    @Bindable var store: StoreOf<Day10GitHubFeature>

    var body: some View {
        List {
            Section {
                switch store.uiState {
                case .searchHistory:
                    ForEach(Array(store.searchHistories), id: \.self) { searchHistory in
                        Text(searchHistory)
                    }
                case .repository:
                    ForEach(store.repositories) { repository in
                        HStack {
                            Text(repository.name)
                        }
                    }
                case .loading:
                    ProgressView()
                case .error:
                    Text(store.error ?? "未知のエラーです")
                }
            } header: {
                TextField("検索", text: $store.searchText)
            }
        }
    }
}

#Preview {
    Day10GitHubScreen(store: Store(initialState: Day10GitHubFeature.State()) {
        Day10GitHubFeature()
    })
}
