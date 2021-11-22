//
//  ProductView.swift
//  sklep-rest
//
//  Created by alidej on 11/11/2021.
//

import SwiftUI
import CoreData

struct ProductView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    var kategoria: Kategoria
    
    func sample() -> [Produkt] {
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
    
    var body: some View {
        List {
        ForEach(sample()) { produkt in
            HStack{
                Text(produkt.title!)
                Button(action: {}) {
                    Text("Add to basket").padding(.trailing)
                }
            }
        }
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Kategoria")
        let kat = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Kategoria
        
        ProductView(kategoria: kat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
