//
//  Day9ParallelFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/28.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day9ParallelFeature {
    @ObservableState
    struct State {
        var userLoading = false
        var user: User?

        var postLoading = false
        var posts: [Post] = []

        var settingsLoading = false
        var settingsData: SettingsData?

        var error: String?

        var isAllDataLoaded: Bool {
            user != nil &&
            !posts.isEmpty &&
            settingsData != nil
        }
    }
    enum Action {
        case fetchAllData
        case fetchUser
        case userResponse(TaskResult<User>)
        case fetchPosts
        case postsResponse(TaskResult<[Post]>)
        case fetchSettingsData
        case settingsDataResponse(TaskResult<SettingsData>)
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.postClient) var postClient
    @Dependency(\.settingsDataClient) var settingsDataClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAllData:
                state.error = nil
                return .merge(
                    .run { send in await send(.fetchUser) },
                    .run { send in await send(.fetchPosts) },
                    .run { send in await send(.fetchSettingsData) }
                )
            case .fetchUser:
                if state.user != nil {
                    return .none
                }
                state.userLoading = true
                return .run { send in
                    await send(.userResponse(
                        TaskResult {
                            try await userClient.fetchUser()
                        }
                    ))
                }
            case .userResponse(.success(let user)):
                state.user = user
                state.userLoading = false
                return .none
            case .userResponse(.failure(_)):
                state.error = (state.error ?? "") + "user error\n"
                state.userLoading = false
                return .none
            case .fetchPosts:
                if !state.posts.isEmpty {
                    return .none
                }
                state.postLoading = true
                return .run { send in
                    await send(.postsResponse(
                        TaskResult {
                            try await postClient.fetchPosts()
                        }
                    ))
                }
            case .postsResponse(.success(let posts)):
                state.posts = posts
                state.postLoading = false
                return .none
            case .postsResponse(.failure(_)):
                state.error = (state.error ?? "") + "posts error\n"
                state.postLoading = false
                return .none
            case .fetchSettingsData:
                if state.settingsData != nil {
                    return .none
                }
                state.settingsLoading = true
                return .run { send in
                    await send(.settingsDataResponse(
                        TaskResult {
                            try await settingsDataClient.fetchSettingsData()
                        }
                    ))
                }
            case .settingsDataResponse(.success(let settingsData)):
                state.settingsData = settingsData
                state.settingsLoading = false
                return .none
            case .settingsDataResponse(.failure(_)):
                state.error = (state.error ?? "") + "settingsData error\n"
                state.settingsLoading = false
                return .none
            }
        }
    }
}

private enum APIError: Error {
    case networkError
}

struct UserClient {
    var fetchUser: @Sendable () async throws -> User
}

extension UserClient: DependencyKey {
    static let liveValue = Self(fetchUser: {
        try await Task.sleep(for: .seconds(1))

        if Bool.random() {
            throw APIError.networkError
        }
        return User(name: "taro")
    })
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
    var postClient: PostClient {
        get { self[PostClient.self] }
        set { self[PostClient.self] = newValue }
    }
    var settingsDataClient: SettingsDataClient {
        get { self[SettingsDataClient.self] }
        set { self[SettingsDataClient.self] = newValue }
    }
}

struct User {
    var name: String
}

struct Post: Identifiable {
    var id: UUID = UUID()
    var address: String
}

struct SettingsData {
    var theme: String
}

struct PostClient {
    var fetchPosts: @Sendable () async throws -> [Post]
}

extension PostClient: DependencyKey {
    static let liveValue = Self(fetchPosts: {
        try await Task.sleep(for: .seconds(2))

        if Bool.random() {
            throw APIError.networkError
        }
        return [Post(address: "東京"), Post(address: "大阪")]
    })
}

struct SettingsDataClient {
    var fetchSettingsData: @Sendable () async throws -> SettingsData
}

extension SettingsDataClient: DependencyKey {
    static let liveValue = Self(fetchSettingsData: {
        try await Task.sleep(for: .seconds(1.5))

        if Bool.random() {
            throw APIError.networkError
        }
        return SettingsData(theme: "ダーク")
    })
}
