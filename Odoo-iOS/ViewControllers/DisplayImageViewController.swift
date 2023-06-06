//
//  DisplayImageViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 5.06.2023.
//

import UIKit
import CropViewController

class DisplayImageViewController: UIViewController, CropViewControllerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var editImageNameButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var modifyImageButton: UIButton!
    @IBOutlet weak var isPublishedButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var imageToBeDisplayed: ProductImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageDetails()

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backButtonTapped(_:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupButtons()
    }
    
    private func setupButtons(){
        backButton.setTitle("", for: .normal)
        editImageNameButton.setTitle("", for: .normal)
        modifyImageButton.setTitle("", for: .normal)
        isPublishedButton.setTitle("", for: .normal)
        deleteButton.setTitle("", for: .normal)
        imageImageView.layer.borderWidth = 3
        imageImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupImageDetails() {
        if let imageToBeDisplayed = imageToBeDisplayed {
            imageNameLabel.text = imageToBeDisplayed.name
            imageImageView.image = UIImage(data: Data(base64Encoded: imageToBeDisplayed.imageData)!) // assuming that imageData is base64 encoded
            
            let imageName = imageToBeDisplayed.isPublished ? "eye" : "eye.slash"
            isPublishedButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    @IBAction func editImageNameButtonTapped(_ sender: Any) {
        // code to handle editing the image name
    }
    
    @IBAction func modifyImageButtonTapped(_ sender: Any) {
        guard let imageToBeDisplayed = imageToBeDisplayed else { return }
        let cropViewController = CropViewController(image: UIImage(data: Data(base64Encoded: imageToBeDisplayed.imageData)!)!)
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.cropView.cropBoxResizeEnabled = false
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    @IBAction func isPublishedButtonTapped(_ sender: Any) {
        imageToBeDisplayed?.isPublished.toggle()
        
        // update the image on the button based on the isPublished status
        if let isPublished = imageToBeDisplayed?.isPublished {
            let imageName = isPublished ? "eye" : "eye.slash"
            isPublishedButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        // assuming modifyImage(image:completion:) is also a method in this class
        if let imageToBeDisplayed = imageToBeDisplayed {
            NetworkManager.shared.modifyImage(image: imageToBeDisplayed) { success, message in
                if !success {
                    print("Failed to update image status on server: \(message ?? "")")
                    // if updating the status on the server failed, revert the isPublished status and the button image
                    DispatchQueue.main.async {
                        self.imageToBeDisplayed?.isPublished.toggle()
                        let imageName = self.imageToBeDisplayed?.isPublished == true ? "eye" : "eye.slash"
                        self.isPublishedButton.setImage(UIImage(systemName: imageName), for: .normal)
                    }
                }
            }
        }
    }
    
    @IBAction func removeImageButtonTapped(_ sender: Any) {
        guard let imageToBeRemoved = imageToBeDisplayed else { return }
        
        let alertController = UIAlertController(title: NSLocalizedString("confirm", comment: ""), message: NSLocalizedString("confirmationMessage", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("remove", comment: ""), style: .destructive) { _ in
            NetworkManager.shared.removeImage(imageID: imageToBeRemoved.id) { success, message in
                if success {
                    print("Successfully removed image.")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                } else {
                    print("Failed to remove image: \(message ?? "No error message provided.")")
                }
            }
        })
        self.present(alertController, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        guard var imageToBeDisplayed = imageToBeDisplayed else { return }
        
        // Convert the cropped image to base64 and update the imageToBeDisplayed
        let imageData = image.pngData()!.base64EncodedString()
        imageToBeDisplayed.imageData = imageData
        
        NetworkManager.shared.modifyImage(image: imageToBeDisplayed) { (success, errorMessage) in
            if success {
                print("Successfully modified image.")
                DispatchQueue.main.async {
                    self.imageImageView.image = image
                }
            } else {
                print("Failed to modify image: \(errorMessage ?? "No error message provided.")")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
