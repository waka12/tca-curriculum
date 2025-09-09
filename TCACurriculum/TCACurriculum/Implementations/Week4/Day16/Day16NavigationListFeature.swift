//
//  Day16NavigationListFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day16NavigationListFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day16Item> = []
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear
        case itemRowTapped(Day16Item)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.items = [
                    .init(id: uuid(), name: "item1"),
                    .init(id: uuid(), name: "item2"),
                    .init(id: uuid(), name: "item3")
                ]
                return .none
            case .itemRowTapped(let item):
                state.destination = .detail(
                    Day16NavigationDetailFeature.State(item: item)
                )
                return .none
            case let .destination(.presented(.detail(.delegate(.editItem(item))))):
                state.items[id: item.id] = item
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct Day16Item: Identifiable {
    var id: UUID
    var name: String
}

extension Day16NavigationListFeature {
    @Reducer
    enum Destination: Sendable {
        case detail(Day16NavigationDetailFeature)
    }
}

extension Day16NavigationListFeature.Destination.State {}
