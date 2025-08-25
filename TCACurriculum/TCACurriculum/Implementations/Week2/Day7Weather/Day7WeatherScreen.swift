//
//  Day7WeatherScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/26.
//

import SwiftUI
import ComposableArchitecture

struct Day7WeatherScreen: View {
    @Bindable var store: StoreOf<Day7WeatherFeature>
    var body: some View {
        if store.isLoading {
            ProgressView()
        } else {
            VStack {
                if let weather = store.weather {
                    Text("状態: \(weather.condition)")
                    Text("気温: \(weather.temperature)")
                } else {
                    Text("取得失敗: \(store.error ?? "不明")")
                }
                if let _ = store.error {
                    Button("リトライ") {
                        store.send(.fetch)
                    }
                } else {
                    Button("取得") {
                        store.send(.fetch)
                    }
                }
            }
        }
    }
}

#Preview {
    Day7WeatherScreen(store: Store(initialState: Day7WeatherFeature.State()) {
        Day7WeatherFeature()
    })
}
