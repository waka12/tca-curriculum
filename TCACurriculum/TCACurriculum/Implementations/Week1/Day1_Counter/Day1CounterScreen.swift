//
//  Day1CounterScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/20.
//

import SwiftUI
import ComposableArchitecture

struct Day1CounterScreen: View {
    @Bindable var store: StoreOf<Day1CounterFeature>

    var body: some View {
        VStack(spacing: 16) {
            Text("\(store.count)")
            Text("\(store.doubleCount)")
            HStack(spacing: 24) {
                Button {
                    store.send(.decreaseButtonTapped)
                } label: {
                    Image(systemName: "minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 15)
                }
                Button {
                    store.send(.increaseButtonTapped)
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 15)
                }
            }
            Button {
                store.send(.resetButtonTapped)
            } label: {
                Image(systemName: "return")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 30)
            }
        }
    }
}

#Preview {
    Day1CounterScreen(
        store: Store(initialState: Day1CounterFeature.State()) {
            Day1CounterFeature()
        }
    )
}
