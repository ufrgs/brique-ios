//
//  RequestItemController.swift
//  ufrgs-mural
//
//  Created by Augusto on 07/01/2019.
//  Copyright © 2019 Augusto. All rights reserved.
//

import Foundation
import UIKit

class RequestItemController: UIViewController {
    
    // MARK: - Properties
    
    let requestRepository = ItemRequestRepository()
    
    var nrSeqItem: Int?
    weak var delegate: ItemRequestProtocol?
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        
        self.helpLabel.hero.modifiers = [.fade, .scale(0.5)]
        self.textView.hero.modifiers = [.fade, .scale(0.5), .translate(y: 20.0)]
        
        configureTextView()
        configureNavBar()
        
        textView.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc func confirmRequest(_ sender: Any) {
        let message = textView.text
        
        if let nrSeq = self.nrSeqItem {
            
            if Helper.isValid(string: message) {
                tryRequestingItem(message: message!, nrSeq: nrSeq)
            } else {
                warnMissingMessage()
            }
            
        } else {
            warnMissingNrSeq()
        }
        
    }
    
    private func tryRequestingItem(message: String, nrSeq: Int) {
        
        self.startWaiting()
        
        requestRepository.create(nrSeqItem: nrSeq, message: message) { (success, message) in
            
            self.stopWaiting()
            
            if success {
                self.delegate?.itemWasRequested(nrSeq: nrSeq)
                
                Helper.toast(message: "Solicitação enviada com sucesso", time: 0.8, view: self.view.superview) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.warnErrorRequesting(message: message)
            }
            
        }
        
    }
    
    // MARK: - Alert methods
    
    private func warnMissingMessage() {
        let alert = Helper.createSimpleAlert(title: "Mensagem inválida", message: "Por favor, preencha corretamente o campo da mensagem de solicitação.")
        self.present(alert, animated: true, completion: nil)
    }
    
    private func warnMissingNrSeq() {
        let alert = Helper.createSimpleAlert(title: "Erro", message: "Ocorreu um erro ao obter as informações do item.")
        self.present(alert, animated: true, completion: nil)
    }
    
    private func warnErrorRequesting(message: String) {
        let alert = Helper.createSimpleAlert(title: "Erro", message: message)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Configuration methods
    
    private func configureTextView() {
        textView.clipsToBounds = true
        
        textView.layer.borderWidth = 1.25
        textView.layer.cornerRadius = 6.0
        
        let color = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
        textView.layer.borderColor = color.cgColor
        
        textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        textView.hero.id = HeroId.viewItemImage
    }
    
    private func configureNavBar() {
        self.navigationItem.title = "Solicitação"
        
        let confirmButton = UIBarButtonItem(title: "Confirmar", style: .plain, target: self, action: #selector(confirmRequest(_:)))
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 17) {
            
            confirmButton.setTitleTextAttributes([
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : UIView().tintColor,
                ], for: .normal)
        }
        
        navigationItem.rightBarButtonItem = confirmButton
        
    }
    
    // MARK: - Waiting feedback methods
    
    func startWaiting() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.endEditing(true)
        self.showWaitOverlay()
    }
    
    func stopWaiting() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.removeAllOverlays()
    }
    
}
