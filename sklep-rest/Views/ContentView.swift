//
//  ContentView.swift
//  sklep-rest
//
//  Created by user209006 on 1/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    
    @State var tabSelection = 0
    
    init() {
        loadCategoriesFromAPI()
        loadProductsFromAPI()
        loadCartFromAPI()
    }
    
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
            ProfileView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Konto")
                }.tag(2)
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }.tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func loadCategoriesFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = sklep_appData.url + "/kategoria"
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let kategoriaEntity = NSEntityDescription.entity(forEntityName: "Kategoria", in: context)
        
        let dispatchGroup = DispatchGroup()
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for item in object as! [Dictionary<String, AnyObject>] {
                        
                        let title = item["title"] as! String
                        let server_id = item["id"] as! String
                        
                        if !checkIfExists(model: "Kategoria", field: "title", fieldValue: item["title"] as! String) {

                        
                            let kategoria = NSManagedObject(entity: kategoriaEntity!, insertInto: context)
                        
                            kategoria.setValue(title, forKey: "title")
                            kategoria.setValue(server_id, forKey: "server_id")
                        
                            print("Dodano kategorię: \(title) o id: \(server_id)")
                        } else {
                            print("Kategoria: \(title) o id: \(server_id) jest już w bazie")
                        }
                        
                    }
                    try context.save()
                    dispatchGroup.leave()
                } else {
                    print("Błędny JSON")
                }
                
            } catch {
                print("Problem z pobraniem odpowiedzi - kategorie")
                dispatchGroup.leave()
                return
            }
        })
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()
    }
    
    func loadProductsFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = sklep_appData.url + "/produkt"
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let dispatchGroup = DispatchGroup()
        
        let produktEntity = NSEntityDescription.entity(forEntityName: "Produkt", in: context)
        
                
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for item in object as! [Dictionary<String, AnyObject>] {
                        if !checkIfExists(model: "Produkt", field: "title", fieldValue: item["title"] as! String) {
                        let title = item["title"] as! String
                        let server_id = item["id"] as! String
                        let desc = item["description"] as! String
                        let quantity = item["quantity"] as! Int
                        let price = item["price"] as! Double
                        let url = item["image"] as! String
                        let kategoria_id = item["kategoria_id"] as! NSDictionary
                        let kat_id = kategoria_id["id"] as! String
                        let katRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Kategoria")
                        let predicate = NSPredicate(format: "server_id == %@", kat_id)
                        
                            katRequest.predicate = predicate
                        
                        let kat = try! context.fetch(katRequest).first as! Kategoria
                        
                        let produkt = NSManagedObject(entity: produktEntity!, insertInto: context)
                        
                        produkt.setValue(title, forKey: "title")
                        produkt.setValue(desc, forKey: "desc")
                        produkt.setValue(url, forKey: "image_url")
                        produkt.setValue(server_id, forKey: "server_id")
                        produkt.setValue(quantity, forKey: "quantity")
                        produkt.setValue(price, forKey: "price")
                        produkt.setValue(kat, forKey: "kategoria")
                        
                        print("Dodano produkt: \(title) o id: \(server_id)")
                        } else {
                            let title = item["title"] as! String
                            let server_id = item["id"] as! String
                            print("Produkt: \(title) o id: \(server_id) jest już w bazie")
                        }
                    }
                    try context.save()
                    dispatchGroup.leave()
                } else {
                    print("Błędny JSON")
                }
                
            } catch {
                print("Unexpected error: \(error).")
                print("Problem z pobraniem odpowiedzi")
                dispatchGroup.leave()
                return
            }
        })
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()
    }
    
    func loadCartFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = sklep_appData.url + "/koszyk/" + sklep_appData.clientID
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let koszykEntity = NSEntityDescription.entity(forEntityName: "Koszyk", in: context)
        
                
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for item in object as! [Dictionary<String, AnyObject>] {
                        if !checkIfExists(model: "Koszyk", field: "server_id", fieldValue: item["id"] as! String) {
                        let server_id = item["id"] as! String
                        let quantity = item["quantity"] as! Int
                        let produkt_id = item["produkt_id"] as! NSDictionary
                        let prod_id = produkt_id["id"] as! String
                        let prodRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Produkt")
                        let predicate = NSPredicate(format: "server_id == %@", prod_id)
                        
                            prodRequest.predicate = predicate
                        
                            let prod = try! context.fetch(prodRequest).first as! Produkt
                        
                        let koszyk = NSManagedObject(entity: koszykEntity!, insertInto: context)
                        
                        koszyk.setValue(server_id, forKey: "server_id")
                        koszyk.setValue(quantity, forKey: "quantity")
                        koszyk.setValue(prod, forKey: "produkt")
                        
                            print("Dodano produkt: \(prod.title!) x \(quantity) do koszyka")
                        } else {
                            let prod_id = item["produkt_id"] as! NSDictionary
                            let id = prod_id["id"] as! String
                            let quantity = item["quantity"] as! Int
                            print("Produkt o id: \(id) x \(quantity) jest już w koszyku")
                        }
                    }
                    try context.save()
                } else {
                    print("Błędny JSON")
                }
                
            } catch {
                print("Unexpected error: \(error).")
                print("Problem z pobraniem odpowiedzi")
                return
            }
        })
        task.resume()
    }
    
    func checkIfExists(model: String, field: String, fieldValue: String) -> Bool {
        let context = persistenceController.container.viewContext
        
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
