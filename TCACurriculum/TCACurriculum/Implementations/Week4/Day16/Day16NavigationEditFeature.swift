//
//  Day16NavigationEditFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//


import ComposableArchitecture

@Reducer
struct Day16NavigationEditFeature {
    @ObservableState
    struct State {
        var item: Day16Item
        var text: String = ""

        init(item: Day16Item) {
            self.item = item
        }
    }

    enum Action: BindableAction {
        case onAppear
        case saveButton
        case binding(BindingAction<State>)
        case delegate(Delegate)
        @CasePathable
        enum Delegate {
            case editItem(Day16Item)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.text = state.item.name
                return .none
            case .saveButton:
                state.item.name = state.text
                return .run { [item = state.item] send in
                    await send(.delegate(.editItem(item)))
                    await self.dismiss()
                }
            case .delegate:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
