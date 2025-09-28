//
//  Day25PostListScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/23.
//

import SwiftUI
import ComposableArchitecture

struct Day25PostListScreen: View {
    @Bindable var store: StoreOf<Day25PostListFeature>
    var body: some View {
        Toggle("オフラインにする", isOn: $store.isOffline)
        List {
            Section {
                ForEach(store.posts) { post in
                    VStack(alignment: .leading) {
                        AsyncImage(url: URL(string: post.imageURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                        HStack {
                            Text(post.caption)
                            Spacer()
                            Button {
                                store.send(.likeButtonTapped(post))
                            } label: {
                                HStack {
                                    if post.isLiked {
                                        Image(systemName: "hand.thumbsup.fill")
                                    } else {
                                        Image(systemName: "hand.thumbsup")
                                    }
                                    Text("\(post.likeCount)")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        ForEach(0..<min(post.comments.count, 3), id: \.self) { index in
                            if index == 2 {
                                Button("もっと見る") {

                                }
                                .foregroundStyle(.blue)
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                HStack {
                                    Image(systemName: "arrow.down.forward")
                                    Text(post.comments[index].text)
                                }
                            }
                        }
                        Button("コメント送信") {
                            store.send(.addCommentButtonTapped(post))
                        }
                        .disabled(!store.isCommentSendButtonEnabled)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onAppear {
                        store.send(.moreLoadIfNeeded(post.id))
                    }
                }
            } header: {
                TextField("コメントする", text: $store.commentText)
            } footer: {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
        .onAppear {
            store.send(.load)
        }
    }
}

#Preview {
    Day25PostListScreen(store: Store(initialState: Day25PostListFeature.State()) {
        Day25PostListFeature()
    })
}
