//
//  SettingsViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 8.06.2023.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var logoutBackgroundView: UIView!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        setButtons()
        setLabels()
        logoutBackgroundView.layer.cornerRadius = 10
    }
    func setButtons(){
        logoutButton.setTitle("", for: .normal)
    }
    func setLabels(){
        logoutLabel.text = NSLocalizedString("logout", comment: "")
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
