//
//  Day18ModalFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/10.
//

import ComposableArchitecture

@Reducer
struct Day18ModalFeature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case addButtonTapped
        case settingsButtonTapped
        case deleteButtonTapped
        case saveButtonTapped
        case destination(PresentationAction<Destination.Action>)
        enum Alert: Equatable {
            case confirmDialog
            case completed
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .add(Day18AddFeature.State())
                return .none
            case .settingsButtonTapped:
                state.destination = .settings(Day18SettingsFeature.State())
                return .none
            case .deleteButtonTapped:
                state.destination = .alert(.deleteConfirmation())
                return .none
            case .saveButtonTapped:
                state.destination = .confirmDialog(.completeDialog())
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Day18ModalFeature {
    @Reducer
    enum Destination: Sendable {
        case add(Day18AddFeature)
        case settings(Day18SettingsFeature)
        case alert(AlertState<Day18ModalFeature.Action.Alert>)
        case confirmDialog(ConfirmationDialogState<Day18ModalFeature.Action.Alert>)
    }
}

extension Day18ModalFeature.Destination.State {}

extension AlertState where Action == Day18ModalFeature.Action.Alert {
    static func deleteConfirmation() -> Self {
        Self {
            TextState("Are you sure?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDialog) {
                TextState("Delete")
            }
        }
    }
}

extension ConfirmationDialogState where Action == Day18ModalFeature.Action.Alert {
    static func completeDialog() -> Self {
        Self {
            TextState("完了")
        }
    }
}
