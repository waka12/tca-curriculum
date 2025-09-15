//
//  Day21RegisterFormScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/15.
//

import SwiftUI
import ComposableArchitecture

struct Day21RegisterFormScreen: View {
    @Bindable var store: StoreOf<Day21RegisterFormFeature>

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                TextField("mail", text: $store.email)
                if let errorText = store.emailError {
                    Text(errorText).foregroundColor(.red)
                }
            }
            VStack {
                SecureField("password", text: $store.password)
                if let errorText = store.passwordError {
                    Text(errorText).foregroundColor(.red)
                }
            }
            VStack {
                SecureField("confirm password", text: $store.confirmPassword)
                if let errorText = store.confirmPasswordError {
                    Text(errorText).foregroundColor(.red)
                }
            }

            HStack {
                Text("利用規約に同意しますか？")
                Spacer()
                Button {
                    store.send(.agreeButtonTapped)
                } label: {
                    if store.isAgree {
                        Image(systemName: "checkmark.square")
                    } else {
                        Image(systemName: "square")
                    }
                }
            }

            Button("登録") {
                store.send(.submitButtonTapped)
            }
            .disabled(!store.isValid)
        }
        .padding()
    }
}

#Preview {
    Day21RegisterFormScreen(store: Store(initialState: Day21RegisterFormFeature.State()) {
        Day21RegisterFormFeature()
    })
}
