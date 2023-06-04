//
//  DisplayImagesViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 4.06.2023.
//

import UIKit

class DisplayImagesViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImagesCollectionView: UICollectionView!
    var productBarcode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(productBarcode)
        
        NetworkManager.shared.fetchImages(productBarcode: productBarcode ?? "0") { imageResponse in
            if let imageResponse = imageResponse {
                // Process the image response
                print("Status: \(imageResponse.status)")
                print("Message: \(imageResponse.message)")
                print("Product ID: \(imageResponse.productId)")
                print("Product Name: \(imageResponse.productName)")
                print("Product Images:")
                
                for productImage in imageResponse.productImages {
                    print("ID: \(productImage.id)")
                    print("Name: \(productImage.name)")
                    print("Sequence: \(productImage.sequence)")
                    print("Image Data: \(productImage.imageData)")
                    print("Is Published: \(productImage.isPublished)")
                    print("File Name: \(productImage.fileName)")
                    print("---------------------")
                }
            } else {
                print("Failed to fetch images.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.setTitle("", for: .normal)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
