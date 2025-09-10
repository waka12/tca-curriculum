//
//  Day19DisplayFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import ComposableArchitecture

@Reducer
struct Day19DisplayFeature {
    @ObservableState
    struct State {
        @Shared var count: Int
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
