//
//  Day5MemoFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/24.
//

import ComposableArchitecture
import Foundation

enum SortState: CaseIterable {
    case createdAt
    case updatedAt
}

@Reducer
struct Day5MemoFeature {
    @ObservableState
    struct State: Equatable {
        var memos: IdentifiedArrayOf<Memo> = []
        var sortedMemos: IdentifiedArrayOf<Memo> {
            switch sortState {
            case .createdAt:
                IdentifiedArray(uniqueElements: memos.sorted(by: { $0.createdAt > $1.createdAt }))
            case .updatedAt:
                IdentifiedArray(uniqueElements: memos.sorted(by: { $0.updatedAt > $1.updatedAt }))
            }
        }
        var isPresentedAdd: Bool = false
        var isPresentedUpdate: Memo?
        var sortState: SortState = .createdAt
        var memoText: String = ""
    }

    struct Memo: Identifiable, Equatable {
        let id: UUID = UUID()
        var text: String
        let createdAt: Date = Date()
        var updatedAt: Date = Date()
        var formattedCreatedAt: String {
              let formatter = DateFormatter()
              formatter.dateStyle = .short
              formatter.timeStyle = .short
              return formatter.string(from: createdAt)
          }
    }

    enum Action: BindableAction {
        case addButtonTapped
        case editButtonTapped(Memo)
        case registerButtonTapped
        case updateButtonTapped(Memo)
        case deleteButtonTapped(Memo)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.memoText = ""
                state.isPresentedAdd = true
                return .none
            case .editButtonTapped(let memo):
                state.memoText = memo.text
                state.isPresentedUpdate = memo
                return .none
            case .registerButtonTapped:
                state.memos.append(Memo(text: state.memoText))
                state.isPresentedAdd = false
                return .none
            case .updateButtonTapped(let updateMemo):
                if var memo = state.memos[id: updateMemo.id] {
                    memo.text = state.memoText
                    memo.updatedAt = Date()
                    state.memos[id: updateMemo.id] = memo
                }
                state.isPresentedUpdate = nil
                return .none
            case .deleteButtonTapped(let memo):
                state.memos.remove(id: memo.id)
                return .none
            case .binding:
                return .none
            }
        }
    }
}
