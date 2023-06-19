//
//  NetworkSettingsViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 19.06.2023.
//

import UIKit

class NetworkSettingsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var URLView: UIView!
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var URLTextView: UITextView!
    @IBOutlet weak var URLClearButton: UIButton!
    
    @IBOutlet weak var databaseView: UIView!
    @IBOutlet weak var databaseLabel: UILabel!
    @IBOutlet weak var databaseTextView: UITextView!
    @IBOutlet weak var databaseClearButton: UIButton!

    @IBOutlet weak var dismissButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewBackgrounds()
        setScreenForLastlyLoggedUser()
        configureLabels()
        configureTextViews()
        configureButtons()
        configureTapGesture()
        updateViewBorderColor()

        URLTextView.delegate = self
        databaseTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        URLTextView.text = UserDefaults.standard.string(forKey: "URLTextViewValue")
        databaseTextView.text = UserDefaults.standard.string(forKey: "DatabaseTextViewValue")
        updateViewBorderColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveURLToUserDefaults()
        saveDatabaseToUserDefaults()
    }
    
    @IBAction func URLClearButtonTapped(_ sender: Any) {
        URLTextView.text = ""
        updateViewBorderColor()
    }
    
    @IBAction func databaseClearButtonTapped(_ sender: Any) {
        databaseTextView.text = ""
        updateViewBorderColor()
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    private func setViewBackgrounds(){
        updateViewBorderColor()
        URLView.layer.borderWidth = 1
        databaseView.layer.borderWidth = 1
        URLView.layer.cornerRadius = 10
        databaseView.layer.cornerRadius = 10
    }
    
    private func updateViewBorderColor() {
        URLView.layer.borderColor = isURLTextViewEmpty() ? UIColor.red.cgColor : UIColor.label.cgColor
        databaseView.layer.borderColor = isDatabaseTextViewEmpty() ? UIColor.red.cgColor : UIColor.label.cgColor
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func isURLTextViewEmpty() -> Bool {
        return URLTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func isDatabaseTextViewEmpty() -> Bool {
        return databaseTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func setScreenForLastlyLoggedUser() {
        if let lastLoggedUser = LoggedUsersManager.shared.getLastlyLoggedUser() {
            URLTextView.text = lastLoggedUser.URL.absoluteString
            databaseTextView.text = lastLoggedUser.database
        } else {
            print("No logged-in users")
        }
        updateViewBorderColor()
    }
    
    private func configureLabels(){
        databaseLabel.text = NSLocalizedString("database", comment: "")
    }
    
    private func configureTextViews() {
        URLTextView.isScrollEnabled = false
        URLTextView.textContainer.lineBreakMode = .byTruncatingTail
        URLTextView.textContainer.maximumNumberOfLines = 1
        
        databaseTextView.isScrollEnabled = false
        databaseTextView.textContainer.lineBreakMode = .byTruncatingTail
        databaseTextView.textContainer.maximumNumberOfLines = 1
    }
    
    private func configureButtons(){
        dismissButton.setTitle("", for: .normal)
        URLClearButton.setTitle("", for: .normal)
        databaseClearButton.setTitle("", for: .normal)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateViewBorderColor()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == URLTextView {
            saveURLToUserDefaults()
        } else if textView == databaseTextView {
            saveDatabaseToUserDefaults()
        }
        updateViewBorderColor()
    }
    
    private func saveURLToUserDefaults() {
        UserDefaults.standard.set(URLTextView.text, forKey: "URLTextViewValue")
    }
    
    private func saveDatabaseToUserDefaults() {
        UserDefaults.standard.set(databaseTextView.text, forKey: "DatabaseTextViewValue")
    }
}
