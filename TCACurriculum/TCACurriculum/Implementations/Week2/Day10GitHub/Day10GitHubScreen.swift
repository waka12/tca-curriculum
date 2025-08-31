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
                            .onTapGesture {
                                store.send(.historyRowTapped(searchHistory))
                            }
                    }
                case .repository:
                    Picker("表示", selection: $store.listState) {
                        ForEach(ListState.allCases, id: \.self) { type in
                            switch type {
                            case .normal:
                                Text("通常")
                            case .favorite:
                                Text("お気に入り")
                            }
                        }
                    }
                    ForEach(store.listRepositories) { repository in
                        HStack {
                            Text(repository.name)
                            if repository.isFavorite {
                                Button {
                                    store.send(.removeFavorite(repository))
                                } label: {
                                    Image(systemName: "star.fill")
                                }
                            } else {
                                Button {
                                    store.send(.addFavorite(repository))
                                } label: {
                                    Image(systemName: "star")
                                }
                            }
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
        .refreshable {
            store.send(.loadNextPage)
        }
    }
}

#Preview {
    Day10GitHubScreen(store: Store(initialState: Day10GitHubFeature.State()) {
        Day10GitHubFeature()
    })
}
