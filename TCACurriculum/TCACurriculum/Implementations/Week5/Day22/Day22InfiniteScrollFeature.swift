//
//  Day22InfiniteScrollFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day22InfiniteScrollFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day22Item> = []
        var currentPage = 1
        var hasNextPage = true
        var isLoading = false
        var isRefreshing = false
        var error: String?
    }

    enum Action {
        case onAppear
        case load
        case refresh
        case moreLoadInNeeded(Day22Item)
        case loadResponse(TaskResult<Day22ItemResult>)
    }

    @Dependency(\.day22Client) var day22Client

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.load)
                }
            case .load:
                state.isLoading = true
                state.error = nil
                return .run { [currentPage = state.currentPage] send in
                    await send(.loadResponse(
                        TaskResult {
                            try await day22Client.load(currentPage)
                        }
                    ))
                }
            case .refresh:
                state.items = []
                state.currentPage = 1
                return .run { send in
                    await send(.load)
                }
            case let .moreLoadInNeeded(item):
                guard item.id == state.items.last?.id, state.hasNextPage else {
                    return .none
                }
                return .run { send in
                    await send(.load)
                }
            case let .loadResponse(.success(result)):
                state.items.append(contentsOf: IdentifiedArray(uniqueElements: result.items))
                state.hasNextPage = result.hasMore
                state.isLoading = false
                state.currentPage += 1
                return .none
            case let .loadResponse(.failure(error)):
                state.error = error.localizedDescription
                state.isLoading = false
                return .none
            }
        }
    }
}

struct Day22Client {
    var load: @Sendable (Int) async throws -> Day22ItemResult
}

extension Day22Client: DependencyKey {
    static var liveValue = Self(load: { page in
        try await Task.sleep(for: .seconds(1))
        if Int.random(in: 1...10) == 1 {
            throw Day22Error.networkError
        }

        let items = (1...10).map { index in
            Day22Item(id: UUID(), name: "item: \(page)-\(index)")
        }
        return Day22ItemResult(items: items, hasMore: page < 5)
    })
}

extension DependencyValues {
    var day22Client: Day22Client {
        get { self[Day22Client.self] }
        set { self[Day22Client.self] = newValue }
    }
}

struct Day22Item: Identifiable {
    var id: UUID
    var name: String
}

struct Day22ItemResult {
    let items: [Day22Item]
    let hasMore: Bool
}

private enum Day22Error: Error {
    case networkError
}
