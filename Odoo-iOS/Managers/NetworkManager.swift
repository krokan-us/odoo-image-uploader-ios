//
//  NetworkManager.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    func sendLoginRequest(baseURL: URL, databaseName: String, username: String, password: String, completion: @escaping (Int?) -> Void) {
        let requestURL = baseURL.appendingPathComponent("jsonrpc")
        
        let randomID = Int.random(in: 0...1000) // Generate random ID between 0 and 1000
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "service": "common",
                "method": "login",
                "args": [databaseName, username, password]
            ],
            "id": randomID
        ]
        
        AF.request(requestURL, method: .post, parameters: payload, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let result = json["result"] as? Int {
                        if result != 0{
                            completion(result)
                        }else{
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(nil)
                }
            }
    }

}
