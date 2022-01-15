//
//  ProfileView.swift
//  sklep-rest
//
//  Created by user209006 on 1/15/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Spacer()
            Button(action: { UserAuth.shared.logout() }, label: { Text("Wyloguj się") })
            Spacer()
            Divider()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
