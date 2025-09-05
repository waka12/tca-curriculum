//
//  Day14D8Tests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/05.
//

import Testing
import ComposableArchitecture
import Foundation

@testable import TCACurriculum

@MainActor
struct Day14D8Tests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day8SearchFeature.State()) {
            Day8SearchFeature()
        }

        #expect(store.state.searchText == "")
        #expect(store.state.searchResults == [])
        #expect(store.state.isSearching == false)
    }

    @Test func searchSuccess() async throws {
        let store = TestStore(initialState: Day8SearchFeature.State(searchText: "hello")) {
            Day8SearchFeature()
        } withDependencies: {
            $0.searchClient.search  = { query in
                [SearchResult(id: "1", title: "\(query) Result1")]
            }
        }

        await store.send(.search) {
            $0.isSearching = true
            $0.searchResults = []
        }

        await store.receive(\.searchResponse.success) {
            $0.searchResults = [SearchResult(id: "1", title: "hello Result1")]
            $0.isSearching = false
        }
    }

    @Test func searchFailure() async throws {
        let store = TestStore(initialState: Day8SearchFeature.State(searchText: "hello")) {
            Day8SearchFeature()
        } withDependencies: {
            $0.searchClient.search  = { query in
                throw NSError(domain: "error", code: -1, userInfo: nil)
            }
        }

        await store.send(.search) {
            $0.isSearching = true
            $0.searchResults = []
        }

        await store.receive(\.searchResponse.failure) {
            $0.isSearching = false
        }
    }

    @Test func searchDebounce() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: Day8SearchFeature.State()) {
            Day8SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.searchClient.search = { query in
                [
                    SearchResult(id: "1", title: "\(query) Result1"),
                    SearchResult(id: "2", title: "\(query) Result2")
                ]
            }
        }

        await store.send(.binding(.set(\.searchText, "swift"))) {
            $0.searchText = "swift"
        }

        await clock.advance(by: .milliseconds(300))

        await store.send(.binding(.set(\.searchText, "swiftui"))) {
            $0.searchText = "swiftui"
        }

        await clock.advance(by: .milliseconds(500))

        await store.receive(\.search) {
            $0.isSearching = true
            $0.searchResults = []
        }
        await store.receive(\.searchResponse.success) {
            $0.searchResults = [
                SearchResult(id: "1", title: "swiftui Result1"),
                SearchResult(id: "2", title: "swiftui Result2")
            ]
            $0.isSearching = false
        }

        await store.receive(\.search) {
            $0.isSearching = true
            $0.searchResults = []
        }
        await store.receive(\.searchResponse.success) {
            $0.searchResults = [
                SearchResult(id: "1", title: "swiftui Result1"),
                SearchResult(id: "2", title: "swiftui Result2")
            ]
            $0.isSearching = false
        }

    }

}
