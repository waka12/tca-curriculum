//
//  Day3ToDoScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/22.
//

import SwiftUI
import ComposableArchitecture

struct Day3ToDoScreen: View {
    @Bindable var store: StoreOf<Day3ToDoFeature>

    var body: some View {
        VStack {
            HStack {
                TextField("ここに入力", text: $store.todoText)
                Button("add") {
                    store.send(.addButtonTapped)
                }
            }
            .padding()
            List {
                ForEach(store.todos) { todo in
                    HStack {
                        Text(todo.text)
                        Spacer()
                        Button {
                            store.send(.updateStatusButtonTapped(todo))
                        } label: {
                            Text(todo.isCompleted ? "完了" : "未完了")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { indexSet in
                    store.send(.deleteButtonTapped(store.todos[indexSet.first!]))
                }
            }
        }
    }
}

#Preview {
    Day3ToDoScreen(
        store: Store(initialState: Day3ToDoFeature.State()) {
            Day3ToDoFeature()
        }
    )
}
