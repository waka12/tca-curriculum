//
//  Day33AnimationFeature.swift
//  TCACurriculum
//
//  Created by Claude on 2025/10/21.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct Day33AnimationFeature {
    @ObservableState
    struct State: Equatable {
        var cards: IdentifiedArrayOf<CardState> = [
            CardState(id: UUID(), title: "Card 1", color: .red),
            CardState(id: UUID(), title: "Card 2", color: .blue),
            CardState(id: UUID(), title: "Card 3", color: .green),
            CardState(id: UUID(), title: "Card 4", color: .orange),
            CardState(id: UUID(), title: "Card 5", color: .purple)
        ]
        
        // ドラッグ状態の管理
        var dragState: DragState = .inactive
        
        // アニメーション状態
        var animationTrigger = UUID()
    }
    
    enum Action {
        case onAppear
        case dragStarted(cardId: UUID)
        case dragChanged(cardId: UUID, translation: CGSize)
        case dragEnded(cardId: UUID, translation: CGSize)
        case cardSwiped(cardId: UUID, direction: SwipeDirection)
        case animationCompleted(cardId: UUID)
    }
    
    enum SwipeDirection {
        case left, right
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .dragStarted(cardId):
                // トップカードのみドラッグ可能
                if let topCard = state.cards.first, topCard.id == cardId {
                    state.dragState = .dragging(cardId: cardId, translation: .zero)
                }
                return .none
                
            case let .dragChanged(cardId, translation):
                // 高頻度更新の最適化 - トップカードのみ更新
                if case .dragging(let dragId, _) = state.dragState, dragId == cardId {
                    state.dragState = .dragging(cardId: cardId, translation: translation)
                    
                    // カードの状態を更新
                    if let index = state.cards.firstIndex(where: { $0.id == cardId }) {
                        state.cards[index].dragOffset = translation
                        state.cards[index].rotation = Double(translation.width / 20)
                        state.cards[index].opacity = 1 - min(abs(translation.width) / 200, 0.5)
                    }
                }
                return .none
                
            case let .dragEnded(cardId, translation):
                state.dragState = .inactive
                
                // スワイプ判定のしきい値
                let threshold: CGFloat = 100
                
                if abs(translation.width) > threshold {
                    // スワイプアニメーションをトリガー
                    let direction: SwipeDirection = translation.width > 0 ? .right : .left
                    return .send(.cardSwiped(cardId: cardId, direction: direction))
                } else {
                    // 元の位置に戻す
                    if let index = state.cards.firstIndex(where: { $0.id == cardId }) {
                        state.cards[index].dragOffset = .zero
                        state.cards[index].rotation = 0
                        state.cards[index].opacity = 1
                        state.animationTrigger = UUID() // アニメーショントリガー
                    }
                    return .none
                }
                
            case let .cardSwiped(cardId, direction):
                // スワイプアニメーションの設定
                if let index = state.cards.firstIndex(where: { $0.id == cardId }) {
                    let xOffset = direction == .right ? 500 : -500
                    state.cards[index].dragOffset = CGSize(width: xOffset, height: -100)
                    state.cards[index].rotation = direction == .right ? 30 : -30
                    state.cards[index].opacity = 0
                    state.animationTrigger = UUID()
                    
                    // アニメーション完了後にカードを削除
                    return .run { [cardId] send in
                        try await Task.sleep(for: .milliseconds(300))
                        await send(.animationCompleted(cardId: cardId))
                    }
                }
                return .none
                
            case let .animationCompleted(cardId):
                // カードを削除
                state.cards.removeAll(where: { $0.id == cardId })
                
                // 背面のカードを前面に移動するアニメーション
                for index in state.cards.indices {
                    state.cards[index].scale = scaleForIndex(index)
                    state.cards[index].yOffset = yOffsetForIndex(index)
                }
                state.animationTrigger = UUID()
                return .none
            }
        }
    }
    
    // インデックスに基づくスケール計算
    private func scaleForIndex(_ index: Int) -> Double {
        return 1.0 - (Double(index) * 0.05)
    }
    
    // インデックスに基づくY座標オフセット計算
    private func yOffsetForIndex(_ index: Int) -> CGFloat {
        return CGFloat(index * 10)
    }
}

// ドラッグ状態
enum DragState: Equatable {
    case inactive
    case dragging(cardId: UUID, translation: CGSize)
}

// カードの状態
struct CardState: Identifiable, Equatable {
    let id: UUID
    let title: String
    let color: CardColor
    
    // アニメーション可能なプロパティ
    var dragOffset: CGSize = .zero
    var rotation: Double = 0
    var opacity: Double = 1
    var scale: Double = 1
    var yOffset: CGFloat = 0
}

// カラー定義
enum CardColor: String, Equatable {
    case red, blue, green, orange, purple
    
    var swiftUIColor: SwiftUI.Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        }
    }
}
