//
//  Day14D6Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/05.
//

import Testing
import ComposableArchitecture

@testable import TCACurriculum

@MainActor
struct Day14D6Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day6TimerFeature.State()) {
            Day6TimerFeature()
        }

        #expect(store.state.timerState == .pause)
        #expect(store.state.timerValue == 0)
    }

    @Test func resetButtonTapped() async throws {
        let store = TestStore(initialState: Day6TimerFeature.State(timerState: .inProgress, timerValue: 10)) {
            Day6TimerFeature()
        }

        await store.send(.resetButtonTapped) {
            $0.timerState = .pause
            $0.timerValue = 0
        }
    }

    @Test func pauseButtonTapped() async throws {
        let store = TestStore(initialState: Day6TimerFeature.State(timerState: .inProgress, timerValue: 10)) {
            Day6TimerFeature()
        }

        await store.send(.pauseButtonTapped) {
            $0.timerState = .pause
        }

        #expect(store.state.timerValue == 10)
    }

    @Test func tick() async throws {
        let store = TestStore(initialState: Day6TimerFeature.State()) {
            Day6TimerFeature()
        }

        await store.send(.tick) {
            $0.timerValue += 1
        }
    }

    @Test func timerTick() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: Day6TimerFeature.State()) {
            Day6TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.playButtonTapped) {
            $0.timerState = .inProgress
        }

        await clock.advance(by: .seconds(1))

        await store.receive(\.tick) {
            $0.timerValue = 1
        }

        await store.send(.pauseButtonTapped) {
            $0.timerState = .pause
        }
    }

    @Test func timerCancellation() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: Day6TimerFeature.State()) {
            Day6TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.playButtonTapped) {
            $0.timerState = .inProgress
        }

        await store.send(.resetButtonTapped) {
            $0.timerState = .pause
            $0.timerValue = 0
        }

        await clock.advance(by: .seconds(1))
    }

}
