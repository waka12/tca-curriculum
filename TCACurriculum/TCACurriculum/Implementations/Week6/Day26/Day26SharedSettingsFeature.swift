//
//  Day26SharedSettingsFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture

@Reducer
struct Day26SharedSettingsFeature {
    @ObservableState
    struct State {
        @Shared(.appStorage("userName")) var userName:String = ""
        @Shared(.inMemory("unreadCount")) var unreadCount:Int = 0
        @Shared(.fileStorage(.documentsDirectory.appending(component: "theme.json")))
        var theme: Theme = .light

        var editingUserName: String = ""
        var editingUnreadCount: Int = 0
        var isLightMode: Bool = true
    }

    enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.editingUserName = state.userName
                state.editingUnreadCount = state.unreadCount
                state.isLightMode = state.theme == .light ? true : false
                return .none
            case .binding(\.editingUserName):
                state.$userName.withLock {
                    $0 = state.editingUserName
                }
                return .none
            case .binding(\.editingUnreadCount):
                state.$unreadCount.withLock {
                    $0 = state.editingUnreadCount
                }
                return .none
            case .binding(\.isLightMode):
                state.$theme.withLock {
                    $0 = state.isLightMode ? .light : .dark
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

