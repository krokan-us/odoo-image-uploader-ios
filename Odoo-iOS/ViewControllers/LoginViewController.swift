//
//  LoginViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var URLTextView: UITextView!
    @IBOutlet weak var databaseTextView: UITextView!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var passwordTextView: UITextView!
    
    @IBOutlet weak var URLClearButton: UIButton!
    @IBOutlet weak var databaseClearButton: UIButton!
    @IBOutlet weak var usernameClearButton: UIButton!
    @IBOutlet weak var passwordClearButton: UIButton!
    private var isUserAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextViews()
        configureButtons()
    }
    
    private func configureTextViews() {
        URLTextView.isScrollEnabled = false
        databaseTextView.isScrollEnabled = false
        usernameTextView.isScrollEnabled = false
        passwordTextView.isScrollEnabled = false
        
        URLTextView.textContainer.lineBreakMode = .byTruncatingTail
        databaseTextView.textContainer.lineBreakMode = .byTruncatingTail
        usernameTextView.textContainer.lineBreakMode = .byTruncatingTail
        passwordTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        URLTextView.textContainer.maximumNumberOfLines = 1
        databaseTextView.textContainer.maximumNumberOfLines = 1
        usernameTextView.textContainer.maximumNumberOfLines = 1
        passwordTextView.textContainer.maximumNumberOfLines = 1
    }
    
    private func configureButtons(){
        URLClearButton.setTitle("", for: .normal)
        databaseClearButton.setTitle("", for: .normal)
        usernameClearButton.setTitle("", for: .normal)
        passwordClearButton.setTitle("", for: .normal)

    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let urlText = URLTextView.text, let url = URL(string: urlText) {
            NetworkManager.shared.sendLoginRequest(baseURL: url, databaseName: databaseTextView.text, username: usernameTextView.text, password: passwordTextView.text) {
                userID in
                if let userID = userID {
                    print("Login successful! User ID: \(userID)")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBar") as? TabBarViewController {
                        tabBarVC.modalPresentationStyle = .fullScreen
                        DispatchQueue.main.async {
                            self.present(tabBarVC, animated: false)
                        }
                    }
                } else {
                    print("Login failed.")
                }
            }
        } else {
            // Handle invalid URL text
            print("Invalid URL")
        }
    }
    }
extension LoginViewController {
    @IBAction func URLClearButtonTapped(_ sender: Any) {
        URLTextView.text = ""
    }
    
    @IBAction func databaseClearButtonTapped(_ sender: Any) {
        databaseTextView.text = ""
    }
    
    @IBAction func usernameClearButtonTapped(_ sender: Any) {
        usernameTextView.text = ""
    }
    
    @IBAction func passwordClearButtonTapped(_ sender: Any) {
        passwordTextView.text = ""
    }
}

