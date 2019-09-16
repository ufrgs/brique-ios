//
//  CreateItemImageController.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class CreateItemImageController: UIViewController {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var dismissDelegate: CreateItemBaseProtocol?
    
    var imageSelectionView: ImageSelectionView?
    var selectedImage: UIImage?
    var imageToBeCropped: UIImage?
    
    var repository = ItemRepository()
    var item = Item()
    
    // MARK: - Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let containerSubviewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: imageContainerView.bounds.width, height: imageContainerView.bounds.height))
        
        if imageSelectionView == nil {
            
            imageSelectionView = ImageSelectionView(frame: containerSubviewFrame, image: selectedImage)
            imageSelectionView!.delegate = self
        
            self.imageContainerView.addSubview(imageSelectionView!)
            self.saveButton.isEnabled = imageSelectionView!.hasImage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageResizerModally" {
            let vc = segue.destination as! ImageResizerController
            
            vc.image = self.imageToBeCropped
            vc.delegate = self
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismissDelegate?.dismiss()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let nrSeq = self.item.nrSeq, let image = self.selectedImage {
            self.trySavingImage(nrSeq: nrSeq, image: image)
        } else {
            let alert = Helper.createSimpleAlert(title: "Erro", message: "Não foi possível salvar a foto.")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func trySavingImage(nrSeq: Int, image: UIImage) {
        self.startWaiting()
        
        repository.updateImage(nrSeq: nrSeq, image: image) { (success, message) in
            self.stopWaiting()
            
            if success {
                Helper.toast(message: message, time: 0.8, view: self.view.superview) {
                    self.dismissDelegate?.dismiss()
                }
            }
                
            else {
                let alert = Helper.createSimpleAlert(title: "Erro", message: message)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Waiting feedback methods
    
    func startWaiting() {
        self.saveButton.isUserInteractionEnabled = false
        self.showWaitOverlay()
    }
    
    func stopWaiting() {
        self.saveButton.isUserInteractionEnabled = true
        self.removeAllOverlays()
    }
    
}

// MARK: - PickImageProtocol

protocol PickImageProtocol: class {
    func pickImage()
}

extension CreateItemImageController: PickImageProtocol {
    
    func pickImage() {
        
        askImageSource { (image) in
            
            if let img = image {
                self.imageToBeCropped = img
                // show controller to resize/crop the image resize
                self.performSegue(withIdentifier: "showImageResizerModally", sender: self)
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

extension CreateItemImageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

protocol CropImageProtocol: class {
    func didCrop(image: UIImage)
}

extension CreateItemImageController: CropImageProtocol {
    
    func didCrop(image: UIImage) {
        self.selectedImage = image
        self.imageSelectionView!.setImage(image: image)
        self.saveButton.isEnabled = self.imageSelectionView!.hasImage()
    }
    
}
