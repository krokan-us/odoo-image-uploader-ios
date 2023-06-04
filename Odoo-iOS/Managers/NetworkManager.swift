//
//  NetworkManager.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import Foundation
import Alamofire

struct ProductImage {
    let id: Int
    var name: String
    var sequence: Int
    var imageData: String
    var isPublished: Bool
    var fileName: String
}

struct ImageResponse {
    let status: String
    let message: String
    let productId: Int
    let productName: String
    var productImages: [ProductImage]
}

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
                        if result != 0 {
                            UserDefaults.standard.set(baseURL, forKey: "currentBaseURL")
                            UserDefaults.standard.set(databaseName, forKey: "currentDatabaseName")
                            UserDefaults.standard.set(result, forKey: "currentlyLoggedUserId")
                            UserDefaults.standard.set(password, forKey: "currentlyLoggedUserPassword")
                            completion(result)
                        } else {
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
    
    func fetchImages(productBarcode: String, completion: @escaping (ImageResponse?) -> Void) {
        guard let currentBaseURL = UserDefaults.standard.url(forKey: "currentBaseURL"),
              let currentDatabaseName = UserDefaults.standard.string(forKey: "currentDatabaseName"),
              let currentlyLoggedUserId = UserDefaults.standard.object(forKey: "currentlyLoggedUserId") as? Int,
              let currentlyLoggedUserPassword = UserDefaults.standard.string(forKey: "currentlyLoggedUserPassword") else {
            print("Missing required user defaults")
            completion(nil)
            return
        }
        
        let requestURL = currentBaseURL.appendingPathComponent("jsonrpc")
        
        let randomID = Int.random(in: 0...1000) // Generate random ID between 0 and 1000
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "context": ["lang": "tr_TR"],
                "service": "object",
                "method": "execute",
                "args": [
                    currentDatabaseName,
                    currentlyLoggedUserId,
                    currentlyLoggedUserPassword,
                    "product.product",
                    "get_variant_images_endpoint",
                    0,
                    [
                        "product_barcode": productBarcode
                    ]
                ]
            ],
            "id": randomID
        ]
        
        AF.request(requestURL, method: .post, parameters: payload, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let status = result["status"] as? String,
                       let message = result["message"] as? String,
                       let productId = result["product_id"] as? Int,
                       let productName = result["product_name"] as? String,
                       let productImages = result["product_images"] as? [[String: Any]] {
                        
                        var images: [ProductImage] = []
                        
                        for image in productImages {
                            if let id = image["id"] as? Int,
                                let name = image["name"] as? String,
                                let sequence = image["sequence"] as? Int,
                                let imageData = image["image_data"] as? String,
                                let isPublished = image["is_published"] as? Bool,
                                var fileName = image["filename"] {
                                
                                if let fileNameString = fileName as? String {
                                    // Handle string value
                                    if fileNameString == "false" {
                                        // Create slugged filename from name by removing whitespaces
                                        fileName = name.replacingOccurrences(of: " ", with: "-")
                                    }
                                } else if fileName is Bool && !(fileName as! Bool) {
                                    // Handle boolean value (false)
                                    // Create slugged filename from name by removing whitespaces
                                    fileName = name.replacingOccurrences(of: " ", with: "-")
                                }
                                
                                let productImage = ProductImage(id: id, name: name, sequence: sequence, imageData: imageData, isPublished: isPublished, fileName: fileName as! String)
                                images.append(productImage)
                            }
                        }

                        let imageResponse = ImageResponse(status: status,
                                                          message: message,
                                                          productId: productId,
                                                          productName: productName,
                                                          productImages: images)
                        completion(imageResponse)
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
