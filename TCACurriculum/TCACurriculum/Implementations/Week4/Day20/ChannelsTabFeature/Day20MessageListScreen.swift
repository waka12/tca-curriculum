//
//  Day20MessageListScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20MessageListScreen: View {
    @Bindable var store: StoreOf<Day20MessageListFeature>
    var body: some View {
        List(store.messages) { message in
            Button(message.message) {
                store.send(.messageItemTapped(message))
            }
        }
        .navigationDestination(item: $store.scope(state: \.destination?.detail, action: \.destination.detail)) { store in
            Day20MessageDetailScreen(store: store)
        }
        .navigationTitle(store.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("+") {
                    store.send(.addButtonTapped)
                }
            }
        }
        .sheet(isPresented: $store.isPresentedAdd) {
            VStack {
                TextField("new", text: $store.newMessage)
                Button("保存") {
                    store.send(.saveButtonTapped)
                }
                .disabled(store.newMessage.isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    Day20MessageListScreen(store: Store(initialState: Day20MessageListFeature.State(name: "hi")) {
        Day20MessageListFeature()
    })
}
