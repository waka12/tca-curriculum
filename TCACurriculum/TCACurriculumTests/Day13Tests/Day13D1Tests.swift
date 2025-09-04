//
//  Day13D1Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/04.
//

import Testing
import ComposableArchitecture

@testable import TCACurriculum

@MainActor
struct Day13D1Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day1CounterFeature.State()) {
            Day1CounterFeature()
        }
        
        #expect(store.state.count == 0)
        #expect(store.state.doubleCount == 0)
    }

    @Test func increaseButtonTapped() async throws {
        let store = TestStore(initialState: Day1CounterFeature.State()) {
            Day1CounterFeature()
        }

        await store.send(.increaseButtonTapped) {
            $0.count += 1
        }

        #expect(store.state.doubleCount == 2)
    }

    @Test func decreaseButtonTapped() async throws {
        let store = TestStore(initialState: Day1CounterFeature.State(count: 5)) {
            Day1CounterFeature()
        }

        await store.send(.decreaseButtonTapped) {
            $0.count = 4
        }

        #expect(store.state.doubleCount == 8)
    }

    @Test func resetButtonTapped() async throws {
        let store = TestStore(initialState: Day1CounterFeature.State(count: 10)) {
            Day1CounterFeature()
        }

        await store.send(.resetButtonTapped) {
            $0.count = 0
        }

        #expect(store.state.doubleCount == 0)
    }

    @Test("countがマイナスにならない")
    func notNegativeValue() async throws {
        let store = TestStore(initialState: Day1CounterFeature.State()) {
            Day1CounterFeature()
        }

        await store.send(.decreaseButtonTapped)

        #expect(store.state.count == 0)
    }

}
