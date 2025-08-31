//
//  Day11WeatherFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/26.
//

import ComposableArchitecture

@Reducer
struct Day11WeatherFeature {
    @ObservableState
    struct State {
        var weather: Weather?
        var isLoading = false
        var error: String?
    }

    enum Action: BindableAction {
        case fetch
        case weatherResponse(TaskResult<Weather>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.day11WeatherClient) var day11WeatherClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetch:
                state.isLoading = true
                state.weather = nil
                state.error = nil
                return .run { send in
                    await send(.weatherResponse(
                        TaskResult {
                            try await day11WeatherClient.fetchWeather()
                        }
                    ))
                }
            case .weatherResponse(.success(let weather)):
                state.weather = weather
                state.isLoading = false
                return .none
            case .weatherResponse(.failure(let error)):
                state.error = error.localizedDescription
                state.isLoading = false
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct Day11WeatherClient {
    var fetchWeather: @Sendable () async throws -> Weather
}

extension Day11WeatherClient: DependencyKey {
    static let liveValue = Self(fetchWeather: {
        try await Task.sleep(for: .seconds(2))
        // ランダムでエラーを発生
        if Bool.random() {
            throw WeatherError.networkError
        }
        return Weather(
            temperature: Int.random(in: -10...35),
            condition: ["☀️", "☁️", "🌧️", "⛈️"].randomElement()!
        )
    })

    static let testValue = Self(fetchWeather: {
        Weather(temperature: 20, condition: "☀️")
    })

    static let previewValue = Self(fetchWeather: {
        try await Task.sleep(for: .seconds(0.5))
        return Weather(temperature: 25, condition: "☁️")
    })
}

extension DependencyValues {
    var day11WeatherClient: Day11WeatherClient {
        get { self[Day11WeatherClient.self] }
        set { self[Day11WeatherClient.self] = newValue }
    }
}
