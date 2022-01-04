//
//  ContentView.swift
//  sklep-rest
//
//  Created by kprzystalski on 18/01/2021.
//

import SwiftUI
import CoreData

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Kategoria.title, ascending: true)],
        animation: .default)
    
    private var kategorie: FetchedResults<Kategoria>
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                List(kategorie) { kategoria in
                    NavigationLink(kategoria.title!, destination: ProductView(kategoria: kategoria))
                }
                .navigationTitle("Sklep")
                .navigationBarTitleDisplayMode(.large)
            }
            Divider()
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
