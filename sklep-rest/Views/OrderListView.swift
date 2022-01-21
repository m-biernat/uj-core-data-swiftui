//
//  OrderListView.swift
//  sklep-rest
//
//  Created by user209006 on 1/21/22.
//

import SwiftUI

struct OrderListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Zamowienie.date, ascending: false)],
        animation: .default)
    
    private var zamowienia: FetchedResults<Zamowienie>
    
    var body: some View {
        VStack(spacing: 0) {
            if (zamowienia.count > 0) {
                List(zamowienia) { zamowienie in
                    NavigationLink(destination: OrderDetailView(zamowienie: zamowienie)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(zamowienie.server_id!)
                                    .lineLimit(1)
                                    .font(.caption)
                                Spacer()
                                let date = FormatDate.toString(zamowienie.date!)
                                Text(date)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack() {
                                let price = String(zamowienie.price)
                                Text(price)
                                    .font(.caption)
                                Text("PLN")
                                    .font(.caption2)
                            }
                            .frame(width: 60)
                        }
                        .padding(.vertical, 8)
                    }
                    .navigationBarTitle("Zamówienia (\(zamowienia.count))", displayMode: .inline)
                }
            }
            else {
                Spacer()
                Text("Brak zamówień")
                    .foregroundColor(Color.gray)
                Spacer()
            }
        }
    }
}

struct OrderListView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
