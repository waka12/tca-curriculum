//
//  Day27PhotosPickerFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import _PhotosUI_SwiftUI

@Reducer
struct Day27PhotosPickerFeature {
    @ObservableState
    struct State {
        var selectedItems: [PhotosPickerItem] = []
        var uploadItems: IdentifiedArrayOf<UploadItem> = []
        var progress: Double = 0
    }

    enum Action: BindableAction {
        case upload(UploadItem)
        case uploadButtonTapped
        case updateProgress(UUID, Double)
        case uploadCompleted(UUID)
        case uploadCancelButtonTapped(UUID)
        case binding(BindingAction<State>)
    }

    private enum CancelID: Hashable {
        case upload(UUID)
    }

    @Dependency(\.day27UploadClient) var day27UploadClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .upload(uploadItem):
                state.uploadItems[id: uploadItem.id]?.status = .uploading

                return .run { [uploadItem] send in
                    for await progress in day27UploadClient.upload(uploadItem) {
                        await send(.updateProgress(uploadItem.id, progress))
                    }
                    await send(.uploadCompleted(uploadItem.id))
                }
                .cancellable(id: CancelID.upload(uploadItem.id))
            case .uploadButtonTapped:
                for _ in state.selectedItems {
                    state.uploadItems.append(UploadItem(id: UUID(), fileName: "item-\(state.uploadItems.count).jpg"))
                }
                let waitingItems = state.uploadItems.filter { $0.status == .waiting }

                return .run { send in
                    for item in waitingItems {
                        await send(.upload(item))
                    }
                }
            case let .updateProgress(fileID, progressValue):
                state.uploadItems[id: fileID]?.progressValue = progressValue
                return .none
            case let .uploadCompleted(fileID):
                state.uploadItems[id: fileID]?.status = .completed
                print(state.uploadItems[id: fileID]?.progressValue ?? 0)
                return .none
            case let .uploadCancelButtonTapped(fileID):
                state.uploadItems[id: fileID]?.status = .cancelled
                return .cancel(id: CancelID.upload(fileID))
            case .binding:
                return .none
            }
        }
    }
}

struct Day27UploadClient {
    var upload: @Sendable (UploadItem) -> AsyncStream<Double>
}

extension Day27UploadClient: DependencyKey {
    static let liveValue = Self(
        upload: { item in
            AsyncStream { continuation in
                Task {
                    // ランダムな速度でアップロード
                    let speed = Double.random(in: 50...200) // ms per chunk

                    for progress in stride(from: 0.0, to: 1.0, by: 0.05) {
                        try? await Task.sleep(for: .milliseconds(UInt64(speed)))

                        // 20%の確率で失敗（デモ用）
                        if progress > 0.8 && Bool.random() && false {
                            continuation.finish()
                            return
                        }

                        continuation.yield(progress)
                    }
                    continuation.yield(1.0) // 100%完了
                    continuation.finish()
                }
            }
        }
    )
}

extension DependencyValues {
    var day27UploadClient: Day27UploadClient {
        get { self[Day27UploadClient.self] }
        set { self[Day27UploadClient.self] = newValue }
    }
}

struct UploadItem: Identifiable {
    let id: UUID
    let fileName: String
    var progressValue: Double = 0.0
    var status: UploadStatus = .waiting
}

enum UploadStatus {
    case waiting
    case uploading
    case completed
    case failed
    case cancelled
}
