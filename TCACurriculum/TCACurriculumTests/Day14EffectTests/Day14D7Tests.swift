//
//  Day14D7Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/05.
//

import Testing
import ComposableArchitecture

@testable import TCACurriculum

@MainActor
struct Day14D7Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day7WeatherFeature.State()) {
            Day7WeatherFeature()
        }

        #expect(store.state.weather == nil)
        #expect(store.state.isLoading == false)
        #expect(store.state.error == nil)
    }

    @Test func fetchSuccess() async throws {
        let store = TestStore(initialState: Day7WeatherFeature.State()) {
            Day7WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = {
                Weather(temperature: 10, condition: "☀️")
            }
        }

        await store.send(.fetch) {
            $0.isLoading = true
            $0.weather = nil
            $0.error = nil
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = Weather(temperature: 10, condition: "☀️")
            $0.isLoading = false
        }
    }

    @Test func fetchError() async throws {
        let store = TestStore(initialState: Day7WeatherFeature.State()) {
            Day7WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = {
                throw WeatherError.networkError
            }
        }

        await store.send(.fetch) {
            $0.isLoading = true
            $0.weather = nil
            $0.error = nil
        }

        await store.receive(\.weatherResponse.failure) {
            $0.error = WeatherError.networkError.localizedDescription
            $0.isLoading = false
        }
    }

}
