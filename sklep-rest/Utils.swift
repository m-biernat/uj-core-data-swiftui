//
//  Utils.swift
//  sklep-rest
//
//  Created by user209006 on 1/21/22.
//

import Foundation
import CoreData

struct FormatDate {
    static let shared = FormatDate()
    
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY hh:mm a"
    }
    
    static func toString(_ date: Date) -> String {
        return shared.dateFormatter.string(from: date)
    }
}

extension NSManagedObject {
    class func removeAll(_ viewContext: NSManagedObjectContext) {
        let entityName = String(describing: self)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let objects = try? viewContext.fetch(fetchRequest) as? [NSManagedObject]
        
        objects?.forEach { item in
            viewContext.delete(item)
        }
        
        try! viewContext.save()
    }
    
    class func checkIfExists(_ viewContext: NSManagedObjectContext, field: String, fieldValue: String) -> Bool {
        let entityName = String(describing: self)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(field) = %@", fieldValue)
        
        do {
            let fetchResults = try viewContext.fetch(fetchRequest) as? [NSManagedObject]
            if fetchResults!.count > 0 {
                return true
            }
            return false
        } catch {
            print("Core Data Error")
        }
        return false
    }
    
    class func getReference(_ viewContext: NSManagedObjectContext, id: String) -> Self {
        let entiyName = String(describing: self)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entiyName)
        fetchRequest.predicate = NSPredicate(format: "server_id == %@", id)
        
        return try! viewContext.fetch(fetchRequest).first as! Self
    }
}
