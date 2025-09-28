//
//  Day25PostListFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day25PostListFeature {
    @ObservableState
    struct State {
        var posts: IdentifiedArrayOf<Day25PostItem> = []
        var currentPage: Int = 1
        var isLoading: Bool = false
        var commentText: String = ""
        var isCommentSendButtonEnabled: Bool {
            !isLoading && !commentText.isEmpty
        }
        var isOffline: Bool = false
    }

    enum Action: BindableAction {
        case load
        case postsResponse(TaskResult<[Day25PostItem]>)
        case goodResponse(TaskResult<()>, original: Day25PostItem)
        case commentResponse(TaskResult<()>, original: Day25PostItem)
        case moreLoadIfNeeded(UUID)

        case likeButtonTapped(Day25PostItem)
        case addCommentButtonTapped(Day25PostItem)
        case refresh

        case binding(BindingAction<State>)
    }

    @Dependency(\.day25Client) var day25Client
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .load:
                guard !state.isOffline else { return .none }
                state.isLoading = true
                return .run { [currentPage = state.currentPage] send in
                    await send(.postsResponse(
                        TaskResult {
                            try await day25Client.load(currentPage)
                        }
                    ))
                }
            case let .postsResponse(.success(posts)):
                state.posts.append(contentsOf: posts) 
                state.currentPage += 1
                state.isLoading = false
                return .none
            case .postsResponse(.failure(_)):
                state.isLoading = false
                return .none
            case let .moreLoadIfNeeded(postID):
                guard state.posts.last?.id == postID, !state.isLoading else { return .none }
                return .run { send in
                    await send(.load)
                }
            case let .likeButtonTapped(postItem):
                guard !state.isOffline else { return .none }
                state.posts[id: postItem.id]?.isLiked.toggle()
                if let post = state.posts[id: postItem.id], post.isLiked  {
                    state.posts[id: postItem.id]?.likeCount += 1
                } else {
                    state.posts[id: postItem.id]?.likeCount -= 1
                }
                return .run { [postItem] send in
                    await send(.goodResponse(
                            TaskResult {
                                try await day25Client.good()
                            }, original: postItem
                        ))
                }
            case let .addCommentButtonTapped(postItem):
                guard !state.isOffline else { return .none }
                let newComment = Day25CommentItem(id: UUID(), username: "tar", text: state.commentText)

                var updatedPost = postItem
                updatedPost.comments.insert(newComment, at: 0)  // 最新コメントを上に
                state.posts[id: postItem.id] = updatedPost
                state.commentText = ""
                return .run { [postItem] send in
                    await send(.commentResponse(
                        TaskResult {
                            try await day25Client.comment()
                        }, original: postItem
                    ))
                }
            case .goodResponse(.success, _):
                return .none
            case let .goodResponse(.failure(_), originalItem):
                state.posts[id: originalItem.id] = originalItem
                return .none
            case .commentResponse(.success, _):
                return .none
            case let .commentResponse(.failure(_), originalItem):
                state.posts[id: originalItem.id] = originalItem
                return .none
            case .refresh:
                guard !state.isOffline else { return .none }
                state.isLoading = false
                state.posts = []
                state.currentPage = 1
                return .run { send in
                    await send(.load)
                }
            case .binding:
                return .none
            }
        }
    }
}

struct Day25PostItem: Identifiable {
    let id: UUID
    let username: String
    let imageURL: String
    let caption: String
    var likeCount: Int
    var isLiked: Bool
    var comments: [Day25CommentItem]
}

struct Day25CommentItem: Identifiable {
    let id: UUID
    let username: String
    let text: String
}

struct Day25Client {
    var load: @Sendable (Int) async throws -> [Day25PostItem]
    var good: @Sendable () async throws -> Void
    var comment: @Sendable () async throws -> Void
}

enum Day25Error: Error {
    case networkError
    case goodError
    case commentError
}

extension Day25Client: DependencyKey {
    static var liveValue = Self(
        load: { page in
            try await Task.sleep(for: .seconds(1))
            if Int.random(in: 1...10) == 1 {
                throw Day25Error.networkError
            }

            var items: [Day25PostItem] = []
            for i in 1...10 {
                let comments = (1...Int.random(in: 1...5)).map { index in
                    Day25CommentItem(
                        id: UUID(),
                        username: "comment-name-\(page)-\(index)",
                        text: "comment-\(index)"
                    )
                }
                items.append(
                    Day25PostItem(
                    id: UUID(),
                    username: "name-\(i)",
                    imageURL: "https://picsum.photos/400/400?random=\(page)_\(i)",
                    caption: "page-\(page), item-\(i)",
                    likeCount: Int.random(in: 0...10),
                    isLiked: false,
                    comments: comments
                ))
            }
            return items
        },
        good: {
            try await Task.sleep(for: .seconds(1))
            if Int.random(in: 1...5) == 1 {
                throw Day25Error.goodError
            }
            return
        },
        comment: {
            try await Task.sleep(for: .seconds(1))
            if Int.random(in: 1...5) == 1 {
                throw Day25Error.commentError
            }
            return
        }
    )
}

extension DependencyValues {
    var day25Client: Day25Client {
        get { self[Day25Client.self] }
        set { self[Day25Client.self] = newValue }
    }
}
