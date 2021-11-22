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

    var body: some View {
        NavigationView {
        List {
            ForEach(kategorie) { kategoria in
                HStack{
                    //ProductView(kategoria: kategoria)
                    //Text(kategoria.title!)
                    NavigationLink(kategoria.title!, destination: ProductView(kategoria: kategoria))
                    //NavigationLink(kategoria.value(forKey: "title") as! String, destination: ProduktView(kategoria: kategoria.))
                }
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
