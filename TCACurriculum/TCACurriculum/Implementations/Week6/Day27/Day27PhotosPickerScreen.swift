//
//  Day27PhotosPickerScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/30.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct Day27PhotosPickerScreen: View {
    @Bindable var store: StoreOf<Day27PhotosPickerFeature>

    var body: some View {
        List {
            Section {
                ForEach(store.uploadItems) { item in
                    HStack {
                        VStack(spacing: 4) {
                            Text(item.fileName)
                            if case .completed = item.status {
                                Text("完了")
                                    .foregroundStyle(.green)
                            } else if case .cancelled = item.status {
                                Text("キャンセル")
                                    .foregroundStyle(.yellow)
                            } else {
                                ProgressView(value: item.progressValue)
                            }
                        }
                        if case .uploading = item.status {
                            Button ("×") {
                                store.send(.uploadCancelButtonTapped(item.id))
                            }
                        }
                    }
                }
            } header: {
                PhotosPicker(
                    selection: $store.selectedItems,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    Text("Select Multiple Photos")
                }
            } footer: {
                Button("送信") {
                    store.send(.uploadButtonTapped)
                }
                .frame(maxWidth: .infinity)
            }
        }
//        ForEach(store.uploadItems) { item in
//            HStack {
//                Image(uiImage: item.image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                Spacer()
//            }
//        }
    }
}

#Preview {
    Day27PhotosPickerScreen(store: Store(initialState: Day27PhotosPickerFeature.State()) {
        Day27PhotosPickerFeature()
    })
}
