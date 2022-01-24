//
//  PaymentView.swift
//  sklep-rest
//
//  Created by user209006 on 1/23/22.
//

import SwiftUI
import CoreData
import Stripe

struct PaymentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var viewContext

    var zamowienie: Zamowienie?
    
    @State private var paymentMethodParams: STPPaymentMethodParams?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Płatność")
                .bold()
                .padding()
            
            if zamowienie != nil {
                OrderView(zamowienie: zamowienie!)
            }
            
            Spacer()
            
            Text("Wprowadź dane karty płatniczej")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(Color.gray)
                .padding(8)
            
            STPPaymentCardTextField.Representable
                .init(paymentMethodParams: $paymentMethodParams)
                .padding(.horizontal)
            
            Spacer()
            
            Spacer()
            
            Divider()
            
            HStack() {
                Button(
                    action: {
                        print("zaplac")
                    },
                    label: {
                        Image(systemName: "dollarsign.square.fill")
                            .font(.title2)
                        Text("Zapłać")
                    })
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                
                Button(
                    action: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    label: {
                        Text("Anuluj")
                    })
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
            }
            .padding(8)
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Zamowienie")
        let zam = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Zamowienie
        
        PaymentView(zamowienie: zam).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
