//
//  EmbeddedCropViewController.swift
//  MantisExample
//
//  Created by Echo on 11/9/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit
import Mantis

class EmbeddedCropViewController: UIViewController {
    
    var image: UIImage?
    var preTrans: Transformation?
    var preCropInfo: CropInfo?
    var cropViewController: CropViewController?
    
    var didGetCroppedImage: ((UIImage, Transformation, CropInfo) -> Void)?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var resolutionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.title = "Cancel"
        doneButton.title = "Done"
        resolutionLabel.text = "\(getResolution(image: image) ?? "unknown")"
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func crop(_ sender: Any) {
        cropViewController?.crop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cropViewController = segue.destination as? CropViewController {
            cropViewController.image = image
            cropViewController.mode = .customizable
            cropViewController.delegate = self
            
            var config = Mantis.Config()
            config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
            config.showCropToolbar = true
            config.showRotationDial = false
            config.cropVisualEffectType = .light
            
            
            if let pre = preTrans {
                config.presetTransformationType = .presetInfo(info: pre)
            }
            
            
//            let transform = Transformation(offset: CGPoint(x: 0.0, y: 79.66666666666667),
//                                           rotation: -1.5707963267948966,
//                                           scale: 1.5,
//                                           manualZoomed: false,
//                                           intialMaskFrame: CGRect(x: 14.0, y: 57.33333333333334, width: 347.0, height: 231.33333333333331),
//                                           maskFrame: CGRect(x: 28.5, y: 14.0, width: 318.0, height: 318.0),
//                                           scrollBounds: CGRect(x: 0.0, y: 79.66666666666667, width: 318, height: 318))
//
//            config.presetTransformationType = .presetInfo(info: transform)
            
//            if let pre = preCropInfo {
//                config.presetTransformationType = .presetNormalizedInfo(normailizedInfo: CGRect(x: 0.0, y: 79.66666666666667, width: 318, height: 318))
//            }
            
            
            cropViewController.config = config
            
            self.cropViewController = cropViewController
        }
    }
    
    private func getResolution(image: UIImage?) -> String? {
        if let size = image?.size {
            return "\(Int(size.width)) x \(Int(size.height)) pixels"
        }
        return nil
    }
}

extension EmbeddedCropViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController,
                                   cropped: UIImage,
                                   transformation: Transformation,
                                   cropInfo: CropInfo) {
        self.dismiss(animated: true)
        self.didGetCroppedImage?(cropped, transformation, cropInfo)
        
        print(transformation)
//        print(cropViewController.getCurrentTransformation())
        print(cropViewController.convertTransformInfo(byTransformInfo: transformation))

    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        self.dismiss(animated: true)
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        self.resolutionLabel.text = "..."
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        let croppedImage = Mantis.crop(image: original, by: cropInfo)
        self.resolutionLabel.text = getResolution(image: croppedImage)
    }

}
