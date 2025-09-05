//
//  Day7WeatherFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/26.
//

import ComposableArchitecture

@Reducer
struct Day7WeatherFeature {
    @ObservableState
    struct State: Equatable {
        var weather: Weather?
        var isLoading = false
        var error: String?
    }

    enum Action: BindableAction {
        case fetch
        case weatherResponse(TaskResult<Weather>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.weatherClient) var weatherClient

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
                            try await weatherClient.fetchWeather()
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

struct WeatherClient {
    var fetchWeather: @Sendable () async throws -> Weather
}

struct Weather: Equatable {
    var temperature: Int
    var condition: String
}

enum WeatherError: Error {
    case networkError
}

extension WeatherClient: DependencyKey {
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
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}
