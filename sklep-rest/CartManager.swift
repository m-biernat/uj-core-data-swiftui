//
//  CartManager.swift
//  sklep-rest
//
//  Created by user209006 on 12/27/21.
//

import CoreData

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
    
    static func addToCart(produkt: Produkt) {
        if(!checkIfExists(model: "Koszyk", field: "produkt.title", fieldValue: produkt.title!))
        {
            let context = persistentContainer.viewContext
            
            let koszykEntity = NSEntityDescription.entity(forEntityName: "Koszyk", in: context)
            
            let koszyk = NSManagedObject(entity: koszykEntity!, insertInto: context)
            
            koszyk.setValue("0", forKey: "server_id")
            koszyk.setValue(1, forKey: "quantity")
            koszyk.setValue(produkt, forKey: "produkt")
            
            try! context.save()
        } else {
            updateCart(produkt: produkt)
        }
    }
    
    static func updateCart(produkt: Produkt) {
        let context = persistentContainer.viewContext
        
        produkt.koszyk?.quantity += 1
        
        try! context.save()
    }
    
    static func removeFromCart(koszyk: Koszyk) {
        let context = persistentContainer.viewContext
        
        koszyk.quantity -= 1
        
        if koszyk.quantity < 1 {
            context.delete(koszyk)
        }
        
        try! context.save()
    }
    
    static func removeCart() {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Koszyk")
        
        let objects = try? context.fetch(fetchRequest) as? [Koszyk]
        
        objects?.forEach { koszyk in
            context.delete(koszyk)
        }
        
        try! context.save()
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
