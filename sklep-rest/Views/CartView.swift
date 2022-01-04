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
                List(productsInCart) { koszyk in
                    HStack{
                        VStack(alignment: .leading) {
                            Text(koszyk.produkt!.title!)
                            Spacer()
                            Text(koszyk.produkt!.desc!)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        Spacer()
                        let quantity = String(koszyk.quantity)
                        Text(quantity + " szt.")
                            .font(.caption)
                        Button(action: {
                            removeFromCart(koszyk: koszyk) { () in
                                
                            }
                        }) {
                            Image(systemName: "bin.xmark")
                                .foregroundColor(Color.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                HStack() {
                    Spacer()
                    
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
                                
                    Button(
                        action: {
                            removeCart() { () in
                                
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
                    
                    Spacer()
                }
                .padding(8)
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
    func removeFromCart(koszyk: Koszyk, completion: @escaping () -> Void) {
        var quantity = Int(koszyk.quantity)
        quantity -= 1
        
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
                
                try! viewContext.save()
                completion()
            }
            
        } else {
            RequestManager.removeDataRequest(postfix: koszyk.server_id!) { () -> () in
                viewContext.delete(koszyk)
                
                try! viewContext.save()
                completion()
            }
        }
    }
    
    func removeCart(completion: @escaping () -> Void) {
        RequestManager.removeDataRequest(postfix: "klient/" + sklep_appData.clientID) { () -> () in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Koszyk")
            
            let objects = try? viewContext.fetch(fetchRequest) as? [Koszyk]
            
            objects?.forEach { koszyk in
                viewContext.delete(koszyk)
            }
            
            try! viewContext.save()
            completion()
        }
    }
}
