//
//  Day5MemoScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/24.
//

import SwiftUI
import ComposableArchitecture

struct Day5MemoScreen: View {
    @Bindable var store: StoreOf<Day5MemoFeature>

    var body: some View {
        List {
            Section {
                ForEach(store.sortedMemos) { memo in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(memo.text)
                            Text("文字数: \(memo.text.count)")
                            Text("作成日: \(memo.formattedCreatedAt)")
                        }
                        Spacer()
                        Button {
                            store.send(.editButtonTapped(memo))
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        store.send(.deleteButtonTapped(store.sortedMemos[index]))
                    }
                }
            } header: {
                HStack {
                    Picker("sort", selection: $store.sortState) {
                        ForEach(SortState.allCases, id: \.self) { type in
                            switch type {
                            case .createdAt:
                                Text("作成日")
                            case .updatedAt:
                                Text("更新日")
                            }
                        }
                    }
                    Spacer()
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $store.isPresentedAdd) {
            VStack {
                TextField("ここに入力", text: $store.memoText)
                Button("add") {
                    store.send(.registerButtonTapped)
                }
                .disabled(store.memoText.isEmpty)
            }
            .padding()
        }
        .sheet(item: $store.isPresentedUpdate) { item in
            VStack {
                TextField("ここに入力", text: $store.memoText)
                Button("update") {
                    store.send(.updateButtonTapped(item))
                }
                .disabled(store.memoText.isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    Day5MemoScreen(
        store: Store(initialState: Day5MemoFeature.State()) {
            Day5MemoFeature()
        }
    )
}
