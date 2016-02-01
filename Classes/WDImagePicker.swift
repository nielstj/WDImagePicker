//
//  WDImagePicker.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos


@objc public protocol WDImagePickerDelegate {
    optional func imagePicker(imagePicker: WDImagePicker, pickedImage: UIImage)
    optional func imagePickerDidCancel(imagePicker: WDImagePicker)
    optional func imagePicker(imagePicker: WDImagePicker, pickedImage:  UIImage, info : [String : AnyObject]?)
}

@objc public class WDImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WDImageCropControllerDelegate {
    public var delegate: WDImagePickerDelegate?
    public var cropSize: CGSize!
    public var resizableCropArea = false
    
    private var _imagePickerController: UIImagePickerController!
    
    public var imagePickerController: UIImagePickerController {
        return _imagePickerController
    }
    
    private var info : [String : AnyObject]?
    
    override public init() {
        super.init()
        
        self.cropSize = CGSizeMake(320, 320)
        _imagePickerController = UIImagePickerController()
        _imagePickerController.delegate = self
        _imagePickerController.sourceType = .PhotoLibrary
    }
    
    private func hideController() {
        self._imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if self.delegate?.imagePickerDidCancel != nil {
            self.delegate?.imagePickerDidCancel!(self)
        } else {
            self.hideController()
        }
    }
    
    public func imagePickerController(picker: UIImagePickerController, var didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let url = info[UIImagePickerControllerReferenceURL] as! NSURL
        
        let fetchResult = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)
        
        let lastImageAsset = fetchResult.lastObject as! PHAsset
        let coordinate = lastImageAsset.location
        let date = lastImageAsset.creationDate
        
        self.info = [String : AnyObject]()
        
        if coordinate != nil {
            self.info!["location"] = coordinate
        }
        if date != nil {
            self.info!["date"] = date
        }
        
        
        
        let cropController = WDImageCropViewController()
        cropController.sourceImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        cropController.resizableCropArea = self.resizableCropArea
        cropController.cropSize = self.cropSize
        cropController.delegate = self
        picker.pushViewController(cropController, animated: true)
    }
    
    func imageCropController(imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.delegate?.imagePicker?(self, pickedImage: croppedImage, info : info)
    }
}
