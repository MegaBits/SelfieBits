//
//  ViewController.swift
//  SelfieBits
//
//  Created by Patrick Perini on 12/21/14.
//  Copyright (c) 2014 megabits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var photoView: UIImageView?
    @IBOutlet var stickerCollectionView: UICollectionView?
    @IBOutlet var trashField: UIButton?
    
    var stickerViews: [StickerView] = []
    func resetPhoto() {
        self.stickerViews.map {
            $0.removeFromSuperview()
        }
        
        self.stickerViews = []
        self.photoView?.image = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stickerCollectionView?.reloadData()
        
        StickerView.ControlProperties.deletionRect = CGRectInset(self.photoView!.convertRect(self.trashField!.frame, fromView: self.view), -50, -50)
        NSNotificationCenter.defaultCenter().addObserverForName("StickerViewAdded", object: nil, queue: nil) { (note: NSNotification?) in
            if let sticker: StickerView = note?.object as? StickerView {
                self.stickerViews.append(sticker)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("StickerViewDeleted", object: nil, queue: nil) { (note: NSNotification?) in
            if let sticker: StickerView = note?.object as? StickerView {
                UIView.animateWithDuration(0.25, animations: {
                    sticker.transform = CGAffineTransformScale(sticker.transform, 0.0001, 0.0001)
                }, completion: {(finished: Bool) in
                    sticker.removeFromSuperview()
                    self.stickerViews = self.stickerViews.filter {
                        return $0 != sticker
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraButtonWasPressed(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera

        self.presentViewController(imagePicker,
            animated: true,
            completion: nil)
    }
    
    @IBAction func megabitsButtonWasPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/megabits/id933449722?ls=1&mt=8")!)
    }
    
    @IBAction func shareButtonWasPressed(sender: UIButton) {
        // Flash screen
        let flashView: UIView = UIView(frame: UIScreen.mainScreen().bounds)
        flashView.backgroundColor = UIColor.whiteColor()
        flashView.layer.zPosition = CGFloat.max
        flashView.alpha = 0.0
        
        UIApplication.sharedApplication().keyWindow?.addSubview(flashView)
        UIView.animateWithDuration(0.06) {
            flashView.alpha = 1.0
        }
        
        // Pull image
        var snapshot: UIImage
        UIGraphicsBeginImageContext(self.photoView!.frame.size)
        
        self.photoView!.drawViewHierarchyInRect(self.photoView!.bounds, afterScreenUpdates: false)
        snapshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIView.animateWithDuration(0.94, animations: {
            flashView.alpha = 0.0
        }, completion: { (completed: Bool) in
            flashView.removeFromSuperview()
        })

        var popTime = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.01 * Float(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            // Share
            var caption = "#selfiebits"
            let activityPicker = UIActivityViewController(activityItems: [snapshot, caption], applicationActivities: nil)
            
            if activityPicker.respondsToSelector("popoverPresentationController") {
                let presentationController: UIPopoverPresentationController? = activityPicker.popoverPresentationController!
                presentationController?.sourceView = sender
            }
            
            activityPicker.completionHandler = { (activityType: String!, completed: Bool) in
                if completed {
                    self.resetPhoto()
                }
            }
            
            self.presentViewController(activityPicker, animated: true, completion: {
            })
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: StickerCellView? = collectionView.dequeueReusableCellWithReuseIdentifier("StickerCell", forIndexPath: indexPath) as? StickerCellView
        cell?.photoView = self.photoView
    
        switch indexPath.row {
        case 39:
            cell?.imageView?.image = UIImage(named: "XXX.png")
        default:
            cell?.imageView?.image = UIImage(named: String(format: "%03d.png", indexPath.row))
        }
        
        cell?.imageView?.layer.magnificationFilter = kCAFilterNearest
        return cell!
    }
}

extension ViewController: UINavigationControllerDelegate {
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        if let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.resetPhoto()
            self.photoView?.image = image
        }
    }
}