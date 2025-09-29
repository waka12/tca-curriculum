//
//  Day26SharedHomeFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture

@Reducer
struct Day26SharedHomeFeature {
    @ObservableState
    struct State {
        @Shared(.appStorage("userName")) var userName:String = ""
        @Shared(.inMemory("unreadCount")) var unreadCount:Int = 0
        @Shared(.fileStorage(.documentsDirectory.appending(component: "theme.json")))
        var theme = Theme.light
    }

    enum Action {

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            }
        }
    }
}

extension Theme: Codable {}
