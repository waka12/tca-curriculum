//
//  Day31LargeListFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day31LargeListFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<LargeListItem> = []
        var currentPage: Int = 0
        var isLoading: Bool = false
    }

    enum Action {
        case onAppear
        case moreLoadIfNeeded(UUID)
        case itemsLoaded(TaskResult<[LargeListItem]>)
        case clearItems
    }

    @Dependency(\.largeListClient) var largeListClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.currentPage += 1
                state.isLoading = true
                return .run { [currentPage = state.currentPage] send in
                    await send(.itemsLoaded(
                        TaskResult {
                            try await largeListClient.fetch(currentPage)
                        }
                    ))
                }
            case let .moreLoadIfNeeded(targetID):
                if state.items.last?.id == targetID {
                    guard !state.isLoading else { return .none }
                    state.currentPage += 1
                    state.isLoading = true
                    return .run { [currentPage = state.currentPage]send in
                        // 追加してから削除をすると、Listの仕様によりスクロール位置が最下部になり無限スクロールが発生するため、追加前に削除する
                        await send(.clearItems)
                        await send(.itemsLoaded(
                            TaskResult {
                                try await largeListClient.fetch(currentPage)
                            }
                        ))
                    }
                }
                return .none
            case let .itemsLoaded(.success(items)):
                state.items.append(contentsOf: items)
                state.isLoading = false
                return .none
            case .itemsLoaded(.failure(_)):
                state.isLoading = false
                return .none
            case .clearItems:
                if state.items.count > 200 {
                    let idsToRemove = state.items.prefix(50).map(\.id)
                    for id in idsToRemove {
                        state.items.remove(id: id)
                    }
                }
                return .none
            }
        }
    }
}

struct LargeListItem: Identifiable {
    var id: UUID
    var name: String
}

struct LargeListClient {
    var fetch: @Sendable (Int) async throws -> [LargeListItem]
}

extension LargeListClient: DependencyKey {
    static var liveValue = Self(fetch: { page in
        try await Task.sleep(for: .seconds(1))

        return (1...50).map { index in
            LargeListItem(id: UUID(), name: "item-\(page)-\(index)")
        }
    })
}

extension DependencyValues {
    var largeListClient: LargeListClient{
        get { self[LargeListClient.self] }
        set { self[LargeListClient.self] = newValue }
    }
}
