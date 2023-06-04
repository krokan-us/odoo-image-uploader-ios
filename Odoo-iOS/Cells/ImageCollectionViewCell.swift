//
//  ImageCollectionViewCell.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 4.06.2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var isSelectedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelectedButton.setTitle("", for: .normal)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
    }
    
    func configure(with image: ProductImage) {
        if image.isPublished {
            isSelectedButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            isSelectedButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        
        if let imageData = Data(base64Encoded: image.imageData) {
            print("Successfully loaded image data for image ID: \(image.id)")
            photoImageView.image = UIImage(data: imageData)
        } else {
            //Fail report will be sent here.
            print("Failed to load image data for image ID: \(image.id)")
            photoImageView.image = UIImage(named: "corruptedImage")
            isSelectedButton.isHidden = true
        }
    }
}
