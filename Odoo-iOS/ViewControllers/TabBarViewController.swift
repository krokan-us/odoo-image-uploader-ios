//
//  TabBarViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.items?[0].title = NSLocalizedString("camera", comment: "")
        tabBar.items?[1].title = NSLocalizedString("settings", comment: "")

    }
}
