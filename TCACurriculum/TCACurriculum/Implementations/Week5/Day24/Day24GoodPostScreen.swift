//
//  Day24GoodPostScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/18.
//

import SwiftUI
import ComposableArchitecture

struct Day24GoodPostScreen: View {
    @Bindable var store: StoreOf<Day24GoodPostFeature>

    var body: some View {
        List(store.items) { item in
            HStack {
                Text(item.title)
                Spacer()
                Button {
                    store.send(.goodButtonTapped(item))
                } label: {
                    if item.isLiked {
                        Image(systemName: "hand.thumbsup.fill")
                    } else {
                        Image(systemName: "hand.thumbsup")
                    }
                }
            }
        }
    }
}

#Preview {
    Day24GoodPostScreen(store: Store(initialState: Day24GoodPostFeature.State()) {
        Day24GoodPostFeature()
    })
}
