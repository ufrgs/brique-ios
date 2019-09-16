//
//  CropView.swift
//  ImageResizer
//
//  Created by Augusto on 17/12/2018.
//  Copyright © 2018 Augusto Boranga. All rights reserved.
//

import Foundation
import UIKit

class CropView: UIView {
    
    // MARK: - Properties
    
    var lastLocation = CGPoint.zero
    var lastFrame = CGRect.zero
    
    var boundsFrame = CGRect()
    
    var minX: CGFloat = 0.0
    var maxX: CGFloat = 0.0
    var minY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    
    var corners = [UIView]()
    var cornerBeingDragged: UIView?
    
    var isResizing = false
    var minSize: CGFloat = 0.0
    
    let cornerSize: CGFloat = 25.0
    
    // MARK: - Initializers
    
    init(frame: CGRect, boundsFrame: CGRect) {
        super.init(frame: frame)
        self.boundsFrame = boundsFrame
        
        calculateTranslationBounds()
        calculateMinSize()
        configureCorners()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Configuration methods
    
    private func configureUI() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        
        self.isUserInteractionEnabled = true
    }
    
    private func configureCorners() {
        // 0    1
        //
        // 2    3
        
        let originPoints = [CGPoint(x: 0, y: 0),
                            CGPoint(x: frame.width - cornerSize, y: 0),
                            CGPoint(x: 0, y: frame.height - cornerSize),
                            CGPoint(x: frame.width - cornerSize, y: frame.height - cornerSize)]
        
        let size = CGSize(width: cornerSize, height: cornerSize)
        
        for i in 0..<originPoints.count {
            let frame = CGRect(origin: originPoints[i], size: size)
            let corner = UIView(frame: frame)
            
            corner.tag = i
            corner.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
            
            self.corners.append(corner)
            self.addSubview(corner)
        }
    }
    
    private func calculateTranslationBounds() {
        minX = frame.size.width / 2
        maxX = boundsFrame.size.width - minX
        minY = frame.size.height / 2
        maxY = boundsFrame.size.height - minY
    }
    
    private func calculateMinSize() {
        let minAxis = min(boundsFrame.size.width, boundsFrame.size.height)
        minSize = minAxis/2
    }
    
    // MARK: - Overrides
    
    override func touchesBegan(_ touches: (Set<UITouch>), with event: UIEvent!) {
        self.superview?.bringSubview(toFront: self)
        isResizing = false
        
        if let touch = touches.first {
            for corner in corners {
                if touch.view == corner {
                    cornerBeingDragged = corner
                    isResizing = true
                }
            }
        }
        
        lastLocation = self.center
        lastFrame = self.frame
    }
    
    // MARK: - Gesture handler methods
    
    @objc func didDragView(_ sender: UIPanGestureRecognizer) {
        let t  = sender.translation(in: self.superview)
        
        // if touch came from some of the corners
        if isResizing {
            resizeView(translation: t)
        } else {
            moveView(translation: t)
        }
        
    }
    
    func resizeView(translation: CGPoint) {
        
        var newOriginX: CGFloat = lastFrame.origin.x
        var newOriginY: CGFloat = lastFrame.origin.y
        var newWidth: CGFloat = lastFrame.size.width
        var newHeigth: CGFloat = lastFrame.size.height
        
        // if the cropped image is already on its smallest possible size
        if let corner = cornerBeingDragged {
            switch corner.tag {
            case 0:
                newOriginX = lastFrame.origin.x + translation.x
                newOriginY = lastFrame.origin.y + translation.x
                newWidth = lastFrame.size.width - translation.x
                newHeigth = lastFrame.size.height - translation.x
                
                if newOriginX <= 0 {
                    newOriginX = 0
                    newOriginY = self.frame.origin.y
                    newWidth = self.frame.size.width
                    newHeigth = self.frame.size.height
                }
                
                if newOriginY <= 0 {
                    newOriginX = self.frame.origin.x
                    newOriginY = 0
                    newWidth = self.frame.size.width
                    newHeigth = self.frame.size.height
                }

            case 1:
                newOriginX = lastFrame.origin.x
                newOriginY = lastFrame.origin.y - translation.x
                newWidth = lastFrame.size.width + translation.x
                newHeigth = lastFrame.size.height + translation.x
                
                if (newWidth + newOriginX) > boundsFrame.size.width {
                    newOriginY = self.frame.origin.y
                    newWidth = self.frame.origin.x
                    newHeigth = newWidth
                }
                
                if newOriginY <= 0 {
                    newOriginX = self.frame.origin.x
                    newOriginY = 0
                    newWidth = self.frame.size.width
                    newHeigth = self.frame.size.height
                }
                
            case 2:
                newOriginX = lastFrame.origin.x + translation.x
                newOriginY = lastFrame.origin.y
                newWidth = lastFrame.size.width - translation.x
                newHeigth = lastFrame.size.height - translation.x
                
                if newOriginX <= 0 {
                    newOriginX = 0
                    newOriginY = self.frame.origin.y
                    newWidth = self.frame.size.width
                    newHeigth = self.frame.size.height
                }
                
                if (newHeigth + newOriginY) > boundsFrame.size.height {
                    newOriginX = self.frame.origin.x
                    newOriginY = self.frame.origin.y
                    newHeigth = self.frame.size.height
                    newWidth = newHeigth
                }
                
            case 3:
                newOriginX = lastFrame.origin.x
                newOriginY = lastFrame.origin.y
                newWidth = lastFrame.size.width + translation.x
                newHeigth = lastFrame.size.height + translation.x
                
                if (newWidth + newOriginX) > boundsFrame.size.width {
                    newOriginY = self.frame.origin.y
                    newWidth = self.frame.origin.x
                    newHeigth = newWidth
                }
                
                if (newHeigth + newOriginY) > boundsFrame.size.height {
                    newOriginX = self.frame.origin.x
                    newOriginY = self.frame.origin.y
                    newHeigth = self.frame.size.height
                    newWidth = newHeigth
                }
                
            default:
                break
            }
        }
        
        if newWidth < minSize && newHeigth < minSize {
            return
        }
        
        self.frame.origin.x = newOriginX
        self.frame.origin.y = newOriginY
        self.frame.size.width = newWidth
        self.frame.size.height = newHeigth
        
        self.center = CGPoint(x: newOriginX + self.frame.size.width/2, y: newOriginY + self.frame.size.height/2)
        
        updateCorners()
        calculateTranslationBounds()
        
    }
    
    func moveView(translation: CGPoint) {
        
        var newCenterX = lastLocation.x + translation.x
        var newCenterY = lastLocation.y + translation.y
        
        if newCenterX > maxX {
            newCenterX = maxX
        } else if newCenterX < minX {
            newCenterX = minX
        }
        
        if newCenterY > maxY {
            newCenterY = maxY
        } else if newCenterY < minY {
            newCenterY = minY
        }
        
        self.center = CGPoint(x: newCenterX, y: newCenterY)
    }
    
    // MARK: - Update corners
    
    private func updateCorners() {
        let originPoints = [CGPoint(x: 0, y: 0),
                            CGPoint(x: frame.width - cornerSize, y: 0),
                            CGPoint(x: 0, y: frame.height - cornerSize),
                            CGPoint(x: frame.width - cornerSize, y: frame.height - cornerSize)]
        
        for i in 0..<corners.count {
            corners[i].frame.origin = originPoints[i]
        }
    }
    
}

