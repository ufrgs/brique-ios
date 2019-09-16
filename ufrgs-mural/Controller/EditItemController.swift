//
//  EditItemController.swift
//  ufrgs-alerta
//
//  Created by Augusto on 18/09/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import UIKit
import Hero

class EditItemController: UIViewController {
    
    // MARK: - Properties
    
    var item = Item()
    var editedItem = Item()
    
    weak var delegate: EditItemProtocol?
    
    var didChangeText = false
    var didChangeImage: Bool {
        get { return selectedImage != nil }
    }
    
    var selectedImage: UIImage?
    var imageToBeCropped: UIImage?
    
    let rowLabels = ["Nome", "Descrição", "Patrimônio", "Origem"]
    let enabled = [true, true, false, false]
    let repository = ItemRepository()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        editedItem.name = item.name
        editedItem.description = item.description
        
        configureTableView()
        configureNavBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageResizerModally" {
            let vc = segue.destination as! ImageResizerController
            
            vc.image = self.imageToBeCropped
            vc.delegate = self
        }
    }
    
    // MARK: - Configuration methods
    
    private func configureTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.tableView.hero.id = HeroId.myItemCard
    }
    
    private func configureNavBar() {
        let button = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(saveChanges))
        
        if let color = self.navigationController?.navigationBar.tintColor,
            let font = UIFont(name: "AvenirNext-Regular", size: 17) {
            
            button.setTitleTextAttributes([
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : color,
            ], for: .normal)
            
            button.setTitleTextAttributes([
                NSAttributedStringKey.foregroundColor: UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
            ], for: .disabled)
        }

        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.title = "Edição"
    }
    
    // MARK: - Actions
    
    @objc func deleteItem() {
        let alert = UIAlertController(title: "Tem certeza?", message: "Esta ação não poderá ser desfeita.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Excluir", style: .destructive) { (_) in
            
            if let nrSeq = self.item.nrSeq {
                self.tryDeletingItem(nrSeq: nrSeq)
                return
            }
        }
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func saveChanges() {
        if !Helper.internetIsConnected() {
            let alert = Helper.createNoInternetAlert()
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let nrSeq = self.item.nrSeq {
            self.trySavingChanges(nrSeq: nrSeq)
            return
        }
    }
    
    // MARK: - Repository communication methods
    
    private func tryDeletingItem(nrSeq: Int) {
        
        self.startWaiting()
        
        repository.delete(nrSeq: nrSeq, completion: { (success, message) in
            
            self.stopWaiting()
            
            if success {
                Helper.toast(message: message, time: 0.8, view: self.view.superview, completion: {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didDelete(item: self.item)
                })
            } else {
                let alert = Helper.createSimpleAlert(title: "Erro", message: message)
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
    }
    
    private func trySavingChanges(nrSeq: Int) {
        
        if !Helper.isValid(string: editedItem.name) || !Helper.isValid(string: editedItem.description) {
            let alert = Helper.createSimpleAlert(title: "Campo(s) em branco", message: "Nenhum dos campos pode estar em branco. Preencha-os e tente novamente.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.startWaiting()
        
        if didChangeImage && didChangeText {
            if let img = selectedImage {
                repository.update(nrSeq: item.nrSeq!, item: editedItem, image: img) { (imageSuccess, textSuccess, imageMessage, textMessage) in
                    
                    self.stopWaiting()
                    
                    self.handleUpdateResponse(success: imageSuccess || textSuccess)
                    
                    var alertMessage: String?
                    
                    if imageSuccess && textSuccess {
                        self.selectedImage = nil
                        self.item.image = img
                        
                        self.didChangeText = false
                        self.saveTextEditions()
                        
                        Helper.toast(message: "Atualizações feitas com sucesso.", time: 0.8, view: self.view.superview, completion: nil)
                    }
                        
                    else if imageSuccess {
                        self.selectedImage = nil
                        self.item.image = img
                        
                        alertMessage = textMessage
                    }
                        
                    else if textSuccess {
                        self.didChangeText = false
                        self.saveTextEditions()
                        
                        alertMessage = imageMessage
                    }
                        
                    else {
                        alertMessage = "Erro na atualização do bem."
                    }
                    
                    // se houve algum erro, mostra alerta
                    if let m = alertMessage {
                        let alert = Helper.createSimpleAlert(title: "Erro", message: m)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        
        else if didChangeImage {
            if let img = selectedImage {
                repository.updateImage(nrSeq: item.nrSeq!, image: img) { (success, message) in
                    
                    self.selectedImage = nil
                    self.item.image = img
                    
                    self.handleUpdateResponse(success: success)
                    self.showResult(success: success, message: message)
                }
            }
        }
        
        else if didChangeText {
            repository.update(nrSeq: nrSeq, item: self.editedItem) { (success, message) in
                
                self.didChangeText = false
                self.saveTextEditions()
                
                self.handleUpdateResponse(success: success)
                self.showResult(success: success, message: message)
            }
        }
    }
    
    func handleUpdateResponse(success: Bool) {
        
        self.stopWaiting()
        
        if success {
            
            self.delegate?.didEdit(item: item)
            self.tableView.reloadData()
            
            // notify that changes happened
        }
        
    }
    
    func showResult(success: Bool, message: String) {
        
        if success {
            
            Helper.toast(message: message, time: 0.8, view: self.view.superview, completion: nil)
            
        } else {
            
            let alert = Helper.createSimpleAlert(title: "Erro", message: message)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func saveTextEditions() {
        item.name = editedItem.name
        item.description = editedItem.description
    }
    
    // MARK: - Waiting feedback methods
    
    func startWaiting() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.showWaitOverlay()
    }
    
    func stopWaiting() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.removeAllOverlays()
    }
    
    // MARK: - Auxiliar methods
    
    private func didChangeSomething() -> Bool {
        return didChangeImage || didChangeText
    }

}

// MARK: Table View Data Source

extension EditItemController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.navigationItem.rightBarButtonItem?.isEnabled = didChangeText || didChangeImage
        return rowLabels.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CreateItemImageCell", for: indexPath) as! CreateItemImageCell
            cell.delegate = self
            cell.imageSelectionView.delegate = self
            
            // se tiver escolhido uma imagem nova
            if let selectedImg = selectedImage {
                cell.setImage(image: selectedImg)
            }
                
            // senão, se o bem já tiver uma imagem
            else if let img = item.image {
                cell.setImage(image: img)
            }
            // senão, tenta pegar na api, e salva no obj do item
            else {
                if let nrSeq = item.nrSeq {
                    repository.getImage(nrSeq: nrSeq) { (i, message) in
                        self.item.image = i
                        cell.setImage(image: i)
                    }
                }
            }
            
            cell.hero.modifiers = [.fade, .scale(0.75)]
            
            return cell
        }
        
        if indexPath.row > 0 && indexPath.row <= rowLabels.count {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CreateItemFieldCell", for: indexPath) as! CreateItemFieldCell
            cell.titleLabel.text = rowLabels[indexPath.row - 1]
            cell.configure(enabled: enabled[indexPath.row - 1], lineIsVisible: (indexPath.row < 4))
            
            switch indexPath.row {
            case 1:
                cell.contentLabel.text = editedItem.name
            case 2:
                cell.contentLabel.text = editedItem.description
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
            
            cell.button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
            cell.button.setTitle("Excluir do mural", for: .normal)
            cell.button.setTitleColor(.red, for: .normal)
            
            return cell
        }
            
        else {
            return UITableViewCell()
        }
        
    }
    
}

// MARK: - Table View delegate

extension EditItemController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        switch index {
        case 1:
            editField(title: "nome", defaultText: self.editedItem.name) { (text) in
                if let t = text {
                    self.editedItem.name = t
                    self.didChangeText = true
                    
                    self.tableView.reloadData()
                }
            }
        case 2:
            editField(title: "descrição", defaultText: self.editedItem.description) { (text) in
                if let t = text {
                    self.editedItem.description = t
                    self.didChangeText = true
                    
                    self.tableView.reloadData()
                }
            }
        default:
            break
        }
    }
    
    func editField(title: String, defaultText: String?, completion: @escaping (String?) -> ()) {
        
        let alert = Helper.createAlertWithTextInput(
            title: "Editar \(title)",
            message: nil,
            defaultText: defaultText,
            okButtonTitle: "Confirmar",
            completion: completion
        )
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Pick Image Protocol

extension EditItemController: PickImageProtocol {
    
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
            DispatchQueue.main.async {
                self.showImagePicker(sourceType: .camera, completion: completion)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Fototeca", style: .default) { (action) in
            DispatchQueue.main.async {
                self.showImagePicker(sourceType: .photoLibrary, completion: completion)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension EditItemController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditItemController: CropImageProtocol {
    
    func didCrop(image: UIImage) {
        self.selectedImage = image
        self.imageToBeCropped = nil
        
        self.tableView.reloadData()
    }
    
}

