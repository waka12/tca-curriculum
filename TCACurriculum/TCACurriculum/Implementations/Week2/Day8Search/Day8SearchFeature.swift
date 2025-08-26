//
//  Day8SearchFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/27.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day8SearchFeature {
    @ObservableState
    struct State {
        var searchText: String = ""
        var searchResults: [SearchResult] = []
        var isSearching: Bool = false
    }

    enum Action: BindableAction {
        case search
        case searchResponse(TaskResult<[SearchResult]>)
        case binding(BindingAction<State>)
    }

    private enum CancelID {
        case search
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.searchClient) var searchClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .search:
                state.isSearching = true
                state.searchResults = []
                let searchText = state.searchText
                return .run { send in
                    await send(.searchResponse(
                        TaskResult {
                            try await searchClient.search(searchText)
                        }
                    ))
                }
            case .searchResponse(.success(let searchResults)):
                state.searchResults = searchResults
                state.isSearching = false
                return .none
            case .searchResponse(.failure(_)):
                state.isSearching = false
                return .none
            case .binding(\.searchText):
                guard !state.searchText.isEmpty else {
                    return .cancel(id: CancelID.search)
                }
                return .run { send in
                    try await clock.sleep(for: .milliseconds(500))
                    await send(.search)
                }
                .cancellable(id: CancelID.search)
            case .binding(_):
                return .none
            }
        }
    }
}

struct SearchClient {
    var search: @Sendable (String) async throws -> [SearchResult]
}

extension SearchClient: DependencyKey {
    static let liveValue = Self(search: { query in
        try await Task.sleep(for: .seconds(1))
        return [
            SearchResult(title: "\(query) Result1"),
            SearchResult(title: "\(query) Result2"),
            SearchResult(title: "\(query) Result3")
        ]
    })
}

extension DependencyValues {
    var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}

struct SearchResult: Identifiable {
    var id: UUID = UUID()
    var title: String
}
