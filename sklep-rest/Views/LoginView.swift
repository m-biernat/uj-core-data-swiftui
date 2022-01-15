//
//  LoginView.swift
//  sklep-rest
//
//  Created by user209006 on 1/15/22.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            let userAuth = UserAuth.shared
            Spacer()
            Text("sklep-rest")
                .font(.title)
            Spacer()
            Button(
                action: {
                    userAuth.login()
                },
                label: {
                    Text("Logowanie")
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .disabled(userAuth.isLoggedIn)
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
