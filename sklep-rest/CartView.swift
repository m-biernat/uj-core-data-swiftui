//
//  CartView.swift
//  sklep-rest
//
//  Created by user209006 on 12/26/21.
//

import SwiftUI

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var refresh = false
    
    var body: some View {
        Text("Koszyk").font(.headline).padding(.top)
        
        let productsInCart = CartManager.getCartEntries()
        
        let isCartEmpty = productsInCart.count < 1
        
        if isCartEmpty {
            Spacer()
            Text("Koszyk jest pusty")
                .foregroundColor(Color.gray)
            Spacer()
        } else {
            List {
                ForEach(productsInCart) { koszyk in
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
                            CartManager.removeFromCart(koszyk: koszyk)
                            refresh.toggle()
                        }) {
                            Image(systemName: "bin.xmark")
                                .foregroundColor(Color.red)
                        }
                    }.padding(.vertical, 8)
                }
            }
        }
        
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
                .disabled(isCartEmpty)
                .opacity(isCartEmpty ? 0 : 1)
                        
            Button(
                action: {
                    CartManager.removeCart()
                    refresh.toggle()
                },
                label: {
                    Image(systemName: "bin.xmark")
                        .font(.title2)
                })
                .padding()
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .disabled(isCartEmpty)
                .opacity(isCartEmpty ? 0 : 1)
            
            Spacer()
            Spacer()
            
            Button(
                action: {
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                })
                .padding()
                .frame(width:50, height:50)
                .background(Color.accentColor)
                .foregroundColor(Color.white)
                .cornerRadius(38.5)
            
            Spacer()
        }
        .padding(.bottom, 8)
        
        // Refresh view in a hacky way
        if refresh != refresh {
            Text(String(refresh))
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
