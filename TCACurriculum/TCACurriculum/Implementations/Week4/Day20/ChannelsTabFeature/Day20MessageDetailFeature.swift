//
//  Day20MessageDetailFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture

@Reducer
struct Day20MessageDetailFeature {
    @ObservableState
    struct State {
        var item: Day20MessageItem
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

