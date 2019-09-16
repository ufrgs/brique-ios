//
//  ImageSelectionView.swift
//  ufrgs-mural
//
//  Created by Augusto on 18/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class ImageSelectionView: UIView {
    
    // MARK: - Properties
    
    let borderColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1.0)
    let noImageSelectedTextColor = UIColor(red: 188/255.0, green: 188/255.0, blue: 188/255.0, alpha: 1.0)
    
    let cornerRadiusValue: CGFloat = 6.0
    let alphaViewHeight: CGFloat = 80.0
    let imageSelectedText = "Alterar imagem"
    let noImageSelectedText = "Adicionar\numa imagem"
    
    var button = UIButton(frame: .zero)
    var imageView = UIImageView()
    var alphaView = UIView()
    var label = UILabel()
    var dashedBorder = CAShapeLayer()
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var image: UIImage?
    var imageIsSelected = false
    
    var loading = false
    
    weak var delegate: PickImageProtocol?
    
    // MARK: - Initializers
    
    init(frame: CGRect, image: UIImage?) {
        super.init(frame: frame)
        commonInit()
        setImage(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        configureCornerRadius()
        configureDashedBorder()
        configureImageView()
        configureAlphaView()
        configureSpinner()
        configureButton()
        
        button.removeFromSuperview()
        self.addSubview(button)
        
        loading = true
        updateFrames()
        updateUI()
    }
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    // MARK: - Configuration methods
    
    private func configureCornerRadius() {
        layer.cornerRadius = cornerRadiusValue
        clipsToBounds = true
    }
    
    private func configureImageView() {
        imageView = UIImageView(frame: CGRect(origin: .zero, size: self.frame.size))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0)
    }
    
    private func configureAlphaView() {
        let y = self.frame.height - alphaViewHeight
        
        alphaView = UIView(frame: CGRect(x: 0, y: y, width: self.frame.width, height: alphaViewHeight))
        
        alphaView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        alphaView.isUserInteractionEnabled = false
    }
    
    private func configureButton() {
        button = UIButton(frame: CGRect(origin: .zero, size: self.frame.size))
        
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    private func configureDashedBorder() {
        dashedBorder = CAShapeLayer()
        
        dashedBorder.cornerRadius = cornerRadiusValue
        dashedBorder.strokeColor = borderColor.cgColor
        dashedBorder.lineWidth = 5.0
        dashedBorder.lineDashPattern = [10, 10]
        dashedBorder.fillColor = nil
        dashedBorder.frame = self.bounds
        dashedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadiusValue).cgPath
    }

    // MARK: - Auxiliar methods
    
    public func setImage(image: UIImage?) {
        
        self.loading = false
        self.image = image
        
        updateFrames()
        updateUI()
        
    }
    
    private func updateFrames() {
        imageView.frame = CGRect(origin: .zero, size: self.frame.size)
        alphaView.frame = CGRect(x: 0, y: self.frame.height - alphaViewHeight, width: self.frame.width, height: alphaViewHeight)
        button.frame = CGRect(origin: .zero, size: self.frame.size)
        spinner.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        dashedBorder.frame = self.bounds
        dashedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadiusValue).cgPath
        
        if imageIsSelected {
            label.frame = CGRect(origin: .zero, size: self.alphaView.frame.size)
        } else {
            label.frame = CGRect(origin: .zero, size: self.frame.size)
        }
    }
    
    func updateUI() {
        
        if hasImage() {
            setImageSelected()
            imageIsSelected = true
        } else {

            if loading {
                setLoading()
            } else {
                setNoImageSelected()
            }
            
            imageIsSelected = false
        }
        
    }
    
    func hasImage() -> Bool {
        return self.image != nil
    }
    
    @objc func buttonClicked() {
        self.delegate?.pickImage()
    }
    
}

// MARK: - Loading methods

extension ImageSelectionView {
    
    func setLoading() {
        self.imageView.image = nil
        self.configureLabelNoImageSelected()
        
        self.label.removeFromSuperview()
        self.alphaView.removeFromSuperview()
        self.imageView.removeFromSuperview()
        
        self.dashedBorder.opacity = 0.0
        self.spinner.alpha = 0.0
        self.spinner.startAnimating()
        
        self.layer.addSublayer(dashedBorder)
        self.addSubview(spinner)
        
        UIView.animate(withDuration: 0.25) {
            self.dashedBorder.opacity = 1.0
            self.spinner.alpha = 1.0
        }
    }
    
    func configureSpinner() {
        spinner.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
}

// MARK: - Image Selected methods

extension ImageSelectionView {
    
    func setImageSelected() {
        
        self.imageView.image = self.image
        
        self.label.removeFromSuperview()
        self.spinner.removeFromSuperview()
        self.dashedBorder.removeFromSuperlayer()
        
        self.configureLabelImageSelected()
        
        if !imageIsSelected {
            self.imageView.alpha = 0.0
            self.alphaView.alpha = 0.0
            
            self.addSubview(self.imageView)
            self.addSubview(self.alphaView)
            
            UIView.animate(withDuration: 0.25) {
                self.imageView.alpha = 1.0
                self.alphaView.alpha = 1.0
            }
        }
        
        self.alphaView.addSubview(self.label)
    }
    
    private func configureLabelImageSelected() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.alphaView.frame.width, height: self.alphaView.frame.height))
        
        if let font = UIFont(name: "AvenirNext-Medium", size: 16) {
            label.font = font
        }
        
        label.textColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = imageSelectedText

    }
    
}

// MARK: - No Image Selected methods

extension ImageSelectionView {
    
    func setNoImageSelected() {
        
        self.imageView.image = nil
        self.configureLabelNoImageSelected()
        
        self.label.removeFromSuperview()
        self.spinner.removeFromSuperview()
        self.alphaView.removeFromSuperview()
        self.imageView.removeFromSuperview()
        
        self.label.alpha = 0.0
        self.addSubview(label)
        
        self.dashedBorder.opacity = 0.0
        self.layer.addSublayer(dashedBorder)
            
        UIView.animate(withDuration: 0.25) {
            self.dashedBorder.opacity = 1.0
            self.label.alpha = 1.0
        }
    }
    
    private func configureLabelNoImageSelected() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        if let font = UIFont(name: "AvenirNext-Medium", size: 17) {
            label.font = font
        }
        
        label.textColor = noImageSelectedTextColor
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = noImageSelectedText
    }
    
}
