//
//  Day23CacheSearchScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/17.
//

import SwiftUI
import ComposableArchitecture

struct Day23CacheSearchScreen: View {
    @Bindable var store: StoreOf<Day23CacheSearchFeature>

    var body: some View {
        VStack {
            HStack {
                TextField("search", text: $store.searchText)
                Spacer()
                Button("検索") {
                    store.send(.searchButtonTapped)
                }
            }

            Group {
                if let item = store.item {
                    Text(item.name)
                } else if store.isError {
                    Text("取得に失敗")
                } else if store.isLoading {
                    ProgressView()
                } else {
                    Text("検索してください")
                }
            }
            .padding(.top, 48)
            Button("クリア") {
                store.send(.cacheClearButtonTapped)
            }

            Toggle("オンライン", isOn: $store.isOnline)
        }
        .padding()
    }
}

#Preview {
    Day23CacheSearchScreen(store: Store(initialState: Day23CacheSearchFeature.State()) {
        Day23CacheSearchFeature()
    })
}
