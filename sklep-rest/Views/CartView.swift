//
//  CartView.swift
//  sklep-rest
//
//  Created by user209006 on 12/26/21.
//

import SwiftUI
import CoreData

struct CartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Koszyk.produkt?.title, ascending: true)],
        animation: .default)
    
    private var productsInCart: FetchedResults<Koszyk>
    
    var body: some View {
        let isCartEmpty = productsInCart.count < 1
        
        VStack(spacing: 0) {
            if isCartEmpty {
                Spacer()
                Text("Koszyk jest pusty")
                    .foregroundColor(Color.gray)
                Spacer()
            } else {
                NavigationView {
                    VStack(spacing: 0) {
                        List(productsInCart) { koszyk in
                            let produkt = koszyk.produkt!
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
                                        let quantity = String(koszyk.quantity)
                                        Text(quantity + " szt.")
                                            .font(.caption)
                                        let price = String(koszyk.produkt!.price * Double(koszyk.quantity))
                                        Text(price + " zł")
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .navigationBarTitle("Koszyk", displayMode: .inline)
                        .navigationBarHidden(true)
                
                        Divider()
                        
                        HStack() {
                            Spacer()
                            
                            Button(
                                action: {
                                    makeOrder(totalCost: calculateTotalCost()) { zamowienie in
                                        fillOrder(zamowienie: zamowienie) {
                                            //removeCart() { }
                                            
                                            print("Dzialuje")
                                        }
                                    }
                                },
                                label: {
                                    Image(systemName: "barcode")
                                        .font(.title2)
                                    Text("Zamów")
                                })
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                        
                            Button(
                                action: {
                                    removeCart() { }
                                },
                                label: {
                                    Image(systemName: "bin.xmark")
                                        .font(.title2)
                                })
                                .padding()
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                            
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                Divider()
                
                HStack {
                    Image(systemName: "sum")
                    let total = calculateTotalCost()
                    Text(String(total) + " zł")
                }.padding(4)
            }
            Divider()
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension CartView {
    func calculateTotalCost() -> Double {
        return productsInCart.map({$0.produkt!.price * Double($0.quantity)}).reduce(0, +)
    }
    
    func removeCart(completion: @escaping () -> Void) {
        RequestManager.removeDataRequest(postfix: "/koszyk/" + sklep_appData.clientID) { () -> () in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Koszyk")
            
            let objects = try? viewContext.fetch(fetchRequest) as? [Koszyk]
            
            objects?.forEach { koszyk in
                viewContext.delete(koszyk)
            }
            
            try! viewContext.save()
            completion()
        }
    }
    
    func makeOrder(totalCost: Double, completion: @escaping (Zamowienie) -> Void) {
        let postData = PostRequestData.ZamowienieModel(
            client_id: sklep_appData.clientID,
            price: totalCost,
            date: DateFormatter().string(from: Date()),
            paid: false
        )
        
        RequestManager.sendDataRequest(data: postData,
                                       postfix: "/zamowienie/") { (result: RequestData.ZamowienieModel) -> () in
            let zamowienieEntity = NSEntityDescription.entity(forEntityName: "Zamowienie", in: viewContext)
            
            let zamowienie = NSManagedObject(entity: zamowienieEntity!, insertInto: viewContext)
            
            zamowienie.setValuesForKeys([
                "server_id": result.id,
                "price": result.price,
                "date": DateFormatter().date(from: result.date)!,
                "paid": result.paid
            ])
            
            //zamowienie.setValue(result.id, forKey: "server_id")
            //zamowienie.setValue(result.price, forKey: "price")
            //zamowienie.setValue(DateFormatter().date(from: result.date), forKey: "date")
            //zamowienie.setValue(result.paid, forKey: "paid")
        
            //try! viewContext.save()
            completion(zamowienie as! Zamowienie)
        }
    }
    
    func fillOrder(zamowienie: Zamowienie, completion: @escaping () -> Void) {
        var postData: [PostRequestData.ZamowienieProduktModel] = []
        
        productsInCart.forEach { productInCart in
            postData.append(PostRequestData.ZamowienieProduktModel(
                produkt_id: productInCart.produkt!.server_id!,
                title: productInCart.produkt!.title!,
                quantity: Int(productInCart.quantity),
                price: productInCart.produkt!.price * Double(productInCart.quantity),
                zamowienie_id: RequestData.Zamowienie(
                    id: zamowienie.server_id!
                )
            ))
        }
        
        RequestManager.sendDataRequest(data: postData,
                                       postfix: "/zamowienie/produkt/") { (result: [RequestData.ZamowienieProduktModel]) -> () in
            let zamowienieProduktEntity = NSEntityDescription.entity(forEntityName: "ZamowienieProdukt", in: viewContext)
            
            result.forEach { item in
                let zamowienieProdukt = NSManagedObject(entity: zamowienieProduktEntity!, insertInto: viewContext)

                zamowienieProdukt.setValuesForKeys([
                    "server_id": item.id,
                    "produkt_id": item.produkt_id,
                    "title": item.title,
                    "quantity": item.quantity,
                    "price": item.price,
                    "zamowienie": zamowienie
                ])
            }
        
            //try! viewContext.save()
            completion()
        }
    }
}
