//
//  ProfileView.swift
//  sklep-rest
//
//  Created by user209006 on 1/15/22.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let userAuth = UserAuth.shared
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                VStack(spacing: 0) {
                    Spacer()
                    AsyncImage(url: userAuth.profile?.picture) { image in
                               image
                                   .resizable()
                                   .aspectRatio(contentMode: .fit)
                           } placeholder: {
                               Image(systemName: "photo")
                                   .imageScale(.large)
                                   .foregroundColor(.gray)
                           }
                           .frame(width: 150, height: 150)
                           .cornerRadius(100)
                           .padding()
                    
                    Text("\(userAuth.profile?.email ?? "name@domain.com")")
                    Spacer()
                    Button(
                        action: {
                            Koszyk.removeAll(viewContext)
                            Zamowienie.removeAll(viewContext)
                            ZamowienieProdukt.removeAll(viewContext)
                            userAuth.logout()
                        },
                        label: {
                            Text("Wyloguj się")
                        })
                        .padding()
                        .foregroundColor(Color.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 1))
                        .disabled(!userAuth.isLoggedIn)
                    Spacer()
                    
                    NavigationLink(destination: {
                        OrderListView().environment(\.managedObjectContext, viewContext)
                    }) {
                        Text("Zamówienia")
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.accentColor)
                    .cornerRadius(5)
                    
                    Spacer()
                }
                .navigationBarTitle("Konto", displayMode: .inline)
                .navigationBarHidden(true)
            }
            Divider()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
