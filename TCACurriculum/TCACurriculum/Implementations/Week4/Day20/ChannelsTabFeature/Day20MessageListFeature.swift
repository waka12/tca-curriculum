//
//  Day20MessageListFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day20MessageListFeature {
    @ObservableState
    struct State {
        var name: String
        var messages: IdentifiedArrayOf<Day20MessageItem> = []
        @Presents var destination: Destination.State?
        var isPresentedAdd: Bool = false
        var newMessage: String = ""
    }

    enum Action: BindableAction {
        case addButtonTapped
        case messageItemTapped(Day20MessageItem)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case saveButtonTapped
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.isPresentedAdd = true
                state.newMessage = ""
                return .none
            case let .messageItemTapped(item):
                state.destination = .detail(Day20MessageDetailFeature.State(item: item))
                return .none
            case .saveButtonTapped:
                state.messages.append(.init(id: uuid(), message: state.newMessage))
                state.isPresentedAdd = false
                state.newMessage = ""
                return .none
            case .destination, .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Day20MessageListFeature {
    @Reducer
    enum Destination: Sendable {
        case detail(Day20MessageDetailFeature)
    }
}

extension Day20MessageListFeature.Destination.State {}
