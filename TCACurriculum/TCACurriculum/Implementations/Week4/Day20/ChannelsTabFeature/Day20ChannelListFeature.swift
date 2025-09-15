//
//  Day20ChannelListFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day20ChannelListFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day20ChannelItem>
        @Presents var destination: Destination.State?
        @Shared(.inMemory("messages"))
        var isSendingMentionMessage: Bool = false
    }

    enum Action {
        case sendingButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case itemRowTapped(Day20ChannelItem)
    }

    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sendingButtonTapped:
                state.$isSendingMentionMessage.withLock {
                    $0 = true
                }
                return .none
            case let .itemRowTapped(item):
                state.destination = .message(Day20MessageListFeature.State(name: item.name, messages: IdentifiedArray(uniqueElements: item.messages)))
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct Day20ChannelItem: Identifiable {
    var id: UUID
    var name: String
    var messages: [Day20MessageItem]
}

struct Day20MessageItem: Identifiable {
    var id: UUID
    var message: String
}

extension Day20ChannelListFeature {
    @Reducer
    enum Destination: Sendable {
        case message(Day20MessageListFeature)
    }
}

extension Day20ChannelListFeature.Destination.State {}
