//
//  Day15LoginScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/06.
//

import SwiftUI
import ComposableArchitecture

struct Day15LoginScreen: View {
    @Bindable var store: StoreOf<Day15LoginFeature>
    var body: some View {
        VStack(alignment: .leading) {
            if store.authToken != nil {
                Text("ログイン中です")
            } else {
                TextField("メールアドレス", text: $store.mailTextField)
                if store.isEmailError {
                    Text("メールアドレスの形式が正しくありません")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                SecureField("パスワード", text: $store.passTextField)
                    .padding(.top)
                if store.isPassError {
                    Text("8文字以上で入力してください")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }

                HStack {
                    Spacer()
                    Button("ログイン") {
                        store.send(.loginButtonTapped)
                    }
                    .disabled(store.isLoading)
                    .padding(.top)
                    Spacer()
                }

                if let errorText = store.errorText {
                    Text(errorText)
                        .padding(.top)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .padding()
    }
}

#Preview {
    Day15LoginScreen(store: Store(initialState: Day15LoginFeature.State()) {
        Day15LoginFeature()
    })
}
