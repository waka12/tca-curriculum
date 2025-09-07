//
//  Day15LoginTests.swift
//  TCACurriculumTests
//
//  Created by わくわく on 2025/09/06.
//

import Testing
import ComposableArchitecture

@testable import TCACurriculum

@MainActor
struct Day15LoginTests {

    @Test func initialState() async throws {
        let store = TestStore(initialState: Day15LoginFeature.State()) {
            Day15LoginFeature()
        }
        #expect(store.state.mailTextField == "")
        #expect(store.state.isEmailError == false)
        #expect(store.state.passTextField == "")
        #expect(store.state.isPassError == false)
        #expect(store.state.errorText == nil)
        #expect(store.state.isLoading == false)
        #expect(store.state.authToken == nil)
        #expect(store.state.timerValue == 0)
    }

    @Test func loginButtonTappedSuccess() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: Day15LoginFeature.State()) {
            Day15LoginFeature()
        } withDependencies: {
            $0.loginClient.login = { mail, password  in
                AuthToken(accessToken: "test-token", expiresAt: 10)
            }
            $0.continuousClock = clock
            var savedToken: String?
            $0.day15UserDefaultsClient = Day15UserDefaultsClient(
                setAuthToken: { token in
                    savedToken = token
                },
                getAuthToken: {
                    savedToken ?? ""
                }
            )
        }
        await store.send(.binding(.set(\.mailTextField, "test@test.com"))) {
            $0.mailTextField = "test@test.com"
        }
        await store.send(.binding(.set(\.passTextField, "123456789"))) {
            $0.passTextField = "123456789"
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
            $0.errorText = nil
        }

        await store.receive(\.loginResults.success) {
            $0.authToken = AuthToken(accessToken: "test-token", expiresAt: 10)
            $0.isLoading = false
            $0.mailTextField = ""
            $0.passTextField = ""
        }

        await clock.advance(by: .seconds(10))

        await store.receive(\.logout) {
            $0.authToken = nil
        }
    }

    @Test func loginButtonTappedFailure() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: Day15LoginFeature.State()) {
            Day15LoginFeature()
        } withDependencies: {
            $0.loginClient.login = { password, mail in
                throw LoginError.networkError
            }
            $0.continuousClock = clock
            var savedToken: String?
            $0.day15UserDefaultsClient = Day15UserDefaultsClient(
                setAuthToken: { token in
                    savedToken = token
                },
                getAuthToken: {
                    savedToken ?? ""
                }
            )
        }
        await store.send(.binding(.set(\.mailTextField, "test@test.com"))) {
            $0.mailTextField = "test@test.com"
        }
        await store.send(.binding(.set(\.passTextField, "123456789"))) {
            $0.passTextField = "123456789"
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
            $0.errorText = nil
        }

        await store.receive(\.loginResults.failure) {
            $0.isLoading = false
            $0.errorText = "ログインに失敗しました"
        }
    }

    @Test func onAppearAutoLogin() async throws {
        var savedToken: String?
        let userDefaultsClient = Day15UserDefaultsClient(
            setAuthToken: { token in
                savedToken = token
            },
            getAuthToken: {
                savedToken ?? ""
            }
        )
        let clock = TestClock()
        let store = TestStore(initialState: Day15LoginFeature.State()) {
            Day15LoginFeature()
        } withDependencies: {
            $0.loginClient.login = { password, mail in
                throw LoginError.networkError
            }
            $0.continuousClock = clock
            $0.day15UserDefaultsClient = userDefaultsClient
        }
        await userDefaultsClient.setAuthToken("test-token")

        await store.send(.onAppear)

        await store.receive(\.autoLogin("test-token")) {
            $0.authToken = AuthToken(accessToken: "savedToken", expiresAt: 20)
        }

        await clock.advance(by: .seconds(10))

        await store.receive(\.logout) {
            $0.authToken = nil
        }
    }
}
