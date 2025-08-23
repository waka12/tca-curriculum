//
//  Day4ToDoFilterFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/22.
//

import ComposableArchitecture
import Foundation

enum ToDoFilter: CaseIterable {
    case all
    case active
    case completed
}

@Reducer
struct Day4ToDoFilterFeature {
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<ToDoItem> = []
        var todoText: String = ""
        var selectedFilter: ToDoFilter = .all
        var filteredTodos: IdentifiedArrayOf<ToDoItem> {
            switch selectedFilter {
            case .all:
                todos
            case .active:
                activeTodos
            case .completed:
                completedTodos
            }
        }
        var activeTodos: IdentifiedArrayOf<ToDoItem> {
            todos.filter { !$0.isCompleted }
        }
        var completedTodos: IdentifiedArrayOf<ToDoItem> {
            todos.filter { $0.isCompleted }
        }
    }

    struct ToDoItem: Identifiable, Equatable {
        var id: UUID = UUID()
        var text: String
        var isCompleted: Bool
    }

    enum Action: BindableAction {
        case addButtonTapped
        case deleteButtonTapped(ToDoItem)
        case updateStatusButtonTapped(ToDoItem)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                guard !state.todoText.isEmpty else {
                    return .none
                }
                state.todos.append(ToDoItem(text: state.todoText, isCompleted: false))
                state.todoText = ""
                return .none
            case .deleteButtonTapped(let todo):
                state.todos.remove(id: todo.id)
                return .none
            case .updateStatusButtonTapped(let todo):
                state.todos[id: todo.id]?.isCompleted.toggle()
                return .none
            case .binding:
                return .none
            }
        }
    }
}
