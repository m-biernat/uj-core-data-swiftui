//
//  CartManager.swift
//  sklep-rest
//
//  Created by user209006 on 12/27/21.
//

import CoreData
import UIKit

struct CartManager {
    static let persistentContainer = PersistenceController.shared.container
    
    static func getCartEntries() -> [Koszyk] {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Koszyk>
        fetchRequest = Koszyk.fetchRequest()
        
        let objects = try? context.fetch(fetchRequest)
        
        if let unwrapped = objects {
            return unwrapped
        } else {
            print("Koszyk jest pusty")
            return []
        }
    }
    
    static func addToCart(produkt: Produkt, completion: @escaping () -> Void) {
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
                let context = persistentContainer.viewContext
                
                let koszykEntity = NSEntityDescription.entity(forEntityName: "Koszyk", in: context)
                
                let koszyk = NSManagedObject(entity: koszykEntity!, insertInto: context)
                
                koszyk.setValue(result.id, forKey: "server_id")
                koszyk.setValue(result.quantity, forKey: "quantity")
                koszyk.setValue(produkt, forKey: "produkt")
            
                try! context.save()
                completion()
            }
        } else {
            updateCart(produkt: produkt, completion: completion)
        }
    }
    
    static func updateCart(produkt: Produkt, completion: @escaping () -> Void) {
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
                                       postfix: koszyk.server_id!) { (result) -> () in
            let context = persistentContainer.viewContext
            
            koszyk.quantity = Int16(result.quantity)
            
            try! context.save()
            completion()
        }
    }
    
    static func removeFromCart(koszyk: Koszyk, completion: @escaping () -> Void) {
        var quantity = Int(koszyk.quantity)
        quantity -= 1
        
        let context = persistentContainer.viewContext
        
        if (quantity > 0) {
            let updateData = RequestManager.KoszykDataModel(
                client_id: sklep_appData.clientID,
                quantity: quantity,
                produkt_id: RequestManager.Produkt(
                    id: koszyk.produkt!.server_id!
                ),
                id: koszyk.server_id!
            )
            
            RequestManager.sendDataRequest(data: updateData,
                                           method: "PUT",
                                           postfix: koszyk.server_id!) { (result) -> () in
                koszyk.quantity = Int16(result.quantity)
                
                try! context.save()
                completion()
            }
            
        } else {
            RequestManager.removeDataRequest(postfix: koszyk.server_id!) { () -> () in
                context.delete(koszyk)
                
                try! context.save()
                completion()
            }
        }
    }
    
    static func removeCart(completion: @escaping () -> Void) {
        RequestManager.removeDataRequest(postfix: "klient/" + sklep_appData.clientID) { () -> () in
            let context = persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Koszyk")
            
            let objects = try? context.fetch(fetchRequest) as? [Koszyk]
            
            objects?.forEach { koszyk in
                context.delete(koszyk)
            }
            
            try! context.save()
            completion()
        }
    }
    
    static func checkIfExists(model: String, field: String, fieldValue: String) -> Bool {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: model)
        fetchRequest.predicate = NSPredicate(format: "\(field) = %@", fieldValue)
        
        do {
            let fetchResults = try context.fetch(fetchRequest) as? [NSManagedObject]
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
