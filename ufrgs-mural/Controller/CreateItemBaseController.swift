//
//  CreateItemBaseController.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import SwiftOverlays
import UIKit

class CreateItemBaseController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var viewCenterYConstraint: NSLayoutConstraint!
    
    var item = Item()
    var centerYConstraint: CGFloat?
    let repository = ItemRepository()
    
    weak var delegate: DidCreateItemProtocol?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        self.navigationController?.hero.isEnabled = true
        self.hintLabel.text = "Digite o número\nde patrimônio do bem"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.textField.becomeFirstResponder()
        self.addKeyboardObservers()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardObservers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createItemBaseToInfo" {
            let vc = segue.destination as! CreateItemInfoController
            vc.item = self.item
            
            vc.dismissDelegate = self
            vc.didCreateItemDelegate = self.delegate
        } else if segue.identifier == "createItemBaseToEdit" {
            let vc = segue.destination as! EditItemController
            vc.item = self.item
            
//            vc.item = self.item
//
//            vc.dismissDelegate = self
//            vc.didCreateItemDelegate = self.delegate
        }
    }
    
    // MARK: - Actions
    
    @IBAction func checkAction(_ sender: Any) {
        if textField.text == "" {
            let alert = Helper.createSimpleAlert(title: "Campo faltando", message: "Preencha o campo de texto e tente novamente.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.startWaiting()
        
        // pega os dados do PATRIMONIO
        repository.read(id: textField.text!) { (item, message) in
            
            self.stopWaiting()
            
            if let i = item {
                self.item = i
                
                // se o item já foi registrado
                if i.nrSeq != nil {
                    self.askIfUserWantsToEditItem {
                        // pega os dados do item no MURAL
                        self.showWaitOverlay()
                        
                        self.repository.getItemInfo(nrSeq: i.nrSeq!, completion: { (item) in
                            self.removeAllOverlays()
                            
                            if let i = item {
                                self.item = i
                                self.performSegue(withIdentifier: "createItemBaseToEdit", sender: self)
                            }
                        })
                    }
                } else {
                    self.performSegue(withIdentifier: "createItemBaseToInfo", sender: self)
                }
                
                self.button.isUserInteractionEnabled = true
                
            } else {
                let alert = UIAlertController(title: "Bem não encontrado", message: message, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        self.textField.becomeFirstResponder()
                    }
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Waiting feedback methods
    
    func startWaiting() {
        self.button.isUserInteractionEnabled = false
        self.view.endEditing(true)
        self.showWaitOverlay()
    }
    
    func stopWaiting() {
        self.button.isUserInteractionEnabled = true
        self.removeAllOverlays()
    }
    
    // MARK: - Auxiliar functions
    
    private func askIfUserWantsToEditItem(yesCompletion: @escaping ()->()) {
        
        let alert = UIAlertController(title: "Bem já existe", message: "Este bem já foi cadastrado no mural. Deseja editá-lo?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Sim", style: .default) { _ in
            yesCompletion()
        }
        
        let no = UIAlertAction(title: "Não", style: .cancel, handler: nil)
        
        alert.addAction(yes)
        alert.addAction(no)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertErrorLoadingItem() {
        let alert = Helper.createSimpleAlert(title: "Erro", message: "Ocorreu um erro ao obter os dados do bem.")
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Keyboard methods

extension CreateItemBaseController {
    
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
        
        if centerYConstraint == nil {
            centerYConstraint = calculateCenterYConstraint(notification: notification)
        }
        
        if let y = centerYConstraint {
            animateCenterYConstraint(value: -y)
            return
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        animateCenterYConstraint(value: 0.0)
    }
    
    func animateCenterYConstraint(value: CGFloat) {
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.0) {
            self.viewCenterYConstraint.constant = value
            self.view.layoutIfNeeded()
        }
    }
    
    func calculateCenterYConstraint(notification: Notification) -> CGFloat? {
        let originalFrame = self.view.frame
        if let buttonFrame = button.superview?.convert(button.frame, to: self.view) {
            let currentBottomDistance = originalFrame.height - (buttonFrame.origin.y + buttonFrame.height)
            
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let newCenterValue = CGFloat(keyboardHeight) - currentBottomDistance
            
            return newCenterValue
        }
        return nil
    }
}


// MARK: - Create item base protocol

protocol CreateItemBaseProtocol: class {
    func dismiss()
}

extension CreateItemBaseController: CreateItemBaseProtocol {

    func dismiss() {
        self.textField.text = ""
        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.tabBarController?.selectedIndex = 1
        NotificationCenter.default.post(name: CustomNotification.myItemsMustRefresh, object: nil)
        NotificationCenter.default.post(name: CustomNotification.muralMustRefresh, object: nil)
    }
    
}
