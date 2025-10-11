//
//  Day29SyncTaskFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day29SyncTaskFeature {
    @ObservableState
    struct State {
        var tasks: IdentifiedArrayOf<BackgroundTask> = []
        var taskText: String = ""
        var countDownTimer: Int = 30
    }

    enum Action: BindableAction {
        case sync
        case addTaskButtonTapped
        case syncButtonTapped
        case taskCompleted(UUID)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .sync:
                state.tasks = IdentifiedArray(uniqueElements: state.tasks.sorted(by: { $0.priority.rawValue > $1.priority.rawValue }))
                return .run { [tasks = state.tasks] send in
                    for task in tasks {
                        await Task(priority: task.priority.taskPriority) {
                            print("[\(task.priority.label)] \(task.name) を実行中...")
                            try? await Task.sleep(for: .seconds(2)) // 実行をシミュレート
                            print("[\(task.priority.label)] \(task.name) 完了!")
                        }.value

                        await send(.taskCompleted(task.id))
                    }
                }
            case .addTaskButtonTapped:
                state.tasks.append(BackgroundTask(id: UUID(), name: state.taskText, priority: TaskPriority(rawValue: Int.random(in: 0...2)) ?? .low))
                state.taskText = ""
                return .none
            case .syncButtonTapped:
                return .run { send in
                    await send(.sync)
                }
            case let .taskCompleted(taskID):
                state.tasks.remove(id: taskID)
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct BackgroundTask: Identifiable {
    let id: UUID
    let name: String
    let priority: TaskPriority
}

enum TaskPriority: Int {
    case low = 0
    case medium = 1
    case high = 2

    var label: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }

    var taskPriority: _Concurrency.TaskPriority {
        switch self {
        case .low: return .low
        case .medium: return .medium
        case .high : return .high
        }
    }
}

enum TaskStatus {
    case pending
    case running
    case completed
    case failed
}
