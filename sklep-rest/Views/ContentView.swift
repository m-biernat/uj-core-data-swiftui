//
//  ContentView.swift
//  sklep-rest
//
//  Created by user209006 on 1/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @State var tabSelection = 0
    
    init() {
        loadCategoriesFromAPI()
        loadProductsFromAPI()
        loadCartFromAPI()
        loadOrdersFromAPI()
        loadOrderDetailsFromAPI()
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            CategoryView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Kategorie")
                }.tag(0)
            CartView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Koszyk")
                }.tag(1)
            ProfileView()
                .environment(\.managedObjectContext, viewContext)
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
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        RequestManager.getDataRequest(postfix: "/kategoria",
                                      failure: { dispatchGroup.leave() }) { (results: [RequestData.KategoriaModel]) in
            let kategoriaEntity = NSEntityDescription.entity(forEntityName: "Kategoria", in: viewContext)
            
            results.forEach { result in
                if !Kategoria.checkIfExists(viewContext, field: "server_id", fieldValue: result.id) {
                    let kategoria = NSManagedObject(entity: kategoriaEntity!, insertInto: viewContext)

                    kategoria.setValuesForKeys([
                        "title": result.title,
                        "server_id": result.id
                    ])
                }
            }
            
            try! viewContext.save()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func loadProductsFromAPI() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        RequestManager.getDataRequest(postfix: "/produkt",
                                      failure: { dispatchGroup.leave() }) { (results: [RequestData.ProduktModel]) in
            let produktEntity = NSEntityDescription.entity(forEntityName: "Produkt", in: viewContext)
            
            results.forEach { result in
                if !Produkt.checkIfExists(viewContext, field: "server_id", fieldValue: result.id) {
                    let produkt = NSManagedObject(entity: produktEntity!, insertInto: viewContext)

                    produkt.setValuesForKeys([
                        "title": result.title,
                        "desc": result.description,
                        "image_url": result.image,
                        "quantity": result.quantity,
                        "price": result.price,
                        "kategoria": Kategoria.getReference(viewContext, id: result.kategoria_id.id),
                        "server_id": result.id
                    ])
                }
            }
            
            try! viewContext.save()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func loadCartFromAPI() {
        RequestManager.getDataRequest(postfix: "/koszyk/" + sklep_appData.clientID,
                                      failure: {}) { (results: [RequestData.KoszykModel]) in
            let koszykEntity = NSEntityDescription.entity(forEntityName: "Koszyk", in: viewContext)
            
            results.forEach { result in
                if !Koszyk.checkIfExists(viewContext, field: "server_id", fieldValue: result.id) {
                    let koszyk = NSManagedObject(entity: koszykEntity!, insertInto: viewContext)

                    koszyk.setValuesForKeys([
                        "quantity": result.quantity,
                        "produkt": Produkt.getReference(viewContext, id: result.produkt_id.id),
                        "server_id": result.id
                    ])
                }
            }
            
            try! viewContext.save()
        }
    }
    
    func loadOrdersFromAPI() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        RequestManager.getDataRequest(postfix: "/zamowienie/klient/" + sklep_appData.clientID,
                                      failure: { dispatchGroup.leave() }) { (results: [RequestData.ZamowienieModel]) in
            let zamowienieEntity = NSEntityDescription.entity(forEntityName: "Zamowienie", in: viewContext)
            
            results.forEach { result in
                if !Zamowienie.checkIfExists(viewContext, field: "server_id", fieldValue: result.id) {
                    let zamowienie = NSManagedObject(entity: zamowienieEntity!, insertInto: viewContext)

                    zamowienie.setValuesForKeys([
                        "price": result.price,
                        "date": ISO8601DateFormatter().date(from: result.date)!,
                        "paid": result.paid,
                        "server_id": result.id
                    ])
                }
            }
            
            try! viewContext.save()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func loadOrderDetailsFromAPI() {
        RequestManager.getDataRequest(postfix: "/zamowienie/produkt/klient/" + sklep_appData.clientID,
                                      failure: {}) { (results: [RequestData.ZamowienieProduktModel]) in
            let produktEntity = NSEntityDescription.entity(forEntityName: "ZamowienieProdukt", in: viewContext)
            
            results.forEach { result in
                if !ZamowienieProdukt.checkIfExists(viewContext, field: "server_id", fieldValue: result.id) {
                    let produkt = NSManagedObject(entity: produktEntity!, insertInto: viewContext)

                    produkt.setValuesForKeys([
                        "produkt_id": result.produkt_id,
                        "title": result.title,
                        "quantity": result.quantity,
                        "price": result.price,
                        "zamowienie": Zamowienie.getReference(viewContext, id: result.zamowienie_id.id),
                        "server_id": result.id
                    ])
                }
            }
            
            try! viewContext.save()
        }
    }
}
