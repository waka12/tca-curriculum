//
//  Day23CacheSearchFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day23CacheSearchFeature {
    @ObservableState
    struct State {
        var searchText: String = ""
        var item: Day23Item?
        var isLoading: Bool = false
        var isError: Bool = false
        var isOnline: Bool = true
    }

    enum Action: BindableAction {
        case search
        case searchButtonTapped
        case cacheSearch(Day23Item)
        case offlineError
        case cacheClearButtonTapped
        case searchResult(TaskResult<Day23Item>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.day23Client) var day23Client
    @Dependency(\.cacheClient) var cacheClient

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .search:
                return .run { [searchText = state.searchText, isOnline = state.isOnline] send in
                    if let item = await cacheClient.get(searchText) {
                        await send(.cacheSearch(item.data as! Day23Item))
                        return
                    }
                    guard isOnline else {
                        await send(.offlineError)
                        return
                    }
                    await send(.searchResult(
                        TaskResult {
                            try await day23Client.search(searchText)
                        }
                    ))
                }
            case .searchButtonTapped:
                state.isLoading = true
                state.item = nil
                state.isError = false
                return .run { send in
                    await send(.search)
                }
            case let .cacheSearch(item):
                state.item = item
                state.isLoading = false
                return .none
            case .offlineError:
                state.isLoading = false
                state.isError = true
                return .none
            case .cacheClearButtonTapped:
                return .run { send in
                    await cacheClient.clear()
                }
            case let .searchResult(.success(result)):
                state.item = result
                state.isLoading = false
                return .run { [query = state.searchText, result]send in
                    await cacheClient.set(query, CachedData(data: result, expiredAt: Date().addingTimeInterval(300)))
                }
            case .searchResult(.failure(_)):
                state.isError = true
                state.isLoading = false
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct Day23Item: Identifiable {
    var id: UUID
    var name: String
}

struct Day23Client {
    var search: @Sendable (String) async throws -> Day23Item
}

extension Day23Client: DependencyKey {
    static var liveValue = Self(search: { query in
        try await Task.sleep(for: .seconds(1))

        return Day23Item(id: UUID(), name: "item-\(query)")
    })
}

extension DependencyValues {
    var day23Client: Day23Client {
        get { self[Day23Client.self] }
        set { self[Day23Client.self] = newValue }
    }
    var cacheClient: CacheClient {
        get { self[CacheClient.self] }
        set { self[CacheClient.self] = newValue }
    }
}

struct CacheClient {
    var get: @Sendable (String) async -> CachedData?
    var set: @Sendable (String, CachedData) async -> Void
    var clear: @Sendable () async -> Void
}

extension CacheClient: DependencyKey {
    static var liveValue = Self(
        get: { await CacheStorage.shared.get($0)},
        set: { await CacheStorage.shared.set($0, $1)},
        clear: { await CacheStorage.shared.clear()}
    )
}

// actorでスレッドセーフなキャッシュストレージを作成
  actor CacheStorage {
      static let shared: CacheStorage = .init()
      private var cache: [String: CachedData] = [:]

      func get(_ key: String) -> CachedData? {
          guard let cached = cache[key],
                !cached.isExpired else {
              return nil
          }
          return cached
      }

      func set(_ key: String, _ data: CachedData) {
          cache[key] = data
      }

      func clear() {
          cache.removeAll()
      }
  }

struct CachedData {
    let data: Any
    let expiredAt: Date

    var isExpired: Bool {
        Date() > expiredAt

    }
}
