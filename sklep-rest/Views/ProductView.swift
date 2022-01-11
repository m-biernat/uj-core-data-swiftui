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
                HStack {
                    VStack(alignment: .leading) {
                        Text(produkt.title!)
                        Spacer()
                        Text(produkt.desc!).font(.caption).lineLimit(1)
                    }
                    Spacer()
                    let quantity = String(produkt.quantity)
                    Text(quantity + " szt.").font(.caption)
                    Button(action: {
                        addToCart(produkt: produkt) { () -> () in

                        }
                    }) {
                        Image(systemName: "cart.badge.plus")
                    }
                }.padding(.vertical, 8)
            }
        }.navigationBarTitle(kategoria.title!)
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
    func addToCart(produkt: Produkt, completion: @escaping () -> Void) {
        if(!checkIfExists(model: "Koszyk", field: "produkt.server_id", fieldValue: produkt.server_id!))
        {
            let postData = RequestManager.PostKoszykDataModel(
                client_id: sklep_appData.clientID,
                quantity: 1,
                produkt_id: RequestManager.Produkt(
                    id: produkt.server_id!
                )
            )
            
            RequestManager.sendDataRequest(data: postData) { (result) -> () in
                let koszykEntity = NSEntityDescription.entity(forEntityName: "Koszyk", in: viewContext)
                
                let koszyk = NSManagedObject(entity: koszykEntity!, insertInto: viewContext)
                
                koszyk.setValue(result.id, forKey: "server_id")
                koszyk.setValue(result.quantity, forKey: "quantity")
                koszyk.setValue(produkt, forKey: "produkt")
            
                try! viewContext.save()
                completion()
            }
        } else {
            updateCart(produkt: produkt, completion: completion)
        }
    }
    
    func updateCart(produkt: Produkt, completion: @escaping () -> Void) {
        let koszyk = produkt.koszyk!
        var quantity = Int(koszyk.quantity)
        quantity += 1
        
        let updateData = RequestManager.KoszykDataModel(
            client_id: sklep_appData.clientID,
            quantity: quantity,
            produkt_id: RequestManager.Produkt(
                id: produkt.server_id!
            ),
            id: koszyk.server_id!
        )
        
        RequestManager.sendDataRequest(data: updateData,
                                       method: "PUT",
                                       postfix: "produkt/" + koszyk.server_id!) { (result) -> () in
            koszyk.quantity = Int16(result.quantity)
            
            try! viewContext.save()
            completion()
        }
    }
    
    func checkIfExists(model: String, field: String, fieldValue: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: model)
        fetchRequest.predicate = NSPredicate(format: "\(field) = %@", fieldValue)
        
        do {
            let fetchResults = try viewContext.fetch(fetchRequest) as? [NSManagedObject]
            if fetchResults!.count > 0 {
                return true
            }
            return false
        } catch {
            print("Nie bangla2")
        }
        return false
    }
}
