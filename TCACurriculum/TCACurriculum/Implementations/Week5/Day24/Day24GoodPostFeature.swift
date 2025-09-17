//
//  Day24GoodPostFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/18.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day24GoodPostFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day24Item> = [
            .init(id: UUID(), title: "item-1", likeCount: 3, isLiked: false),
            .init(id: UUID(), title: "item-2", likeCount: 0, isLiked: false),
            .init(id: UUID(), title: "item-3", likeCount: 9, isLiked: true)
        ]
        var requestingItemIDs: Set<UUID> = []
    }

    enum Action {
        case goodButtonTapped(Day24Item)
        case goodRequest(Day24Item)
        case goodResponse(TaskResult<Day24Item>, original: Day24Item)
    }

    @Dependency(\.day24Client) var day24Client

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .goodButtonTapped(item):
                guard !state.requestingItemIDs.contains(item.id) else { return .none }

                state.requestingItemIDs.insert(item.id)

                var updateItem = item
                updateItem.isLiked.toggle()
                updateItem.likeCount += updateItem.isLiked ? 1 : -1
                state.items[id: updateItem.id] = updateItem
                return .run { [item] send in
                    await send(.goodRequest(item))
                }
            case let .goodRequest(item):
                return .run { [item] send in
                    await send(.goodResponse(
                        TaskResult {
                            try await day24Client.good(item)
                        }, original: item
                    ))
                }
            case let .goodResponse(.success(_), originalItem):
                state.requestingItemIDs.remove(originalItem.id)
                return .none
            case let .goodResponse(.failure(_), originalItem):
                state.items[id: originalItem.id] = originalItem
                state.requestingItemIDs.remove(originalItem.id)
                return .none
            }
        }
    }
}

struct Day24Item: Identifiable {
    var id: UUID
    var title: String
    var likeCount: Int
    var isLiked: Bool
}

struct Day24Client {
    var good: @Sendable (Day24Item) async throws -> Day24Item
}

enum Day24APIError: Error {
    case networkError
}

extension Day24Client: DependencyKey {
    static var liveValue = Self(good: { item in
        try await Task.sleep(for: .seconds(1))

        if Int.random(in: 1...5) == 1 {
            throw Day24APIError.networkError
        }
        var day24Item = item
        day24Item.isLiked.toggle()
        day24Item.likeCount += day24Item.isLiked ? 1 : -1
        return day24Item
    })
}

extension DependencyValues {
    var day24Client: Day24Client {
        get { self[Day24Client.self] }
        set { self[Day24Client.self] = newValue }
    }
}
