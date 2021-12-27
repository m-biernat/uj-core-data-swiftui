//
//  CartView.swift
//  sklep-rest
//
//  Created by user209006 on 12/26/21.
//

import SwiftUI

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Text("Koszyk").font(.headline).padding(.top)
        
        List {
            Text("aaa")
            Text("bbb")
            Text("aaa")
            Text("bbb")
            Text("aaa")
            Text("bbb")
            Text("aaa")
            Text("bbb")
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
                        
            Button(
                action: {
                    print("wyczysc")
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
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
