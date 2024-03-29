//
//  ViewController.swift
//  PictureEdit
//
//  Created by Lee Sangoroh on 04/02/2024.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var intensityTwo: UISlider!
    
    var currentImage: UIImage!
    ///CoreImage component that handles rendering
    var context: CIContext!
    ///store filter the user activates
    var currentFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        dismiss(animated: true)
        
        currentImage = image
        self.imageView.alpha = 0
        /// CIImage is the Core Image equivalent of UIImage
        /// sent the result into the current Core Image Filter using KCIInputImageKey
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func setFilterr(){
        let ac = UIAlertController(title:"Choose Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title:"CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title:"Cancel", style: .cancel))
        present(ac, animated: true)
    }

    @IBAction func changeFilter(_ sender: Any) {
        setFilterr()
    }
    
    @IBAction func changeFilterTwo(_ sender: Any) {
        setFilterr()
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            fatalError("There is no image to be saved")
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func intensityTwoChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    func applyProcessing(){
        
        UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
            self.imageView.alpha = 1
        }, completion: nil)
        ///read output image from current filter
        //guard let image = currentFilter.outputImage else {return}
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)}
        if inputKeys.contains(kCIInputRadiusKey) {currentFilter.setValue(intensity.value*200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) {currentFilter.setValue(intensity.value*10, forKey: kCIInputScaleKey)}
        if inputKeys.contains(kCIInputCenterKey) {currentFilter.setValue(CIVector(x: currentImage.size.width/2, y: currentImage.size.height/2), forKey: kCIInputCenterKey)}
        
        ///use slider value to set kCIInputIntensityKey
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        ///creates a new data type called CGIImage from output image of current filter
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            ///create UIImage from CGIImage
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
    }
    
    func applyProcessingTwo(){
        ///read output image from current filter
        //guard let image = currentFilter.outputImage else {return}
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {currentFilter.setValue(intensityTwo.value, forKey: kCIInputIntensityKey)}
        if inputKeys.contains(kCIInputRadiusKey) {currentFilter.setValue(intensityTwo.value*200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) {currentFilter.setValue(intensityTwo.value*10, forKey: kCIInputScaleKey)}
        if inputKeys.contains(kCIInputCenterKey) {currentFilter.setValue(CIVector(x: currentImage.size.width/2, y: currentImage.size.height/2), forKey: kCIInputCenterKey)}
        
        ///use slider value to set kCIInputIntensityKey
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        ///creates a new data type called CGIImage from output image of current filter
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            ///create UIImage from CGIImage
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        ///make sure we have a valid image before continuing
        guard currentImage != nil else {return}
        
        ///safely read alert action's title
        guard let actionTitle = action.title else {return}
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            ///we got an error
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image is saved", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

