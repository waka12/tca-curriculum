//
//  Day28WebSocketChatFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day28WebSocketChatFeature {
    @ObservableState
    struct State {
        var messageText: String = ""
        var messageList: IdentifiedArrayOf<ClientMessage> = []
        var connectionStatus: ConnectionStatus = .disconnected
        var retryCount: Int = 0
    }

    enum Action: BindableAction {
        case onAppear
        case sendMessageButtonTapped
        case receiveEvent(WebSocketEvent)
        case retryConnection
        case binding(BindingAction<State>)
    }

    @Dependency(\.day28WebSocketChatClient) var day28WebSocketChatClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.connectionStatus = .connecting
                return .run { send in
                    for await webSocketEvent in await day28WebSocketChatClient.connect() {
                        await send(.receiveEvent(webSocketEvent))
                    }
                }
            case .sendMessageButtonTapped:
                let messageText = state.messageText
                state.messageList.append(ClientMessage(id: UUID(), text: messageText, isFromMe: true, timestamp: Date()))
                state.messageText = ""
                return .run { [messageText] send in
                    try await day28WebSocketChatClient.send(messageText)
                }
            case let .receiveEvent(webSocketEvent):
                print(webSocketEvent)
                switch webSocketEvent {
                case .connected:
                    state.connectionStatus = .connected
                case let .message(text):
                    print(text)
                    state.messageList.append(ClientMessage(id: UUID(), text: text, isFromMe: false, timestamp: Date()))
                case .disconnected:
                    state.connectionStatus = .disconnected
                    return .run { send in
                        await send(.retryConnection)
                    }
                case let .error(text):
                    state.connectionStatus = .error(text)
                    return .run { send in
                        await send(.retryConnection)
                    }
                }
                return .none
            case .retryConnection:
                state.retryCount += 1
                if state.retryCount < 3 {
                    state.connectionStatus = .connecting
                    return .run { send in
                        try await Task.sleep(for: .seconds(2))
                        for await webSocketEvent in await day28WebSocketChatClient.connect() {
                            await send(.receiveEvent(webSocketEvent))
                        }
                    }
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

enum ConnectionStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
}

struct ClientMessage: Identifiable {
    var id: UUID
    var text: String
    var isFromMe: Bool
    var timestamp: Date
}

enum WebSocketEvent {
    case connected
    case message(String)
    case disconnected
    case error(String)
}

struct Day28WebSocketChatClient {
    var connect: @Sendable () async -> AsyncStream<WebSocketEvent>
    var send: @Sendable (String) async throws -> Void
    var disconnect: @Sendable () async -> Void
}

extension Day28WebSocketChatClient: DependencyKey {
    static let liveValue = Self(
        connect: {
            await WebSocketClient.shared.connect()
        }, send: { message in
            try await WebSocketClient.shared.send(message)
        }, disconnect: {
            await WebSocketClient.shared.disconnect()
        }
    )
}

extension DependencyValues {
    var day28WebSocketChatClient: Day28WebSocketChatClient {
        get { self[Day28WebSocketChatClient.self] }
        set { self[Day28WebSocketChatClient.self] = newValue }
    }
}

actor WebSocketClient {
    static let shared: WebSocketClient = .init()

    private var webSocketTask: URLSessionWebSocketTask?
    private var url: URL?

    func connect() -> AsyncStream<WebSocketEvent> {
        AsyncStream { continuation in
            if Bool.random() {
                url = URL(string: "wss://echo.websocket.org")
            } else {
                url = URL(string: "wss://invalid.example.com")
            }
            let task = URLSession.shared.webSocketTask(with: url!)
            self.webSocketTask = task

            task.resume()
            continuation.yield(.connected)

            Task {
                await receiveMessages(continuation: continuation)
            }
        }
    }

    private func receiveMessages(continuation: AsyncStream<WebSocketEvent>.Continuation) async {
        guard let task = webSocketTask else { return }

        do {
            while task.state == .running {
                let message = try await task.receive()
                switch message {
                case let .string(text):
                    continuation.yield(.message(text))
                case .data(_):
                    break
                @unknown default:
                    fatalError("webSocketTask.receive() returned an unexpected case")
                }
            }
        } catch {
            continuation.yield(.error(error.localizedDescription))
            continuation.yield(.disconnected)
        }
    }

    func send(_ message: String) async throws {
        guard let task = webSocketTask else { return }
        try await task.send(.string(message))
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
