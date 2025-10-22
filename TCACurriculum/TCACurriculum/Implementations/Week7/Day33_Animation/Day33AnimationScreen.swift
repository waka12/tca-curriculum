//
//  Day33AnimationScreen.swift
//  TCACurriculum
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import ComposableArchitecture

struct Day33AnimationScreen: View {
    @Bindable var store: StoreOf<Day33AnimationFeature>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                // カードスタック（逆順で表示）
                ForEach(Array(store.cards.enumerated()), id: \.element.id) { index, card in
                    CardView(
                        card: card,
                        index: store.cards.count - 1 - index,
                        totalCards: store.cards.count,
                        animationTrigger: store.animationTrigger
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                store.send(.dragChanged(
                                    cardId: card.id,
                                    translation: value.translation
                                ))
                            }
                            .onEnded { value in
                                store.send(.dragEnded(
                                    cardId: card.id,
                                    translation: value.translation
                                ))
                            }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if store.dragState == .inactive {
                                    store.send(.dragStarted(cardId: card.id))
                                }
                            }
                    )
                }
                
                // パフォーマンスモニター
                VStack {
                    Spacer()
                    PerformanceMonitor()
                        .padding()
                }
                
                // カードがなくなったらメッセージ表示
                if store.cards.isEmpty {
                    Text("すべてのカードがスワイプされました！")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct CardView: View {
    let card: CardState
    let index: Int
    let totalCards: Int
    let animationTrigger: UUID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(card.color.swiftUIColor)
            .frame(width: 300, height: 400)
            .overlay(
                VStack {
                    Text(card.title)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("左右にスワイプ")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            .shadow(radius: 10)
            // スタック表示のための初期位置
            .scaleEffect(card.scale)
            .offset(y: card.yOffset)
            // ドラッグ中の動き
            .offset(card.dragOffset)
            .rotationEffect(.degrees(card.rotation))
            .opacity(card.opacity)
            // アニメーション
            .animation(
                .spring(response: 0.3, dampingFraction: 0.8),
                value: animationTrigger
            )
            // トップカード以外はインタラクション無効
            .allowsHitTesting(index == 0)
    }
}

// パフォーマンスモニター
struct PerformanceMonitor: View {
    @State private var fps: Double = 60
    @State private var lastUpdate = Date()
    @State private var frameCount = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            HStack {
                Text("FPS: \(Int(fps))")
                    .font(.caption)
                    .padding(8)
                    .background(fps >= 55 ? Color.green : (fps >= 30 ? Color.yellow : Color.red))
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .onAppear {
                calculateFPS()
            }
        }
    }
    
    private func calculateFPS() {
        let now = Date()
        let delta = now.timeIntervalSince(lastUpdate)
        
        frameCount += 1
        
        if delta >= 1.0 {
            fps = Double(frameCount) / delta
            frameCount = 0
            lastUpdate = now
        }
    }
}

#Preview {
    Day33AnimationScreen(
        store: Store(initialState: Day33AnimationFeature.State()) {
            Day33AnimationFeature()
        }
    )
}
