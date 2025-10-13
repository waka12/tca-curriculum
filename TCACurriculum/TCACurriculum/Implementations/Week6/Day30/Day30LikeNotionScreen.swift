//
//  Day30LikeNotionScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/10/12.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct Day30LikeNotionScreen: View {
    @Bindable var store: StoreOf<Day30LikeNotionFeature>
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.memos) { memo in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(memo.title)
                                    .bold()
                                Spacer()
                                Button("編集") {
                                    store.send(.editButtonTapped(memo))
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                            }
                            HStack {
                                Text(memo.content)
                                Spacer()
                                if memo.id == store.isEditingItemID {
                                    Text("編集中")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                }
                            }
                            Text("履歴(max3件まで)")
                                .font(.subheadline)
                            ForEach(0..<min(memo.history.count, 3), id: \.self) { index in
                                HStack {
                                    Text(memo.history[index].userName)
                                    Spacer()
                                    Text(memo.history[index].content)
                                    Spacer()
                                    Text(memo.history[index].formattedDate)
                                }
                            }
                        }
                    }
                } header: {
                    VStack {
                        Toggle("オンライン", isOn: $store.isOnlineToggle)
                        HStack {
                            Text("未同期数: \(store.offlineMemos.count)")
                            Spacer()
                            Button("クリア") {
                                store.send(.clearOfflineMemos)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $store.isPresentedEditSheet) {
            VStack(spacing: 8) {
                TextField(store.selectedMemo.title, text: $store.selectedMemo.title)
                TextField(store.selectedMemo.content, text: $store.selectedMemo.content)
                if store.selectedItems.isEmpty {
                    PhotosPicker(
                        selection: $store.selectedItems,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        Text("Select Photo")
                    }
                } else {
                    HStack {
                        ProgressView(value: store.progress)
                        Spacer()
                        if store.isUploadCompleted {
                            Text("完了")
                                .foregroundStyle(.green)
                        } else {
                            Button("upload") {
                                store.send(.uploadButtonTapped)
                            }
                        }
                    }
                }
                Button("保存") {
                    store.send(.saveSheetButtonTapped)
                }
            }
            .padding()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day30LikeNotionScreen(store: Store(initialState: Day30LikeNotionFeature.State()) {
        Day30LikeNotionFeature()
    })
}
