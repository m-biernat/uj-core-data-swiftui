//
//  RequestData.swift
//  sklep-rest
//
//  Created by user209006 on 1/19/22.
//

import CoreData

struct RequestData {
    struct KoszykModel: Codable {
        let client_id: String
        let quantity: Int
        let produkt_id: Produkt
        let id: String
    }
    
    struct Produkt: Codable {
        let id: String
    }
    
    struct ZamowienieModel: Codable {
        let client_id: String
        let price: Double
        let date: String
        let paid: Bool
        let id: String
    }
    
    struct ZamowienieProduktModel: Codable {
        let produkt_id: String
        let title: String
        let quantity: Int
        let price: Double
        let zamowienie_id: Zamowienie
        let id: String
    }
    
    struct Zamowienie: Codable {
        let id: String
    }
}

struct PostRequestData {
    struct KoszykModel: Codable {
        let client_id: String
        let quantity: Int
        let produkt_id: RequestData.Produkt
    }
    
    struct ZamowienieModel: Codable {
        let client_id: String
        let price: Double
        let date: String
        let paid: Bool
    }
    
    struct ZamowienieProduktModel: Codable {
        let produkt_id: String
        let title: String
        let quantity: Int
        let price: Double
        let zamowienie_id: RequestData.Zamowienie
    }
}
