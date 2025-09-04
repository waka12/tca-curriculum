//
//  Day3ToDoFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/22.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day3ToDoFeature {
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<ToDoItem> = []
        var todoText: String = ""
    }

    struct ToDoItem: Identifiable, Equatable {
        var id: UUID
        var text: String
        var isCompleted: Bool
    }


    enum Action: BindableAction {
        case addButtonTapped
        case deleteButtonTapped(ToDoItem)
        case updateStatusButtonTapped(ToDoItem)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                guard !state.todoText.isEmpty else {
                    return .none
                }
                state.todos.append(ToDoItem(id: uuid(), text: state.todoText, isCompleted: false))
                state.todoText = ""
                return .none
            case .deleteButtonTapped(let todo):
                state.todos.remove(id: todo.id)
                return .none
            case .updateStatusButtonTapped(let todo):
                state.todos[id: todo.id]!.isCompleted.toggle()
                return .none
            case .binding:
                return .none
            }
        }
    }
}
