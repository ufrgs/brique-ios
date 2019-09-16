//
//  LoginViewController.swift
//  ufrgs-alerta
//
//  Created by Augusto on 01/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import UIKit
import SwiftOverlays

class LoginController: UIViewController {

    // MARK: - Properties
    
    let api = LoginUfrgsApi()
    let cornerRadiusValue: CGFloat = 6.0
    
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var cardTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerViewTopConstraint: NSLayoutConstraint!
    
    let defaultBannerHeight: CGFloat = 150.0
    let defaultBannerTop: CGFloat = 50.0
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        self.view.hero.id = HeroId.loginView
        cardTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.current.isLogged() {
            self.performSegue(withIdentifier: "didLogin", sender: Any?.self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // configure UI
        configureButton()
        configureTextFields()
        configureBanner()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    // MARK: - Login Action
    
    @IBAction func loginAction(_ sender: Any) {
        if !fieldsOk(fields: [cardTextField, passwordTextField]) {
            self.warnFieldsNotOk()
            return
        }
        cardTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        self.showWaitOverlay()
        
        api.authenticate(id: cardTextField.text!, password: passwordTextField.text!) { (token) in
        
            self.removeAllOverlays()
            
            if let t = token {
                self.loginSucceeded(token: t)
            } else {
                self.loginFailed()
            }
        }
    }
    
    // MARK: - Feedback functions
    
    func loginSucceeded(token: String) {
        User.current.save(token: token)
        
//        loginToMyItems
        self.performSegue(withIdentifier: "didLogin", sender: Any?.self)
        
        self.cardTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    func loginFailed() {
        let failAlert = Helper.createSimpleAlert(title: "Atenção!", message: "Identificação e/ou senha incorretos. Corrija suas informações e tente novamente.")
        self.present(failAlert, animated: true, completion: nil)
    }
    
    func warnFieldsNotOk() { }
    
    // MARK: - Auxiliar functions
    
    func fieldsOk(fields: [UITextField]) -> Bool {
        for f in fields {
            if !stringIsValid(s: f.text) { return false }
        }
        return true
    }
    
    func stringIsValid(s: String?) -> Bool {
        return !(s == nil || s == "")
    }
    
    // MARK: - UI Configuration functions
    
    private func configureButton() {
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadiusValue
    }
    
    private func configureTextFields() {
        configureTextField(textField: cardTextField)
        configureTextField(textField: passwordTextField)
        
        textFieldsView.clipsToBounds = true
        textFieldsView.layer.cornerRadius = 8.0
        
        textFieldsView.layer.borderWidth = 1.25
        textFieldsView.layer.borderColor = UIColor(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1.0).cgColor
        
    }
    
    private func configureTextField(textField: UITextField) {

        // configure border and colors
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 1.75
        
    }
    
    private func configureBanner() {
        bannerImage.image = UIImage(named: "login-banner")
    }
    
}

// MARK: UITextField Delegate

extension LoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case cardTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            loginAction(self)
        
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
}

extension LoginController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        animateBannerHeightConstraint(0.0)
        bannerViewTopConstraint.constant = 0.0
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        animateBannerHeightConstraint(defaultBannerHeight)
        bannerViewTopConstraint.constant = defaultBannerTop
    }
    
    func animateBannerHeightConstraint(_ value: CGFloat) {
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.0) {
            self.bannerViewHeightConstraint.constant = value
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - Custom Text Field

class CustomTextField: UITextField {
    
    let xInset: CGFloat = 20.0
    let yInset: CGFloat = 16.0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: xInset, dy: yInset)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: xInset, dy: yInset)
    }
}
