//
//  Day22InfiniteScrollScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/16.
//

import SwiftUI
import ComposableArchitecture

struct Day22InfiniteScrollScreen: View {
    @Bindable var store: StoreOf<Day22InfiniteScrollFeature>
    var body: some View {
        List {
            Section {
                ForEach(store.items) { item in
                    Text(item.name)
                        .onAppear {
                            store.send(.moreLoadInNeeded(item))
                        }
                }
            } header: {
                Text("次ページの読み込み: \(store.hasNextPage)")
            } footer: {
                VStack {
                    if store.isLoading && store.hasNextPage {
                          ProgressView()
                              .frame(maxWidth: .infinity)
                      }
                    if let errorText = store.error {
                        Text("読み込みに失敗\n\(errorText)")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
    }
}

#Preview {
    Day22InfiniteScrollScreen(store: Store(initialState: Day22InfiniteScrollFeature.State()) {
        Day22InfiniteScrollFeature()
    })
}
