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
        /// CIImage is the Core Image equivalent of UIImage
        /// sent the result into the current Core Image Filter using KCIInputImageKey
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    @IBAction func changeFilter(_ sender: Any) {
    }
    
    @IBAction func save(_ sender: Any) {
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing(){
        ///read output image from current filter
        guard let image = currentFilter.outputImage else {return}
        ///use slider value to set kCIInputIntensityKey
        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        ///creates a new data type called CGIImage from output image of current filter
        if let cgimg = context.createCGImage(image, from: image.extent) {
            ///create UIImage from CGIImage
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
    
}

