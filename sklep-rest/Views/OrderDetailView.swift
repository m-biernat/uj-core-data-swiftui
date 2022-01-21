//
//  OrderDetailView.swift
//  sklep-rest
//
//  Created by user209006 on 1/20/22.
//

import SwiftUI
import CoreData

struct OrderDetailView: View {
    @Environment(\.managedObjectContext) var viewContext

    var zamowienie: Zamowienie
    
    var body: some View {
        VStack(spacing: 0) {
            OrderView(zamowienie: zamowienie)
            
            let paid = zamowienie.paid
            HStack() {
                Text("Status: ")
                Spacer()
                if paid {
                    Text("ZAPŁACONE")
                        .foregroundColor(Color.green)
                }
                else {
                    Text("OCZEKUJE NA OPŁATE")
                        .foregroundColor(Color.yellow)
                }
            }
            .padding()
            
            Divider()
            
            let orderedProducts = getOrderedProducts()
            HStack() {
                Text("Liczba produktów: ")
                Spacer()
                let productsCount = String(orderedProducts.count)
                let totalCount = String(orderedProducts.map({$0.quantity}).reduce(0, +))
                Text("\(productsCount) (\(totalCount) szt.)")
            }
            .padding()
            
            List(orderedProducts) { produkt in
                VStack(alignment: .leading) {
                    Text(produkt.title!)
                        .lineLimit(1)
                    Spacer()
                    Text(produkt.produkt_id!)
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundColor(Color.gray)
                    Spacer()
                    HStack() {
                        let quantity = String(produkt.quantity)
                        Text(quantity + " szt.")
                            .font(.caption)
                        Spacer()
                        let price = String(produkt.price)
                        Text(price + " zł")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 8)
            }
            
            if !paid {
                Divider()
                VStack() {
                    Button(
                        action: {
                            print("platnosc")
                        },
                        label: {
                            Image(systemName: "dollarsign.square.fill")
                                .font(.title2)
                            Text("Płatność")
                        })
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                }
                .padding(8)
            }
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Zamowienie")
        let zam = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Zamowienie
        
        OrderDetailView(zamowienie: zam).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension OrderDetailView {
    func getOrderedProducts() -> [ZamowienieProdukt] {
        let predicate = NSPredicate(format: "zamowienie == %@", zamowienie)
        let productsRequest = NSFetchRequest<ZamowienieProdukt>(entityName: "ZamowienieProdukt")
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
