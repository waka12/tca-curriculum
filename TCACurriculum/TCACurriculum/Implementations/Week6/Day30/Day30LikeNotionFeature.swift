//
//  Day30LikeNotionFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation
import _PhotosUI_SwiftUI

@Reducer
struct Day30LikeNotionFeature {
    @ObservableState
    struct State {
        var isOnlineToggle:Bool = true
        var memoText: String = ""
        var memos: IdentifiedArrayOf<Memo> = []
        var selectedMemo: Memo = .init(id: UUID(), title: "", content: "", history: [])
        var isPresentedEditSheet: Bool = false

        var selectedItems: [PhotosPickerItem] = []
        var isUploadCompleted: Bool = false
        var progress: Double = 0
        var isEditingItemID: UUID?

        @Shared(.fileStorage(.documentsDirectory.appending(component: "memos.json")))
        var offlineMemos: [Memo] = []
    }

    enum Action: BindableAction {
        case onAppear
        case editButtonTapped(Memo)
        case receiveEvent(WebSocketEvent)
        case clearOfflineMemos
        case binding(BindingAction<State>)

        case uploadButtonTapped
        case updateProgress(Double)
        case completeUpload
        case saveSheetButtonTapped

    }

    @Dependency(\.day30LikeNotionClient) var day30LikeNotionClient

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.memos = IdentifiedArray(uniqueElements: Memo.mockMemos())
                return .run { send in
                    for await webSocketEvent in await day30LikeNotionClient.connect() {
                        await send(.receiveEvent(webSocketEvent))
                    }
                }
            case let .editButtonTapped(memo):
                state.selectedMemo = memo
                state.isPresentedEditSheet = true
                return .none
            case let .receiveEvent(webSocketEvent):
                print(webSocketEvent)
                switch webSocketEvent {
                case .connected, .disconnected, .error(_):
                    break
                case let .message(message):
                    // JSON文字列 → Data
                    guard let jsonData = message.data(using: .utf8) else {
                        print("Invalid JSON string")
                        return .none
                    }

                    // Data → Memo
                    do {
                        let decoder = JSONDecoder()
                        var receivedMemo = try decoder.decode(Memo.self, from: jsonData)
                        receivedMemo.history.insert(.init(id: UUID(), date: Date(), userName: "taro", content: receivedMemo.content), at: 0)

                        // 受信したメモで更新
                        state.memos[id: receivedMemo.id] = receivedMemo

                        state.isEditingItemID = nil

                    } catch {
                        print("JSON decode error: \(error)")
                    }
                }
                return .none
            case .clearOfflineMemos:
                state.$offlineMemos.withLock {
                    $0 = []
                }
                return .none
            case .uploadButtonTapped:
                return .run { send in
                    for await progress in day30LikeNotionClient.fileUpload() {
                        await send(.updateProgress(progress))
                    }
                    await send(.completeUpload)
                }
            case let .updateProgress(progress):
                state.progress = progress
                return .none
            case .completeUpload:
                state.isUploadCompleted = true
                return .none
            case .saveSheetButtonTapped:
                state.isPresentedEditSheet = false
                state.selectedMemo.history.insert(.init(id: UUID(), date: Date(), userName: "me", content: state.selectedMemo.content), at: 0)
                state.memos[id: state.selectedMemo.id] = state.selectedMemo
                guard state.isOnlineToggle else {
                    state.$offlineMemos.withLock {
                        $0.append(state.selectedMemo)
                    }
                    return .none
                }
                state.isEditingItemID = state.selectedMemo.id
                return .run { [memo = state.selectedMemo] send in
                    try await Task.sleep(for: .seconds(3))
                    try await day30LikeNotionClient.send(memo)
                }
            case .binding(\.isOnlineToggle):
                if state.isOnlineToggle && !state.offlineMemos.isEmpty {
                    return .run { [offlineMemos = state.offlineMemos] send in
                        // 高優先度で同期実行
                        try await Task(priority: .high) {
                            for memo in offlineMemos {
                                try await day30LikeNotionClient.send(memo)
                            }
                        }.value
                        await send(.clearOfflineMemos)
                    }
                } else {
                    return .none
                }
            case .binding:
                return .none
            }
        }
    }
}

struct Memo: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var content: String
    var imageURL: String?
    var history: [EditHistory]

    static func mockMemos() -> [Self] {
        [
            .init(id: UUID(), title: "item-1", content: "hello", history:[]),
            .init(id: UUID(), title: "item-2", content: "memo", imageURL: "hoge", history:[]),
            .init(id: UUID(), title: "item-3", content: "wow", history:[])
        ]
    }
}

struct EditHistory: Identifiable, Equatable, Codable {
    let id: UUID
    var date: Date
    var userName: String
    var content: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy/MM/dd/HH:mm"
        return formatter.string(from: date)
    }
}

struct Day30LikeNotionClient {
    var fileUpload: @Sendable () -> AsyncStream<Double>

    var connect: @Sendable () async -> AsyncStream<WebSocketEvent>
    var send: @Sendable (Memo) async throws -> Void
    var disconnect: @Sendable () async -> Void
}

extension Day30LikeNotionClient: DependencyKey {
    static let liveValue = Self(
        fileUpload: {
            AsyncStream { continuation in
                Task {
                    // ランダムな速度でアップロード
                    let speed = Double.random(in: 50...200) // ms per chunk

                    for progress in stride(from: 0.0, to: 1.0, by: 0.05) {
                        try? await Task.sleep(for: .milliseconds(UInt64(speed)))
                        continuation.yield(progress)
                    }
                    continuation.yield(1.0) // 100%完了
                    continuation.finish()
                }
            }
        }, connect: {
            await WebSocketClient.shared.connect()
        }, send: { memo in
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(memo)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            try await WebSocketClient.shared.send(jsonString)
        }, disconnect: {
            await WebSocketClient.shared.disconnect()
        }
    )
}

extension DependencyValues {
    var day30LikeNotionClient: Day30LikeNotionClient {
        get { self[Day30LikeNotionClient.self] }
        set { self[Day30LikeNotionClient.self] = newValue }
    }
}
