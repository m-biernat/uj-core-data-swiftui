//
//  ContentView.swift
//  sklep-rest
//
//  Created by user209006 on 1/3/22.
//

import SwiftUI

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    
    @State var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            CategoryView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Kategorie")
                }.tag(0)
            CartView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Koszyk")
                }.tag(1)
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
