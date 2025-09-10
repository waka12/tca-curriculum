//
//  Day19ParentFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import ComposableArchitecture

@Reducer
struct Day19ParentFeature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        @Shared var count: Int
    }

    enum Action {
        case showCountButtonTapped
        case showDisplayButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showCountButtonTapped:
                state.destination = .count(Day19CounterFeature.State(count: state.count))
                return .none
            case .showDisplayButtonTapped:
                state.destination = .display(Day19DisplayFeature.State(count: state.$count))
                return .none
            case let .destination(.presented(.count(.delegate(.addCount(count))))):
                state.$count.withLock {
                    $0 = count
                }
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Day19ParentFeature {
    @Reducer
    enum Destination: Sendable {
        case count(Day19CounterFeature)
        case display(Day19DisplayFeature)
    }
}

extension Day19ParentFeature.Destination.State {}
