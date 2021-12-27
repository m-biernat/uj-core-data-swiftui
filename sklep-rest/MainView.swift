//
//  ContentView.swift
//  sklep-rest
//
//  Created by kprzystalski on 18/01/2021.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Kategoria.title, ascending: true)],
        animation: .default)
    
    private var kategorie: FetchedResults<Kategoria>
    
    @State private var showingCart = false
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(kategorie) { kategoria in
                        HStack {
                            NavigationLink(kategoria.title!, destination: ProductView(kategoria: kategoria))
                        }
                    }
                }
                .navigationBarTitle("Sklep")
                .navigationBarTitleDisplayMode(.large)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(
                        action: {
                            showingCart.toggle()
                        },
                        label: {
                        Image(systemName: "cart")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.white)
                    })
                    .background(Color.accentColor)
                    .cornerRadius(38.5)
                    .padding(.bottom, 8)
                    .padding(.trailing, 16)
                    .sheet(isPresented: $showingCart)
                    { CartView() }
                    }
                }
            }
        }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
