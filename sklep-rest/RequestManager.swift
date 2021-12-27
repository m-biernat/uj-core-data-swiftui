//
//  RequestManager.swift
//  sklep-rest
//
//  Created by user209006 on 12/27/21.
//

import CoreData

struct RequestManager {
    
    struct KoszykDataModel: Codable {
        let client_id: String
        let quantity: Int
        let produkt_id: Produkt
        let id: String
    }
    struct PostKoszykDataModel: Codable {
        let client_id: String
        let quantity: Int
        let produkt_id: Produkt
    }
    
    struct Produkt: Codable {
        let id: String
    }
    
    static func sendDataRequest<T: Codable>(data: T,
                                            method: String = "POST",
                                            postfix: String = "",
                                            completion: @escaping (KoszykDataModel) -> Void) {
        let jsonData = try? JSONEncoder().encode(data)
        
        let url = URL(string: sklep_appData.url + "/koszyk/" + postfix)
       
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let incomingData = try JSONDecoder().decode(KoszykDataModel.self, from: data!)
                completion(incomingData)
                
            } catch {
                print("Koszyk - Problem z wyslaniem danych")
                return
            }
        })
        task.resume()
    }
    
    static func removeDataRequest(postfix: String, completion: @escaping () -> Void) {
        let url = URL(string: sklep_appData.url + "/koszyk/" + postfix)
       
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("HTTP request failed")
                return
            }
            
            completion()
        })
        task.resume()
    }
}
