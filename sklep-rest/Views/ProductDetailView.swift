//
//  DetailView.swift
//  sklep-rest
//
//  Created by user209006 on 1/11/22.
//

import SwiftUI
import CoreData

struct ProductDetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    var produkt: Produkt
    
    @State private var quantity = 0
    
    @State private var addToCartActive = true
    @State private var removeFromCartActive = true
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: produkt.image_url!)) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo")
                               .imageScale(.large)
                               .foregroundColor(.gray)
            }
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: 125)
            .clipped()
            
            Text(produkt.title!)
                .font(.title)
                .lineLimit(1)
                .padding(.vertical)

            Text(produkt.desc!)
                .lineLimit(4)
                .padding(.horizontal)
            
            Spacer()
            
            Divider()
            
            HStack {
                Spacer()
                let quantity = String(produkt.quantity)
                Text(quantity + " szt.")
                    .padding()
                Spacer()
                let price = String(produkt.price)
                Text(price + " zł")
                    .padding()
                Spacer()
            }
            
            Divider()
            
            Spacer()
            
            HStack {
                Spacer()
                
                HStack() {
                    Image(systemName: "cart")
                        .font(.title2)
                        .foregroundColor(Color.accentColor)
                    Text(String(quantity) + " szt.")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                
                Spacer()
                
                Button(
                    action: {
                        addToCartActive = false
                        addToCart() {
                            quantity = Int(produkt.koszyk?.quantity ?? 0)
                            addToCartActive = true
                        }
                    },
                    label: {
                        Image(systemName: "cart.fill.badge.plus")
                            .font(.title2)
                    })
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    .disabled(!addToCartActive)
                            
                Button(
                    action: {
                        removeFromCartActive = false
                        removeFromCart() {
                            quantity = Int(produkt.koszyk?.quantity ?? 0)
                            removeFromCartActive = true
                        }
                    },
                    label: {
                        Image(systemName: "cart.fill.badge.minus")
                            .font(.title2)
                    })
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    .disabled(!removeFromCartActive || quantity == 0)
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            quantity = Int(produkt.koszyk?.quantity ?? 0)
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Produkt")
        let prod = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Produkt
        
        ProductDetailView(produkt: prod)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension ProductDetailView {
    func addToCart(completion: @escaping () -> Void) {
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
            updateCart(completion: completion)
        }
    }
    
    func updateCart(completion: @escaping () -> Void) {
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
    
    func removeFromCart(completion: @escaping () -> Void) {
        let koszyk = produkt.koszyk!
        var quantity = Int(koszyk.quantity)
        quantity -= 1
        
        if (quantity > 0) {
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
            
        } else {
            RequestManager.removeDataRequest(postfix: "produkt/" + koszyk.server_id!) { () -> () in
                viewContext.delete(koszyk)
                
                try! viewContext.save()
                completion()
            }
        }
    }
}
