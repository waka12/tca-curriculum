//
//  Day13D3Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/04.
//

import Testing
import ComposableArchitecture
import Foundation

@testable import TCACurriculum

@MainActor
struct Day13D3Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day3ToDoFeature.State()) {
            Day3ToDoFeature()
        }

        #expect(store.state.todos.isEmpty)
        #expect(store.state.todoText.isEmpty)
    }

    @Test("空文字で追加ボタンをタップしても追加されない")
    func addButtonTapped_textEmpty() async throws {
        let store = TestStore(initialState: Day3ToDoFeature.State()) {
            Day3ToDoFeature()
        }

        await store.send(.addButtonTapped)

        #expect(store.state.todos.isEmpty)
    }

    @Test func addButtonTapped() async throws {
        let store = TestStore(initialState: Day3ToDoFeature.State(todoText: "宿題")) {
            Day3ToDoFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addButtonTapped) {
            $0.todos = [Day3ToDoFeature.ToDoItem(id: UUID(0), text: "宿題", isCompleted: false)]
            $0.todoText = ""
        }
    }

    @Test func deleteButtonTapped() async throws {
        let todoItem = Day3ToDoFeature.ToDoItem(id: UUID(0), text: "宿題", isCompleted: false)
        let store = TestStore(initialState: Day3ToDoFeature.State(todos:[todoItem])) {
            Day3ToDoFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.deleteButtonTapped(todoItem)) {
            $0.todos.remove(id: todoItem.id)
        }
    }

    @Test func updateStatusButtonTapped() async throws {
        let todoItem = Day3ToDoFeature.ToDoItem(id: UUID(0), text: "宿題", isCompleted: false)
        let store = TestStore(initialState: Day3ToDoFeature.State(todos:[todoItem])) {
            Day3ToDoFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.updateStatusButtonTapped(todoItem)) {
            $0.todos[id: todoItem.id]?.isCompleted = true
        }
    }

}
