//
//  Day28WebSocketChatScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/10/08.
//

import SwiftUI
import ComposableArchitecture

struct Day28WebSocketChatScreen: View {
    @Bindable var store: StoreOf<Day28WebSocketChatFeature>

    var body: some View {
        List {
            Section {
                ForEach(store.messageList) { messageItem in
                    Text(messageItem.text)
                        .foregroundStyle(messageItem.isFromMe ? .green : .black)
                }
            } header: {
                HStack {
                    TextField("入力", text: $store.messageText)
                    Spacer()
                    Button("送信") {
                        store.send(.sendMessageButtonTapped)
                    }
                    .disabled(store.messageText.isEmpty)
                }
            } footer: {
                if case .connecting = store.connectionStatus {
                    ProgressView()
                } else if case .connected = store.connectionStatus {
                    Text("接続中")
                        .foregroundStyle(.green)
                } else {
                    Text("未接続")
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day28WebSocketChatScreen(store: Store(initialState: Day28WebSocketChatFeature.State()) {
        Day28WebSocketChatFeature()
    })
}
