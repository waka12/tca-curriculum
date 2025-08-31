//
//  Day10GitHubFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/29.
//

import ComposableArchitecture
import Foundation

enum ListState: CaseIterable {
    case normal
    case favorite
}

@Reducer
struct Day10GitHubFeature {
    @ObservableState
    struct State {
        var searchText = ""
        var listRepositories: IdentifiedArrayOf<Repository> {
            switch listState {
            case .normal:
                return repositories
            case .favorite:
                return favorites
            }
        }
        var repositories: IdentifiedArrayOf<Repository> = []
        var favorites: IdentifiedArrayOf<Repository> = []
        var searchHistories: Set<String> = []
        var isLoading = false
        var error: String?
        var currentPage = 1
        var hasMorePages = true
        var uiState: UIState {
            if searchText.isEmpty {
                return .searchHistory
            } else if isLoading {
                return .loading
            } else if error != nil {
                return .error
            } else {
                return .repository
            }
        }
        var listState: ListState = .normal
    }

    enum Action: BindableAction {
        case search
        case searchResponse(TaskResult<GitHubSearchResult>)
        case addFavorite(Repository)
        case removeFavorite(Repository)
        case historyRowTapped(String)
        case loadNextPage
        case loadResponse(TaskResult<GitHubSearchResult>)
        case binding(BindingAction<State>)
    }

    enum UIState {
        case searchHistory
        case repository
        case loading
        case error
    }

    private enum CancelID {
        case search
    }

    @Dependency(\.githubClient) var githubClient
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .search:
                state.isLoading = true
                state.repositories = []
                state.error = nil
                state.listState = .normal
                state.currentPage = 1  // 追加が必要
                state.hasMorePages = true
                let searchText = state.searchText
                let searchPage = state.currentPage
                return .run { send in
                    await send(.searchResponse(
                        TaskResult {
                            try await githubClient.search(searchText, searchPage)
                        }
                    ))
                }
            case .searchResponse(.success(let searchResult)):
                state.repositories = IdentifiedArray(uniqueElements: searchResult.repositories)
                state.isLoading = false
                state.searchHistories.insert(state.searchText)
                return .none
            case .searchResponse(.failure(let error)):
                state.error = error.localizedDescription
                state.isLoading = false
                return .none
            case .addFavorite(let repository):
                if var repo = state.repositories[id: repository.id] {
                    repo.isFavorite = true
                    state.repositories[id: repository.id] = repo
                    state.favorites.append(repo)
                }
                return .none
            case .removeFavorite(let repository):
                if var repo = state.repositories[id: repository.id] {
                    repo.isFavorite = false
                    state.repositories[id: repository.id] = repo
                    state.favorites.remove(id: repo.id)
                }
                return .none
            case .historyRowTapped(let historyText):
                state.searchText = historyText
                return .none
            case .loadNextPage:
                guard state.hasMorePages && !state.isLoading else {
                    return .none
                }
                state.isLoading = true
                let searchText = state.searchText
                let searchPage = state.currentPage + 1
                return .run { send in
                    await send(.loadResponse(
                        TaskResult {
                            try await githubClient.search(searchText, searchPage)
                        }
                    ))
                }
            case .loadResponse(.success(let result)):
                state.currentPage += 1
                state.repositories.append(contentsOf: result.repositories)
                state.hasMorePages = result.hasMore
                return .none
            case .loadResponse(.failure(_)):
                state.isLoading = false
                return .none
            case .binding(\.searchText):
                guard !state.searchText.isEmpty else {
                    state.repositories = []
                    state.error = nil
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

struct Repository: Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let starCount: Int
    let language: String?
    var isFavorite: Bool = false
}

struct GitHubClient {
    var search: @Sendable (String, Int) async throws -> GitHubSearchResult
}

extension GitHubClient: DependencyKey {
    static var liveValue = Self(search: { query, page in
        try await Task.sleep(for: .seconds(1))

        if Int.random(in: 1...10) == 1 {
            throw GithubError.networkError
        }

        let repositories = (1...10).map { index in
            Repository(
                id: UUID(),
                name: "\(query)-repo-\(page)-\(index)",
                description: "Description for \(query) repository",
                starCount: Int.random(in: 0...1000),
                language: ["Swift", "JavaScript", "Python"].randomElement()
            )
        }

        return GitHubSearchResult(repositories: repositories, hasMore: page < 5)
    })
}

extension DependencyValues {
    var githubClient: GitHubClient {
        get { self[GitHubClient.self] }
        set { self[GitHubClient.self] = newValue }
    }
}

struct GitHubSearchResult {
    let repositories: [Repository]
    let hasMore: Bool
}

private enum GithubError: Error {
    case networkError
}
