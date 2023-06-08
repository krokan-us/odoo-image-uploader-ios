//
//  ChangeProfileCell.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 8.06.2023.
//

import UIKit
import DropDown

class ChangeProfileCell: DropDownCell {

    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 10
    } 
}
