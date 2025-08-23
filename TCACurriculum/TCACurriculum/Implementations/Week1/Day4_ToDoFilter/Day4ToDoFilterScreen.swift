//
//  Day4ToDoFilterScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/22.
//

import SwiftUI
import ComposableArchitecture

struct Day4ToDoFilterScreen: View {
    @Bindable var store: StoreOf<Day4ToDoFilterFeature>

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
                Section {
                    ForEach(store.filteredTodos) { todo in
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
                        if let index = indexSet.first {
                            store.send(.deleteButtonTapped(store.filteredTodos[index]))
                        }
                    }
                } header: {
                    HStack {
                        Picker("フィルター", selection: $store.selectedFilter) {
                            ForEach(ToDoFilter.allCases, id: \.self) { type in
                                switch type {
                                case .all:
                                    Text("全て: \(store.todos.count)")
                                case .active:
                                    Text("進行中: \(store.activeTodos.count)")
                                case .completed:
                                    Text("完了: \(store.completedTodos.count)")
                                }
                            }
                        }
                        Spacer()
                        Text("合計数: \(store.filteredTodos.count)")
                    }
                }
            }
        }
    }
}

#Preview {
    Day4ToDoFilterScreen(
        store: Store(initialState: Day4ToDoFilterFeature.State()) {
            Day4ToDoFilterFeature()
        }
    )
}
