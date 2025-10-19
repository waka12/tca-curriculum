//
//  Day31LargeListScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/10/19.
//

import SwiftUI
import ComposableArchitecture

struct Day31LargeListScreen: View {
    @Bindable var store: StoreOf<Day31LargeListFeature>
    var body: some View {
        List {
            Section {
                ForEach(store.items) { item in
                    Text(item.name)
                        .onAppear {
                            store.send(.moreLoadIfNeeded(item.id))
                        }
                }
            } footer: {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day31LargeListScreen(store: Store(initialState: Day31LargeListFeature.State()){
        Day31LargeListFeature()
    })
}
