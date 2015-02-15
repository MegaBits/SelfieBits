//
//  StickerCellView.swift
//  SelfieBits
//
//  Created by Patrick Perini on 12/21/14.
//  Copyright (c) 2014 megabits. All rights reserved.
//

import UIKit

class StickerCellView: UICollectionViewCell {
    // MARK: Classes
    internal struct Position {
        var originalCenter: CGPoint = CGPointZero
        var lastCenter: CGPoint = CGPointZero
        
        var originalSuperView: UIView
        var photoView: UIView
        
        func overView(view: UIView?) -> Bool {
            var viewFrame = self.photoView.convertRect(view?.frame ?? CGRectZero, fromView: view)
            return CGRectContainsPoint(viewFrame, self.lastCenter)
        }
    }
    
    // MARK: Properties
    @IBOutlet var imageView: UIImageView?
    var photoView: UIImageView?
    
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
    private var position: Position?
    
    override func awakeFromNib() {
        // Add long press gesture recognizer
        self.longPressGestureRecognizer.allowableMovement = CGFloat.max
        self.longPressGestureRecognizer.minimumPressDuration = 0.10
        
        self.addGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began: // Pick up
            var position = Position(originalCenter: self.center,
                lastCenter: self.center,
                originalSuperView: self.superview!,
                photoView: self.photoView!)
            
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowRadius = 1.0
            self.layer.shadowOpacity = 0.50
            self.layer.shadowOffset = CGSizeZero
            
            self.photoView?.addSubview(self)
            
            self.transform = CGAffineTransformMakeScale(1.25, 1.25)
            position.lastCenter = self.photoView!.convertPoint(self.center, fromView: position.originalSuperView)
            
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
                self.transform = CGAffineTransformIdentity
                self.center = position.originalCenter
                position.originalSuperView.addSubview(self)
                self.layer.shadowOpacity = 0.00
                
                if position.overView(self.photoView) {
                    var newImageView: StickerView = StickerView(imageView: self.imageView!)
                    newImageView.center = position.lastCenter
                    
                    self.photoView?.addSubview(newImageView)
                }
                
                self.position =  nil
            }
            
        default:
            break
        }
    }
}