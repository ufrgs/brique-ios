//
//  ImageResizerView.swift
//  ImageResizer
//
//  Created by Augusto Boranga on 15/12/18.
//  Copyright © 2018 Augusto Boranga. All rights reserved.
//

import Foundation
import UIKit

class ImageResizerView: UIView {
    
    // MARK: - Properties
    
    var image: UIImage
    var imageView = UIImageView(frame: .zero)
    var cropView = CropView(frame: .zero, boundsFrame: .zero)
    var alphaView = UIView(frame: .zero)
    
    // MARK: - Initializers
    
    init(boundsFrame: CGRect, image: UIImage) {
        self.image = image
        
        let size = image.size
        
        let ratio = boundsFrame.size.width / size.width
        
        var height = size.height * ratio
        var width = boundsFrame.size.width
        
        if height > boundsFrame.size.height {
            let newRatio = boundsFrame.size.height / size.height
            
            height = boundsFrame.size.height
            width = size.width * newRatio
        }
        
        let correctFrame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        
        super.init(frame: correctFrame)
        
        configureViews()
        configureGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Configuration methods
    
    func configureViews() {
        imageView = makeImageView()
        
        cropView = makeCropView(boundsFrame: imageView.frame)
        cropView.center = imageView.center
        
        alphaView = makeAlphaView()
        setMask(with: cropView.frame, in: alphaView)
        
        imageView.addSubview(alphaView)
        imageView.addSubview(cropView)
        
        self.addSubview(imageView)
    }
    
    func configureGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: cropView, action: #selector(CropView.didDragView(_:)))
        panRecognizer.addTarget(self, action: #selector(ImageResizerView.updateAlphaView(_:)))
        
        self.gestureRecognizers = [panRecognizer]
    }
    
    // MARK: - View creation methods
    
    func makeImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.frame)
        
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = UIColor.orange
        imageView.image = self.image
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }
    
    func makeCropView(boundsFrame: CGRect) -> CropView {
        let minAxes = min(self.frame.size.width, self.frame.size.height)
        let cropFrame = CGRect(origin: self.frame.origin, size: CGSize(width: minAxes, height: minAxes))
        
        return CropView(frame: cropFrame, boundsFrame: boundsFrame)
    }
    
    func makeAlphaView() -> UIView {
        let alphaView = UIView(frame: self.frame)
        
        alphaView.backgroundColor = .black
        alphaView.alpha = 0.5
        
        return alphaView
    }
    
    // MARK: - Gesture Recognizer methods
    
    @objc func updateAlphaView(_ sender: UIPanGestureRecognizer) {
        setMask(with: cropView.frame, in: alphaView)
    }
    
    func setMask(with hole: CGRect, in view: UIView) {
        
        let mutablePath = CGMutablePath()
        mutablePath.addRect(view.bounds)
        mutablePath.addRect(hole)
        
        let mask = CAShapeLayer()
        mask.path = mutablePath
        mask.fillRule = kCAFillRuleEvenOdd
        
        view.layer.mask = mask
    }
    
    // MARK: - Finish editing methods
    
    func calculateNewImageFrame() -> CGRect {
        let originalSize = self.image.size
        
        let oldFrame = CGRect(origin: .zero, size: originalSize)
        
        let x = (cropView.frame.origin.x * originalSize.width) / imageView.frame.size.width
        let y = (cropView.frame.origin.y * originalSize.height) / imageView.frame.size.height
        let height = (cropView.frame.size.height * originalSize.height) / imageView.frame.size.height
        let width = (cropView.frame.size.width * originalSize.width) / imageView.frame.size.width
        
        let measure = min(height, width)
        let frame = CGRect(x: round(x), y: round(y), width: measure, height: measure)
        
        return frame
    }
    
    func fixImageOrientation(_ original: UIImage) -> UIImage {
        if original.imageOrientation == UIImageOrientation.up {
            return original
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch original.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: original.size.width, y: original.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: original.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: original.size.height)
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
            break
            
        default:
            break
        }
        
        switch original.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: original.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: original.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        
        let context: CGContext = CGContext(data: nil, width: Int(original.size.width), height: Int(original.size.height), bitsPerComponent: (original.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (original.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.concatenate(transform)
        
        switch original.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(original.cgImage!, in: CGRect(x: 0, y: 0, width: original.size.height, height: original.size.width))
            break
            
        default:
            context.draw(original.cgImage!, in: CGRect(x: 0, y: 0, width: original.size.width, height: original.size.height))
            break
        }
        
        let cgImage: CGImage = context.makeImage()!
        let image: UIImage = UIImage(cgImage: cgImage)
        
        return image
    }
    
}
