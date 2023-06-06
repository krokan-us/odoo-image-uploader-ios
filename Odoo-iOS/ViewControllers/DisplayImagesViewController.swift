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
        getImagesFromAPI()
        
        // Register the cell
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        productImagesCollectionView.register(nib, forCellWithReuseIdentifier: "imageCell")
        
        // Set the collection view's data source and delegate
        productImagesCollectionView.dataSource = self
        productImagesCollectionView.delegate = self
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backButtonTapped(_:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.setTitle("", for: .normal)
        getImagesFromAPI()
    }
    
    func getImagesFromAPI(){
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
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
}

extension DisplayImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (imageResponse?.productImages.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < (imageResponse?.productImages.count ?? 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
            if let productImages = imageResponse?.productImages {
                // Sort the productImages array based on the sequence values
                var sortedImages = productImages.sorted { $0.sequence < $1.sequence }
                
                if indexPath.item < sortedImages.count {
                    // Update the sequence value based on the new order
                    sortedImages[indexPath.item].sequence = indexPath.item + 1
                    
                    cell.configure(with: sortedImages[indexPath.item])
                    
                    // Assign the isSelectedButtonTapped closure
                    cell.isSelectedButtonTapped = { [weak self] in
                        self?.handleIsSelectedButtonTapped(at: indexPath.item)
                    }
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            // Customize the appearance and handle the "addCell" functionality
            cell.photoImageView.image = UIImage(named: "addImage")
            cell.isSelectedButton.isHidden = true
            cell.isUserInteractionEnabled = true
            
            return cell
        }
    }
    
    func handleIsSelectedButtonTapped(at index: Int) {
        guard var productImages = imageResponse?.productImages else { return }
        
        // Toggle the isPublished value of the selected image
        productImages[index].isPublished.toggle()
        
        // Update the image response with the modified product images
        imageResponse?.productImages = productImages
        
        // Reload the collection view to reflect the updated data
        productImagesCollectionView.reloadData()
        
        // TODO: Handle the logic for updating the server with the modified isPublished value
    }
}

extension DisplayImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding: CGFloat = 16.0
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let padding: CGFloat = 16.0
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16.0
        let collectionViewWidth = collectionView.bounds.width
        let availableWidth = collectionViewWidth - (padding * 3) // Account for left padding, right padding, and spacing between cells
        
        let cellWidth = availableWidth / 2.0 // Two cells in each row
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension DisplayImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= (imageResponse?.productImages.count ?? 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addImageVC = storyboard.instantiateViewController(withIdentifier: "addImage") as? AddImageViewController {
                addImageVC.productID = imageResponse?.productId
                addImageVC.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(addImageVC, animated: false)
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let displayImageVC = storyboard.instantiateViewController(withIdentifier: "displayImage") as? DisplayImageViewController {
                if let productImages = imageResponse?.productImages {
                    var sortedImages = productImages.sorted { $0.sequence < $1.sequence }
                    displayImageVC.imageToBeDisplayed = sortedImages[indexPath.item]
                }
                displayImageVC.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(displayImageVC, animated: false)
                }
            }
        }
    }
}
