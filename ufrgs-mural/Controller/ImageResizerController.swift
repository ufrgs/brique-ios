//
//  ImageResizerController.swift
//  ufrgs-mural
//
//  Created by Augusto on 18/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class ImageResizerController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    
    var image: UIImage?
    var imageResizerView: ImageResizerView?
    var delegate: CropImageProtocol?
    
    let imgName = "capivara"
    
    // MARK: - Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let img = self.image {
            
            imageResizerView = ImageResizerView(boundsFrame: self.containerView.frame, image: img)
            imageResizerView!.center = containerView.convert(containerView.center, from: containerView.superview)
            
            self.containerView.addSubview(imageResizerView!)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        var frame = imageResizerView!.calculateNewImageFrame()
        
        if let img = self.image {
            
            let correctlyOrientedImage = imageResizerView!.fixImageOrientation(img)
            
            if let croppedImage = correctlyOrientedImage.cgImage?.cropping(to: frame) {
                
                let newImage = UIImage(cgImage: croppedImage)
                
                delegate?.didCrop(image: newImage)
                dismiss(animated: true, completion: nil)

                // para teste apenas
//                testImageResult(image: newImage)
            }
            
        }
    }
    
    private func testImageResult(image: UIImage) {
        for sv in containerView.subviews {
            sv.removeFromSuperview()
        }

        let imageView = UIImageView(frame: containerView.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image

        containerView.addSubview(imageView)
    }
}


