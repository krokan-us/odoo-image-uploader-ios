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
    
    var isSelectedButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelectedButton.setTitle("", for: .normal)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        isSelectedButton.layer.cornerRadius = 10
        
        isSelectedButton.addTarget(self, action: #selector(isSelectedButtonAction), for: .touchUpInside)
    }
    
    func configure(with image: ProductImage) {
        if image.isPublished {
            isSelectedButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            isSelectedButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        
        if let imageData = Data(base64Encoded: image.imageData) {
            photoImageView.image = UIImage(data: imageData)
        } else {
            // Fail report will be sent here.
            photoImageView.image = UIImage(named: "corruptedImage")
        }
        isSelectedButton.isHidden = false
    }
    
    @objc private func isSelectedButtonAction() {
        isSelectedButtonTapped?()
    }
}
