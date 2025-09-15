//
//  Day20AppFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day20AppFeature {
    @ObservableState
    struct State {
        var selectedTab = Tab.channels
        var channels = Day20ChannelListFeature.State(items: [
            .init(id: UUID(), name: "#general", messages: [
                .init(id: UUID(), message: "こんにちは"),
                .init(id: UUID(), message: "hello")
            ]),
            .init(id: UUID(), name: "#random", messages: [
                .init(id: UUID(), message: "マッスル"),
                .init(id: UUID(), message: "いえーい"),
            ])
        ])
        var dm = Day20DMFeature.State(partners: [.init(id: UUID(), name: "James"), .init(id: UUID(), name: "Keiko")])
        var settings = Day20SettingsFeature.State()
        @Shared(.inMemory("messages"))
        var isSendingMentionMessage: Bool = false
        @Presents var destination: Destination.State?
    }

    enum Tab {
        case channels, dmTab, settings
    }

    enum Action {
        case channels(Day20ChannelListFeature.Action)
        case dm(Day20DMFeature.Action)
        case settings(Day20SettingsFeature.Action)
        case onChangeIsSendingMentionMessageValue(Bool)

        case destination(PresentationAction<Destination.Action>)
        enum Alert: Equatable {
            case mentionAlert
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.channels, action: \.channels) {
            Day20ChannelListFeature()
        }
        Scope(state: \.dm, action: \.dm) {
            Day20DMFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            Day20SettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case let .onChangeIsSendingMentionMessageValue(newValue):
                if newValue {
                    state.destination = .alert(.mentionAlert())
                }
                return .none
            case .destination(.presented(.alert(.mentionAlert))):
                state.$isSendingMentionMessage.withLock { $0 = false }
                return .none
            case .channels, .dm, .settings:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Day20AppFeature {
    @Reducer
    enum Destination: Sendable {
        case alert(AlertState<Day20AppFeature.Action.Alert>)
    }
}

extension Day20ChannelListFeature.Destination.State {}

extension AlertState where Action == Day20AppFeature.Action.Alert {
    static func mentionAlert() -> Self {
        Self {
            TextState("You got chat")
        } actions: {
            ButtonState(role: .cancel, action: .mentionAlert) {
                TextState("OK")
            }
        }
    }
}
