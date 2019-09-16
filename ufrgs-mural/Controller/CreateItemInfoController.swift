//
//  CreateItemInfoController.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class CreateItemInfoController: UIViewController {
    
    // MARK: - Properties
    
    let rowLabels = ["Nome", "Descrição", "Patrimônio", "Origem"]
    let enabled = [true, true, false, false]
    let repository = ItemRepository()
    
    weak var dismissDelegate: CreateItemBaseProtocol?
    weak var didCreateItemDelegate: DidCreateItemProtocol?
    
    var item = Item()
    var imageToBeCropped: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.title = "Informações do bem"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 10
    }
    
    // MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "createItemInfoToImage" {
//            let vc = segue.destination as! CreateItemImageController
//            vc.dismissDelegate = self.dismissDelegate
//            vc.item = self.item
//        }
        
        if segue.identifier == "showImageResizerModally" {
            let vc = segue.destination as! ImageResizerController
            
            vc.image = self.imageToBeCropped
            vc.delegate = self
        }
    }
    
    // MARK: - Actions
    
    @IBAction func createAction(_ sender: Any) {
        if !Helper.isValid(string: item.name) || !Helper.isValid(string: item.description) {
            let alert = Helper.createSimpleAlert(title: "Campo(s) em branco", message: "Nenhum dos campos pode estar em branco. Preencha-os e tente novamente.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let creationSuccess = {
            self.didCreateItemDelegate?.didCreate(item: self.item)
            
            // se possui imagem, vai tentar salvá-la
            if let image = self.item.image {
                self.trySavingImage(nrSeq: self.item.nrSeq!, image: image, successCompletion: {
                    self.toastAndLeave(message: "Bem adicionado com sucesso.")
                })
                
                // senão, tá tudo pronto
            } else {
                self.toastAndLeave(message: "Bem adicionado com sucesso.")
            }
        }
        
        // se não tiver imagem, pergunta pro usuário se ele quer salvar sem imagem mesmo
        if self.item.image == nil {
            let alert = UIAlertController(title: "Nenhuma foto foi adicionada", message: "A foto ajuda na visualização do bem no mural. Deseja cadastrar o bem sem foto?", preferredStyle: .alert)
            
            let yes = UIAlertAction(title: "Cadastrar", style: .default) { (action) in
                self.tryCreatingItem(successCompletion: creationSuccess)
            }
            
            let no = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            
            alert.addAction(yes)
            alert.addAction(no)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.tryCreatingItem(successCompletion: creationSuccess)
        }
        
    }
    
    func tryCreatingItem(successCompletion: @escaping () -> ()) {
        
        self.startWaiting()
        
        repository.create(item: self.item) { (success, message, nrSeq) in
            
            if success {
                self.stopWaiting()
                self.item.nrSeq = nrSeq
                
                successCompletion()
                
            } else {
                let alert = Helper.createSimpleAlert(title: "Erro", message: message)
                
                self.present(alert, animated: true, completion: {
                    self.stopWaiting()
                })
            }
        }
    }
    
    func trySavingImage(nrSeq: Int, image: UIImage, successCompletion: @escaping () -> ()) {
        
        self.startWaiting()
        
        repository.updateImage(nrSeq: nrSeq, image: image) { (success, message) in
            
            self.stopWaiting()
            
            if success {
                successCompletion()
            }
                
            else {
                let alert = UIAlertController(title: "Erro ao salvar imagem", message: message, preferredStyle: .alert)
                
                let tryAgain = UIAlertAction(title: "Tentar novamente", style: .default) { (_) in
                    self.trySavingImage(nrSeq: nrSeq, image: image, successCompletion: {
                        self.toastAndLeave(message: "Bem adicionado com sucesso.")
                    })
                }
                
                let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (_) in
                    self.toastAndLeave(message: "Bem adicionado com sucesso.")
                })
                
                alert.addAction(cancel)
                alert.addAction(tryAgain)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Waiting feedback methods
    
    func startWaiting() {
        self.tableView.isUserInteractionEnabled = false
        self.view.endEditing(true)
        self.showWaitOverlay()
    }
    
    func stopWaiting() {
        self.tableView.isUserInteractionEnabled = true
        self.removeAllOverlays()
    }
    
    private func toastAndLeave(message: String) {
        Helper.toast(message: message, time: 0.8, view: self.view.superview, completion: {
            self.dismissDelegate?.dismiss()
        })
    }
    
}

// MARK: - Table View data source

extension CreateItemInfoController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowLabels.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CreateItemImageCell", for: indexPath) as! CreateItemImageCell
            
            cell.delegate = self
            cell.imageSelectionView.delegate = self
            cell.setImage(image: item.image)
            
            cell.hero.modifiers = [.fade, .scale(0.75)]
            
            return cell
        
        } else if indexPath.row > 0 && indexPath.row <= rowLabels.count {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CreateItemFieldCell", for: indexPath) as! CreateItemFieldCell
            
            cell.titleLabel.text = rowLabels[indexPath.row - 1]
            cell.configure(enabled: enabled[indexPath.row - 1], lineIsVisible: (indexPath.row < 4))
            
            switch indexPath.row {
            case 1:
                cell.contentLabel.text = item.name
                
            case 2:
                cell.contentLabel.text = item.description
                
            case 3:
                cell.contentLabel.text = item.number
                
            case 4:
                if let o = item.sourceOrgao {
                    cell.contentLabel.text = o.name
                } else {
                    cell.contentLabel.text = ""
                }
                
            default:
                break
            }
            
            cell.hero.modifiers = [.fade, .scale(0.3)]
            
            return cell
        }
        
        else if indexPath.row == rowLabels.count + 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CreateItemButtonCell", for: indexPath) as! CreateItemButtonCell
            return cell
        }
        
        else {
            return UITableViewCell()
        }
    }
    
}

// MARK: - Table View delegate

extension CreateItemInfoController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        switch index {
        case 1:
            editField(title: "nome", defaultText: self.item.name) { (text) in
                if let t = text {
                    self.item.name = t
                    self.tableView.reloadData()
                }
            }
            
        case 2:
            editField(title: "descrição", defaultText: self.item.description) { (text) in
                if let t = text {
                    self.item.description = t
                    self.tableView.reloadData()
                }
            }
            
        default:
            break
        }
    }
    
    func editField(title: String, defaultText: String?, completion: @escaping (String?) -> ()) {
        let alert = UIAlertController(title: "Editar \(title)", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = defaultText
        }
        
        let ok = UIAlertAction(title: "Salvar", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                completion(textField.text)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - PickImageProtocol

extension CreateItemInfoController: PickImageProtocol {
    
    func pickImage() {
        
        askImageSource { (image) in
            
            if let img = image {
                self.imageToBeCropped = img
                
                // if image is squared
                if img.size.width == img.size.height {
                    self.didCrop(image: img)
                } else {
                    self.performSegue(withIdentifier: "showImageResizerModally", sender: self)
                }
            }
            
        }
        
    }
    
    private func askImageSource(completion: @escaping (UIImage?) -> ()) {
        let alert = UIAlertController(title: "Escolher imagem", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Câmera", style: .default) { (action) in
            self.showImagePicker(sourceType: .camera, completion: completion)
        })
        
        alert.addAction(UIAlertAction(title: "Fototeca", style: .default) { (action) in
            self.showImagePicker(sourceType: .photoLibrary, completion: completion)
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension CreateItemInfoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType, completion: @escaping (UIImage?) -> ()) {
        
        let imagePicker = CustomImagePickerController()
        
        imagePicker.configure(type: sourceType)
        imagePicker.delegate = self
        imagePicker.completionHandler = completion
        
        DispatchQueue.main.async {
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let completion = (picker as! CustomImagePickerController).completionHandler {
                dismiss(animated: true, completion: nil)
                completion(pickedImage)
                return
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - CropImageProtocol

extension CreateItemInfoController: CropImageProtocol {
    
    func didCrop(image: UIImage) {
        self.item.image = image
        self.tableView.reloadData()
    }
    
}
