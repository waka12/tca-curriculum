//
//  Day20DMFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day20DMFeature {
    @ObservableState
    struct State {
        var partners: IdentifiedArrayOf<Partner> = []
        @Shared(.inMemory("messages"))
        var isSendingMentionMessage: Bool = false
    }

    enum Action {
        case sendingButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sendingButtonTapped:
                state.$isSendingMentionMessage.withLock {
                    $0 = true
                }
                return .none
            }
        }
    }
}

struct Partner: Identifiable {
    var id: UUID
    var name: String
}
