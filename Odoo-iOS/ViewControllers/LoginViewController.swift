//
//  LoginViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 1.06.2023.
//

import UIKit
import DropDown

class LoginViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    let dropDown = DropDown()
    @IBOutlet weak var changeUserView: UIView!
    @IBOutlet weak var changeUserButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
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
        configureChangeUserButton()
        updateLoginButtonState()
        
        URLTextView.delegate = self
        databaseTextView.delegate = self
        usernameTextView.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureChangeUserDropdownMenu()
        setScreenForLastlyLoggedUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passwordTextField.text = ""
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
    
    private func configureChangeUserButton() {
        changeUserButton.setTitle("", for: .normal)
        changeUserButton.addTarget(self, action: #selector(changeUserButtonTapped), for: .touchUpInside)
        profileImageView.layer.cornerRadius = 10
    }
    
    @objc private func changeUserButtonTapped() {
        dropDown.show()
    }
    
    func setScreenForLastlyLoggedUser() {
        if let lastLoggedUser = LoggedUsersManager.shared.getLastlyLoggedUser() {
            URLTextView.text = lastLoggedUser.URL.absoluteString
            databaseTextView.text = lastLoggedUser.database
            usernameTextView.text = lastLoggedUser.username
            if let imageData = Data(base64Encoded: lastLoggedUser.profileImageData),
               let image = UIImage(data: imageData) {
                profileImageView.image = image
            } else {
                profileImageView.image = UIImage(systemName: "person.crop.circle")
            }
        } else {
            print("No logged-in users")
        }
    }

    private func configureChangeUserDropdownMenu() {
        let loggedUsers = LoggedUsersManager.shared.getLoggedUsers()
        let dropdownItems = loggedUsers.map { $0.userName.split(separator: " ").first?.description ?? "" }

        dropDown.anchorView = changeUserView
        dropDown.dataSource = dropdownItems

        dropDown.cellNib = UINib(nibName: "ChangeProfileCell", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? ChangeProfileCell else { return }

            // Setup your custom UI components
            let loggedUser = loggedUsers[index]
            cell.profileImage.image = UIImage(data: Data(base64Encoded: loggedUser.profileImageData) ?? Data())
        }

        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            // Update the login page with the selected user's information
            let selectedUser = loggedUsers[index]
            self?.URLTextView.text = selectedUser.URL.absoluteString
            self?.databaseTextView.text = selectedUser.database
            self?.usernameTextView.text = selectedUser.username
            if let imageData = Data(base64Encoded: selectedUser.profileImageData),
               let image = UIImage(data: imageData) {
                self?.profileImageView.image = image
            } else {
                self?.profileImageView.image = UIImage(systemName: "person.crop.circle")
            }
            self?.passwordTextField.text = ""
            self?.updateLoginButtonState()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
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

                            let userID = userID
                            NetworkManager.shared.getLoggedUserDetails(userID: userID) { userDetails in
                                if let userDetails = userDetails {
                                    LoggedUsersManager.shared.addLoggedUser(user: LoggedUser(id: userDetails.userID, username: self.usernameTextView.text, URL: url, database: self.databaseTextView.text, userName: userDetails.userName, profileImageData: userDetails.imageData, lastLoginDate: Date()))
                                    print(LoggedUsersManager.shared.getLoggedUsers())
                                } else {
                                    print("Failed to fetch user details")
                                }
                            }
                        }
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    let alert = UIAlertController(title: NSLocalizedString("loginFailed", comment: ""), message: NSLocalizedString("tryAgain", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    print("Login failed.")
                }
            }
        } else {
            print("Invalid URL")
        }
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateLoginButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateLoginButtonState()
    }
}

extension LoginViewController {
    @IBAction func URLClearButtonTapped(_ sender: Any) {
        URLTextView.text = ""
        updateLoginButtonState()
    }
    
    @IBAction func databaseClearButtonTapped(_ sender: Any) {
        databaseTextView.text = ""
        updateLoginButtonState()
    }
    
    @IBAction func usernameClearButtonTapped(_ sender: Any) {
        usernameTextView.text = ""
        updateLoginButtonState()
    }
    
    @IBAction func passwordClearButtonTapped(_ sender: Any) {
        passwordTextField.text = ""
        updateLoginButtonState()
    }
    
    private func updateLoginButtonState() {
        let isURLEmpty = URLTextView.text.isEmpty
        let isDatabaseEmpty = databaseTextView.text.isEmpty
        let isUsernameEmpty = usernameTextView.text.isEmpty
        let isPasswordEmpty = passwordTextField.text?.isEmpty ?? true
        
        loginButton.isEnabled = !(isURLEmpty || isDatabaseEmpty || isUsernameEmpty || isPasswordEmpty)
    }
}
