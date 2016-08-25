//
//  WDImagePicker.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import Photos
import UIKit
import AssetsLibrary
import Photos


@objc public protocol WDImagePickerDelegate {
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage, imageAsset:PHAsset?)
    func imagePickerDidCancel(_ imagePicker: WDImagePicker)
}

public class WDImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WDImageCropControllerDelegate {
    public var delegate: WDImagePickerDelegate?
    public var cropSize: CGSize!
    public var resizableCropArea = false
    
    private var _imagePickerController: UIImagePickerController!
    private var imageAsset:PHAsset!
    
    public var imagePickerController: UIImagePickerController {
        return _imagePickerController
    }
    
    private var info:[String : Any] = [:]
    
    override public init() {
        super.init()
        
        self.cropSize = CGSize(width: 320, height: 320)
        _imagePickerController = UIImagePickerController()
        _imagePickerController.delegate = self
        _imagePickerController.sourceType = .photoLibrary
    }
    
    private func hideController() {
        self._imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.imagePickerDidCancel(self)
    }
    
    @nonobjc public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let cropController = WDImageCropViewController()
        cropController.sourceImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        PHAsset.fetchAssets(withALAssetURLs: [info[UIImagePickerControllerReferenceURL] as! URL], options: nil).enumerateObjects(options: .concurrent) { (result, index, stop) in
            NSLog("result: \(result) - \(index)")
            self.imageAsset = result
        }
        
        cropController.resizableCropArea = self.resizableCropArea
        cropController.cropSize = self.cropSize
        cropController.delegate = self
        picker.pushViewController(cropController, animated: true)
    }
    
    func imageCropController(_ imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.delegate?.imagePicker(self, pickedImage: croppedImage, imageAsset: imageAsset)
    }
}
