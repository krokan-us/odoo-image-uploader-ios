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
    var imageResponse: ImageResponse? // Store the image response
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(productBarcode)
        
        NetworkManager.shared.fetchImages(productBarcode: productBarcode ?? "0") { imageResponse in
            if let imageResponse = imageResponse {
                self.imageResponse = imageResponse
                self.productNameLabel.text = imageResponse.productName
                // Reload the collection view to display the images
                DispatchQueue.main.async {
                    self.productImagesCollectionView.reloadData()
                }
            } else {
                print("Failed to fetch images.")
            }
        }
        
        // Register the cell
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        productImagesCollectionView.register(nib, forCellWithReuseIdentifier: "imageCell")
        
        // Set the collection view's data source and delegate
        productImagesCollectionView.dataSource = self
        productImagesCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.setTitle("", for: .normal)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension DisplayImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageResponse?.productImages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
        if let productImages = imageResponse?.productImages {
            // Sort the productImages array based on the sequence values
            var sortedImages = productImages.sorted { $0.sequence < $1.sequence }
            
            if indexPath.item < sortedImages.count {
                // Update the sequence value based on the new order
                sortedImages[indexPath.item].sequence = indexPath.item + 1
                
                cell.configure(with: sortedImages[indexPath.item])
            }
        }
        return cell
    }
}


extension DisplayImagesViewController: UICollectionViewDelegate {
    // Implement any necessary delegate methods, such as handling item selection
}
