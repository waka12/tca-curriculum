//
//  Day6TimerScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/25.
//

import SwiftUI
import ComposableArchitecture

struct Day6TimerScreen: View {
    @Bindable var store: StoreOf<Day6TimerFeature>
    var body: some View {
        VStack {
            Text("\(store.timerValue)")
                .font(.title)
                .padding()
            HStack {
                Button {
                    store.send(.resetButtonTapped)
                } label: {
                    Image(systemName: "arrow.trianglehead.clockwise")
                }
                if case .inProgress = store.timerState {
                    Button {
                        store.send(.pauseButtonTapped)
                    } label: {
                        Image(systemName: "pause")
                    }
                } else {
                    Button {
                        store.send(.playButtonTapped)
                    } label: {
                        Image(systemName: "play")
                    }
                }
            }
        }
    }
}

#Preview {
    Day6TimerScreen(store: Store(initialState: Day6TimerFeature.State()) {
        Day6TimerFeature()
    })
}
