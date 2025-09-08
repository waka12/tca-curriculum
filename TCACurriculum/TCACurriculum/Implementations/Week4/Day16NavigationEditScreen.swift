//
//  Day16NavigationEditScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//

import SwiftUI
import ComposableArchitecture

struct Day16NavigationEditScreen: View {
    @Bindable var store: StoreOf<Day16NavigationEditFeature>

    var body: some View {
        HStack{
            TextField("itame名", text: $store.text)
            Button("保存") {
                store.send(.saveButton)
            }
        }
        .padding()
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day16NavigationEditScreen(store: Store(initialState: Day16NavigationEditFeature.State(item: .init(id: UUID(), name: "item1"))){
        Day16NavigationEditFeature()
    })
}
