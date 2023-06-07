//
//  LoginViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var URLView: UIView!
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var URLTextView: UITextView!
    @IBOutlet weak var URLClearButton: UIButton!
    
    @IBOutlet weak var databaseView: UIView!
    @IBOutlet weak var databaseLabel: UILabel!
    @IBOutlet weak var databaseTextView: UITextView!
    @IBOutlet weak var databaseClearButton: UIButton!
    
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var usernameClearButton: UIButton!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordClearButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var isUserAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewBackgrounds()
        configureLabels()
        configureTextViews()
        configureButtons()
        configureTapGesture()
    }
    
    private func setViewBackgrounds(){
        URLView.layer.borderWidth = 1
        URLView.layer.borderColor = UIColor.label.cgColor
        URLView.layer.cornerRadius = 10
        
        databaseView.layer.borderWidth = 1
        databaseView.layer.borderColor = UIColor.label.cgColor
        databaseView.layer.cornerRadius = 10
        
        usernameView.layer.borderWidth = 1
        usernameView.layer.borderColor = UIColor.label.cgColor
        usernameView.layer.cornerRadius = 10
        
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor.label.cgColor
        passwordView.layer.cornerRadius = 10
    }
    
    private func configureLabels(){
        welcomeLabel.text = NSLocalizedString("welcome", comment: "")
        databaseLabel.text = NSLocalizedString("database", comment: "")
        usernameLabel.text = NSLocalizedString("username", comment: "")
        passwordLabel.text = NSLocalizedString("password", comment: "")
    }

    private func configureTextViews() {
        URLTextView.isScrollEnabled = false
        URLTextView.textContainer.lineBreakMode = .byTruncatingTail
        URLTextView.textContainer.maximumNumberOfLines = 1
        
        databaseTextView.isScrollEnabled = false
        databaseTextView.textContainer.lineBreakMode = .byTruncatingTail
        databaseTextView.textContainer.maximumNumberOfLines = 1
        
        usernameTextView.isScrollEnabled = false
        usernameTextView.textContainer.lineBreakMode = .byTruncatingTail
        usernameTextView.textContainer.maximumNumberOfLines = 1
    }
    
    private func configureButtons(){
        URLClearButton.setTitle("", for: .normal)
        databaseClearButton.setTitle("", for: .normal)
        usernameClearButton.setTitle("", for: .normal)
        passwordClearButton.setTitle("", for: .normal)
        
        loginButton.backgroundColor = .red
        loginButton.tintColor = .white
        loginButton.layer.borderColor = UIColor.red.cgColor
        loginButton.layer.cornerRadius = 10
        loginButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let urlText = URLTextView.text, let url = URL(string: urlText) {
            NetworkManager.shared.sendLoginRequest(baseURL: url, databaseName: databaseTextView.text, username: usernameTextView.text, password: passwordTextField.text ?? "") {
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
    
    @objc private func handleTap() {
        view.endEditing(true)
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
        passwordTextField.text = ""
    }
}
