//
//  ProductView.swift
//  sklep-rest
//
//  Created by alidej on 11/11/2021.
//

import SwiftUI
import CoreData

struct ProductView: View {
    @Environment(\.managedObjectContext) var viewContext

    var kategoria: Kategoria
    
    var body: some View {
        List(getProductsFromCategory()) { produkt in
                NavigationLink(
                    destination: ProductDetailView(produkt: produkt)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(produkt.title!)
                                .lineLimit(1)
                            Spacer()
                            Text(produkt.desc!)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack() {
                            let price = String(produkt.price)
                            Text(price)
                                .font(.caption)
                            Text("PLN")
                                .font(.caption2)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationBarTitle(kategoria.title!)
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Kategoria")
        let kat = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Kategoria
        
        ProductView(kategoria: kat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension ProductView {
    func getProductsFromCategory() -> [Produkt] {
        let predicate = NSPredicate(format: "kategoria == %@", kategoria)
        let productsRequest = NSFetchRequest<Produkt>(entityName: "Produkt")
        productsRequest.predicate = predicate
        do {
            let results = try self.viewContext.fetch(productsRequest);
            return results
        } catch {
            print("Nie bangla")
        }
        return []
    }
}
