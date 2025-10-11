//
//  Day29SyncTaskScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/10/10.
//

import SwiftUI
import ComposableArchitecture

struct Day29SyncTaskScreen: View {
    @Bindable var store: StoreOf<Day29SyncTaskFeature>
    var body: some View {
        List {
            Section {
                ForEach(store.tasks) { task in
                    HStack {
                        Text(task.name)
                        Spacer()
                        Text(task.priority.label)
                    }
                }
            } header: {
                HStack {
                    Text("同期時刻: 10:32")
                    Spacer()
                    Text("次回同期: \(store.countDownTimer)秒")
                    Text("バッジ: \(store.tasks.count)件")
                }
            } footer: {
                HStack {
                    TextField("入力", text: $store.taskText)
                    Button("+") {
                        store.send(.addTaskButtonTapped)
                    }
                    Spacer()
                    Button("手動同期") {
                        store.send(.syncButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    Day29SyncTaskScreen(store: Store(initialState: Day29SyncTaskFeature.State()) {
        Day29SyncTaskFeature()
    })
}
