//
//  RequestManager.swift
//  sklep-rest
//
//  Created by user209006 on 12/27/21.
//

import CoreData

struct RequestManager {
    static func sendDataRequest<T1: Codable, T2: Codable>(data: T1,
                                                            method: String = "POST",
                                                            postfix: String = "",
                                                            completion: @escaping (T2) -> Void) {
        let jsonData = try? JSONEncoder().encode(data)
        
        let url = URL(string: sklep_appData.url + postfix)
       
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
                let incomingData = try JSONDecoder().decode(T2.self, from: data!)
                completion(incomingData)
                
            } catch {
                print("Problem z wyslaniem danych \(postfix)")
                return
            }
        })
        task.resume()
    }
    
    static func removeDataRequest(postfix: String, completion: @escaping () -> Void) {
        let url = URL(string: sklep_appData.url + postfix)
       
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
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
