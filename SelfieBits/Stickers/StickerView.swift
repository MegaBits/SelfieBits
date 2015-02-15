//
//  StickerView.swift
//  SelfieBits
//
//  Created by Patrick Perini on 12/21/14.
//  Copyright (c) 2014 megabits. All rights reserved.
//

import UIKit

class StickerView: UIImageView {
    struct ControlProperties {
        // MARK: Class Properties
        static var deletionRect: CGRect = CGRectZero
    }
    
    // MARK: Properties
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchGestureRecognized:")
    private lazy var rotateGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateGestureRecognized:")
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapGestureRecognized:")
    
    private var position: StickerCellView.Position?
    private var lastScale: CGFloat = 1.00
    
    // MARK: Initializers
    required init(imageView: UIImageView) {
        super.init(frame: imageView.frame)

        self.image = imageView.image
        self.contentMode = imageView.contentMode
        self.userInteractionEnabled = true
        
        self.longPressGestureRecognizer.allowableMovement = CGFloat.max
        self.longPressGestureRecognizer.minimumPressDuration = 0.10
        
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        self.addGestureRecognizer(self.longPressGestureRecognizer)
        self.addGestureRecognizer(self.pinchGestureRecognizer)
        self.addGestureRecognizer(self.rotateGestureRecognizer)
        self.addGestureRecognizer(self.doubleTapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().postNotificationName("StickerViewAdded", object: self)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture Recognizers
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began: // Pick up
            var position = StickerCellView.Position(originalCenter: self.center,
                lastCenter: self.center,
                originalSuperView: self.superview!,
                photoView: self.superview!)
        
            self.transform = CGAffineTransformScale(self.transform, 1.25, 1.25)
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowRadius = 4.0
            self.layer.shadowOpacity = 0.50
            self.layer.shadowOffset = CGSizeZero
            
            self.center = position.lastCenter
            self.position = position
            
        case UIGestureRecognizerState.Changed: // Drag
            if var position = self.position {
                position.lastCenter = gestureRecognizer.locationInView(self.superview)
                self.center = position.lastCenter
                
                self.position = position
            }
            
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled: // Put down
            if var position = self.position {
                self.transform = CGAffineTransformScale(self.transform, 0.80, 0.80)
                
                if CGRectContainsPoint(ControlProperties.deletionRect, self.position!.lastCenter) {
                    NSNotificationCenter.defaultCenter().postNotificationName("StickerViewDeleted", object: self)
                }
                
                self.position =  nil
                self.layer.shadowOpacity = 0.0
            }
            
        default:
            break
        }
    }

    func pinchGestureRecognized(gestureRecognizer: UIPinchGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Changed: // Scaling
            if gestureRecognizer.scale > 3.0 {
                break
            }
            
            var scale = 1.0 + (gestureRecognizer.scale - self.lastScale)
            self.lastScale = gestureRecognizer.scale
            self.transform = CGAffineTransformScale(self.transform, scale, scale)
            
        case UIGestureRecognizerState.Ended:
            self.lastScale = 1.0
            
        default:
            break
        }
    }
    
    func rotateGestureRecognized(gestureRecognizer: UIRotationGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Changed: // Rotating
            var rotation = gestureRecognizer.rotation
            self.transform = CGAffineTransformRotate(self.transform, rotation)
            gestureRecognizer.rotation = 0
            
        default:
            break
        }
    }
    
    func doubleTapGestureRecognized(gestureRecognizer: UITapGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Ended: // Flipping
            UIView.animateWithDuration(0.33, animations: {
                self.transform = CGAffineTransformScale(self.transform, -1, 1)
            })
            
        default:
            break
        }
    }
}
