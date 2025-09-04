//
//  Day13D2Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/04.
//

import Testing
import ComposableArchitecture
import Foundation

@testable import TCACurriculum

@MainActor
struct Day13D2Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day2CounterHistoryFeature.State()) {
            Day2CounterHistoryFeature()
        }

        #expect(store.state.count == 0)
        #expect(store.state.doubleCount == 0)
        #expect(store.state.histories.isEmpty)
    }

    @Test func increaseButtonTapped() async throws {
        let store = TestStore(initialState: Day2CounterHistoryFeature.State()) {
            Day2CounterHistoryFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.increaseButtonTapped) {
            $0.count += 1
            $0.histories = [Day2CounterHistoryFeature.HistoryRow(id: UUID(0), history: .increase, currentCount: 1)]
        }

        #expect(store.state.doubleCount == 2)
    }

    @Test func decreaseButtonTapped() async throws {
        let store = TestStore(initialState: Day2CounterHistoryFeature.State()) {
            Day2CounterHistoryFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.decreaseButtonTapped) {
            $0.count -= 1
            $0.histories = [Day2CounterHistoryFeature.HistoryRow(id: UUID(0), history: .decrease, currentCount: -1)]
        }

        #expect(store.state.doubleCount == -2)
    }

    @Test func resetButtonTapped() async throws {
        let store = TestStore(initialState: Day2CounterHistoryFeature.State(count: 5)) {
            Day2CounterHistoryFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.resetButtonTapped) {
            $0.count = 0
            $0.histories = [Day2CounterHistoryFeature.HistoryRow(id: UUID(0), history: .reset, currentCount: 0)]
        }

        #expect(store.state.doubleCount == 0)
    }

    @Test func clearHistoryButtonTapped() async throws {
        let store = TestStore(initialState: Day2CounterHistoryFeature.State()) {
            Day2CounterHistoryFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.increaseButtonTapped) {
            $0.count += 1
            $0.histories = [Day2CounterHistoryFeature.HistoryRow(id: UUID(0), history: .increase, currentCount: 1)]
        }

        await store.send(.resetButtonTapped) {
            $0.count = 0
            $0.histories = [Day2CounterHistoryFeature.HistoryRow(id: UUID(1), history: .reset, currentCount: 0), Day2CounterHistoryFeature.HistoryRow(id: UUID(0), history: .increase, currentCount: 1)]
        }

        await store.send(.clearHistoryButtonTapped) {
            $0.histories = []
        }

        #expect(store.state.doubleCount == 0)
    }

    @Test("履歴は5件まで保持される")
      func historyLimit() async throws {
          let store = TestStore(initialState: Day2CounterHistoryFeature.State()) {
              Day2CounterHistoryFeature()
          } withDependencies: {
              $0.uuid = .incrementing
          }

          // 6回インクリメント
          for i in 0..<6 {
              await store.send(.increaseButtonTapped) {
                  $0.count = i + 1
                  // 履歴は最新5件のみ
                  if i < 5 {
                      $0.histories = Array((0...i).reversed()).map { index in
                          Day2CounterHistoryFeature.HistoryRow(id: UUID(index), history: .increase, currentCount: index + 1)
                      }
                  } else {
                      // 6件目で最古が削除される
                      $0.histories = Array((1...5).reversed()).map { index in
                          Day2CounterHistoryFeature.HistoryRow(id: UUID(index), history: .increase, currentCount: index + 1)
                      }
                  }
              }
          }
      }

}
