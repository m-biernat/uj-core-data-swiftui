//
//  sklep_restApp.swift
//  sklep-rest
//
//  Created by kprzystalski on 18/01/2021.
//

import SwiftUI
import Stripe

struct sklep_appData {
    static let url = "https://2716-195-82-43-75.ngrok.io"
    static var clientID = "00000000-0000-0000-0000-000000000000"
}

@main
struct sklep_restApp: App {
    @StateObject var userAuth = UserAuth.shared
    
    init() {
        StripeAPI.defaultPublishableKey = "‌pk_test_51KKhrUBa6ifvvEkbICPSJY60YFbOZgFZsAlgdZKnEWKlAb5rtrOgWg2EnxsybGErkr2A3ZsQ2sWZdqHu4MWAT4sd00ZEL53AfO"
    }
    
    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedIn {
                ContentView()
            }
            else {
                LoginView()
            }
        }
    }
}
