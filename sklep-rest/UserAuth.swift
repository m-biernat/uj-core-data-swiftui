//
//  UserAuth.swift
//  sklep-rest
//
//  Created by user209006 on 1/15/22.
//

import SwiftUI
import Auth0
import CryptoKit

class UserAuth: ObservableObject {
    static let shared = UserAuth()
    
    @Published var isLoggedIn: Bool
    
    let credentialsManager: CredentialsManager!
    
    var credentials: Credentials?
    var profile: UserInfo?
    
    private init() {
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        
        isLoggedIn = credentialsManager.hasValid()
        
        if isLoggedIn {
            getCredentials()
            getProfile()
        }
    }
    
    private func getCredentials() {
        credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                // Handle error
                print("Error: \(String(describing: error))")
                return
            }
            // You now have a valid credentials object, you might want to store this locally for easy access.
            // You will use this later to retrieve the user's profile
            self.credentials = credentials
        }
    }
    
    private func getProfile() {
        guard let accessToken = credentials?.accessToken else {
            // Handle Error
            return
        }

        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success(let profile):
                    // You've got the user's profile, good time to store it locally.
                    // e.g. self.profile = profile
                    self.profile = profile
                    self.setClientID()
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                }
            }
    }
    
    private func setClientID() {
        let hash = Insecure.MD5.hash(data: profile!.sub.data(using: .utf8)!)
        var hashStr = hash.compactMap { String(format: "%02X", $0) }.joined()
        hashStr.insert("-", at: hashStr.index(hashStr.startIndex, offsetBy: 8))
        hashStr.insert("-", at: hashStr.index(hashStr.startIndex, offsetBy: 13))
        hashStr.insert("-", at: hashStr.index(hashStr.startIndex, offsetBy: 18))
        hashStr.insert("-", at: hashStr.index(hashStr.startIndex, offsetBy: 23))
        sklep_appData.clientID = hashStr
    }
    
    func login() {
        Auth0
            .webAuth()
            .scope("openid profile email offline_access")
            .audience("https://dev-uzmorrli.us.auth0.com/userinfo")
            .useEphemeralSession()
            .start { result in
                switch result {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the login page
                    self.credentials = credentials
                    if !self.credentialsManager.store(credentials: credentials) {
                        print("Error storing credentials")
                    }
                    self.getProfile()
                    self.isLoggedIn = true
                    print("Credentials: \(credentials)")
                }
            }
    }
    
    func logout() {
        credentialsManager.revoke { error in
            guard error == nil else {
                // Handle error
                print("Error: \(String(describing: error))")
                return
            }

            // The user is now logged out
            self.credentials = nil
            self.profile = nil
            DispatchQueue.main.async {
                self.isLoggedIn = false
            }
        }
    }
}
