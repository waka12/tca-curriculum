//
//  Day9ParallelScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/28.
//

import SwiftUI
import ComposableArchitecture

struct Day9ParallelScreen: View {
    @Bindable var store: StoreOf<Day9ParallelFeature>
    var body: some View {
        List {
            Section {
                Button("取得") {
                    store.send(.fetchAllData)
                }
            }

            if let error = store.error {
                Text(error)
            } else {
                Section {
                    if store.userLoading {
                        ProgressView()
                    } else if let user = store.user {
                        Text("userName: \(user.name)")
                    }
                } header: {
                    Text("User")
                }

                Section {
                    if store.postLoading {
                        ProgressView()
                    } else if !store.posts.isEmpty {
                        ForEach(store.posts) { post in
                            Text(post.address)
                        }
                    }
                } header: {
                    Text("Posts")
                }

                Section {
                    if store.settingsLoading {
                        ProgressView()
                    } else if let settingsData = store.settingsData {
                        Text("settings: \(settingsData.theme)")
                    }
                } header: {
                    Text("Settings")
                }
            }
        }
    }
}

#Preview {
    Day9ParallelScreen(store: Store(initialState: Day9ParallelFeature.State()) {
        Day9ParallelFeature()
    })
}
