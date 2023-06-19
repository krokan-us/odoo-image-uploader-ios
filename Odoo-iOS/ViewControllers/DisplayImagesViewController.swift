//
//  DisplayImagesViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 4.06.2023.
//

import UIKit
import Lottie

class DisplayImagesViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImagesCollectionView: UICollectionView!
    var productBarcode: String?
    var imageResponse: ImageResponse? // Store the image response
    var animationView = LottieAnimationView(name: "paperplaneLoading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingAnimation()
        
        // Register the cell
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        productImagesCollectionView.register(nib, forCellWithReuseIdentifier: "imageCell")
        
        // Set the collection view's data source and delegate
        productImagesCollectionView.dataSource = self
        productImagesCollectionView.delegate = self
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backButtonTapped(_:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        
        productImagesCollectionView.dragDelegate = self
        productImagesCollectionView.dropDelegate = self
        productImagesCollectionView.dragInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.setTitle("", for: .normal)
        showLoadingAnimation()
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
                    self.hideLoadingAnimation()
                }
            } else {
                print("Failed to fetch images.")
                self.hideLoadingAnimation()
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    // When the drag operation starts, this method creates a drag item for the dragged cell.
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row >= imageResponse?.productImages.count ?? 0 {
            return []
        }
        let item = imageResponse?.productImages[indexPath.row]
        let itemProvider = NSItemProvider(object: "\(item?.id ?? -1)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

    // The drag item gets dropped into the collection view.
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath, indexPath.row < (imageResponse?.productImages.count ?? 0) {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0) - 1 // adjust for extra cell
            destinationIndexPath = IndexPath(item: row, section: 0)
        }

        if coordinator.proposal.operation == .move, let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath,
           sourceIndexPath.item < (imageResponse?.productImages.count ?? 0),
           destinationIndexPath.item < (imageResponse?.productImages.count ?? 0) {
            collectionView.performBatchUpdates({
                if let sourceImage = imageResponse?.productImages.remove(at: sourceIndexPath.item) {
                    imageResponse?.productImages.insert(sourceImage, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
            }, completion: nil)

            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            
            // Update the sequence value of all the images and make API call
            if let productImages = imageResponse?.productImages {
                for (index, productImage) in productImages.enumerated() {
                    var updatedProductImage = productImage
                    updatedProductImage.sequence = index + 1
                    imageResponse?.productImages[index] = updatedProductImage
                    
                    NetworkManager.shared.modifyImage(image: updatedProductImage) { success, error in
                        if success {
                            DispatchQueue.main.async {
                                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                            }
                        } else {
                            print("Failed to update sequence for image id: \(updatedProductImage.id)")
                        }
                    }
                }
            }
        }
    }



    // Provides a destination index path for the drag item, in case we want to reorder the items.
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
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
        
        productImages[index].isPublished.toggle()
        
        NetworkManager.shared.modifyImage(image: productImages[index]) { success, error in
            if success {
                self.getImagesFromAPI()
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("failedToChangeIsPublishedValue", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
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

// Add drag & drop delegate protocols
extension DisplayImagesViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
}

extension DisplayImagesViewController{
    func setupLoadingAnimation() {
        animationView = LottieAnimationView(name: "paperplaneLoading")
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 300),
            animationView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func showLoadingAnimation() {
        animationView.play()
        animationView.isHidden = false
        productImagesCollectionView.isHidden = true
    }
    
    func hideLoadingAnimation() {
        animationView.stop()
        animationView.isHidden = true
        productImagesCollectionView.isHidden = false
    }
}
