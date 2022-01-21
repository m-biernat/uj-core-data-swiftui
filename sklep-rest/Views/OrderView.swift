//
//  OrderView.swift
//  sklep-rest
//
//  Created by user209006 on 1/21/22.
//

import SwiftUI
import CoreData

struct OrderView: View {
    var zamowienie: Zamowienie
    
    var body: some View {
        VStack(spacing: 0) {
            Text(zamowienie.server_id!)
                .font(.footnote)
                .bold()
            
            HStack() {
                Text("Data:")
                Spacer()
                let date = FormatDate.toString(zamowienie.date!)
                Text(date)
            }
            .padding()
            
            HStack() {
                Text("Wartość: ")
                Spacer()
                let price = String(zamowienie.price)
                Text("\(price) zł")
            }
            .padding(.horizontal, 16)
        }
        .navigationBarTitle("Szczegóły zamówienia", displayMode: .inline)
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Zamowienie")
        let zam = try! PersistenceController.preview.container.viewContext.fetch(request).first as! Zamowienie
        
        OrderView(zamowienie: zam).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
