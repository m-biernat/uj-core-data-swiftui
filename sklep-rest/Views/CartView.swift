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
    
    @State private var actionPerformed = false;
    
    var body: some View {
        let isCartEmpty = productsInCart.count < 1
        
        VStack(spacing: 0) {
            if isCartEmpty {
                Spacer()
                Text("Koszyk jest pusty")
                    .foregroundColor(Color.gray)
                Spacer()
            }
            else {
                if actionPerformed {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                else {
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
                                            let price = String(calculatePrice(koszyk.produkt!.price, koszyk.quantity))
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
                                        actionPerformed = true
                                        makeOrder(totalCost: calculateTotalCost()) { zamowienie in
                                            fillOrder(zamowienie) {
                                                removeCart() {
                                                    actionPerformed = false
                                                }
                                            }
                                        }
                                    },
                                    label: {
                                        Image(systemName: "barcode")
                                            .font(.title2)
                                        Text("Zamów")
                                    })
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)
                                    .disabled(actionPerformed)
                                
                                Button(
                                    action: {
                                        actionPerformed = true
                                        removeCart() {
                                            actionPerformed = false
                                        }
                                    },
                                    label: {
                                        Image(systemName: "bin.xmark")
                                            .font(.title2)
                                    })
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)
                                    .disabled(actionPerformed)
                                
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
        let result = productsInCart.map({$0.produkt!.price * Double($0.quantity)}).reduce(0, +)
        return Double(round(100 * result) / 100)
    }
    
    func calculatePrice(_ price: Double, _ quantity: Int16) -> Double {
        let result = price * Double(quantity)
        return Double(round(100 * result) / 100)
    }
    
    func removeCart(completion: @escaping () -> Void) {
        RequestManager.removeDataRequest(postfix: "/koszyk/" + sklep_appData.clientID) {
            
            Koszyk.removeAll(viewContext)
            
            completion()
        }
    }
    
    func makeOrder(totalCost: Double, completion: @escaping (Zamowienie) -> Void) {
        let postData = PostRequestData.ZamowienieModel(
            client_id: sklep_appData.clientID,
            price: totalCost,
            date: Date.now.formatted(.iso8601),
            paid: false
        )
        
        print("Send \(postData.date)")
        
        RequestManager.sendDataRequest(data: postData,
                                       postfix: "/zamowienie/") { (result: RequestData.ZamowienieModel) -> () in
            let zamowienieEntity = NSEntityDescription.entity(forEntityName: "Zamowienie", in: viewContext)
            
            let zamowienie = NSManagedObject(entity: zamowienieEntity!, insertInto: viewContext)
            
            zamowienie.setValuesForKeys([
                "server_id": result.id,
                "price": result.price,
                "date": ISO8601DateFormatter().date(from: result.date)!,
                "paid": result.paid
            ])
            
            print(result.date)
        
            try! viewContext.save()
            completion(zamowienie as! Zamowienie)
        }
    }
    
    func fillOrder(_ zamowienie: Zamowienie, completion: @escaping () -> Void) {
        var postData: [PostRequestData.ZamowienieProduktModel] = []
        
        productsInCart.forEach { productInCart in
            postData.append(PostRequestData.ZamowienieProduktModel(
                produkt_id: productInCart.produkt!.server_id!,
                title: productInCart.produkt!.title!,
                quantity: Int(productInCart.quantity),
                price: calculatePrice(productInCart.produkt!.price, productInCart.quantity),
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
        
            try! viewContext.save()
            completion()
        }
    }
}
