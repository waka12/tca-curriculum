//
//  Day16NavigationDetailFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//

import ComposableArchitecture

@Reducer
struct Day16NavigationDetailFeature {
    @ObservableState
    struct State {
        var item: Day16Item
        @Presents var destination: Destination.State?

        init(item: Day16Item) {
            self.item = item
        }
    }

    enum Action {
        case editButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        @CasePathable
        enum Delegate {
            case editItem(Day16Item)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .editButtonTapped:
                state.destination = .edit(
                    Day16NavigationEditFeature.State(item: state.item)
                )
                return .none
            case let .destination(.presented(.edit(.delegate(.editItem(item))))):
                state.item = item
                return .run { [item = state.item] send in
                    await send(.delegate(.editItem(item)))
                }
            case .destination:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Day16NavigationDetailFeature {
    @Reducer
    enum Destination: Sendable {
        case edit(Day16NavigationEditFeature)
    }
}

extension Day16NavigationDetailFeature.Destination.State {}
