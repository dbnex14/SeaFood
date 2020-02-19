//
//  ViewController.swift
//  SeaFood
//
//  Created by Dino B on 2020-02-19.
//  Copyright © 2020 Dino B. All rights reserved.
//

import UIKit
import CoreML
// First thing we need to do is to import needed
// frameworks.
// This will help us process images easier and allow us
// to use images with CoreML
import Vision

// Next, we need to declare protocols to use ImagePicker
// class to allow us to tap into camera as well as use the
// image for image recognition.  So we need to declare
// some protocols such as UIImagePickerControllerDelegate
// which needs UINavigationControllerDelegate.  So,
// UIImagePickerControllerDelegate relies on
// UINavigationControllerDelegate.
// Next, in main.storyboard, we embed our empty
// ViewController inside the navigationController by selecting
// the top yellow circle > Editor > Embed IN > NavigationController.
// This gives us free nav bar at the top and allows us to
// navigate btw screens easily.
// Next we added BarButton and changed its type to Camera and ImageView
// and set some constrains on it, then we added action and outlet for
// these.
//
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set imagePicker delegate
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera // allow user to take image (front/back)
        // but we cannot use camera with simulator so I use photoLibrary
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false // you can crop or so
    }
    
    // this delegate method comes from the UIImagePickerController class. It
    // tells the delegate (this view controller) that user has just picked
    // the image, so this is the time point.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // picker is our imagePicker
        // didFinishPickingMediaWithInfo is a dictionary
        // was image picked?
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // now that we got the image, set it to the background of our viewcontroller
            imageView.image = userPickedImage
            
            // convert image to CIImage (Core Image Image) since that allow us
            // to use Vision and CoreMl framework for interpretation.
            // We guard it to throw fatal error if conversion fails
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciImage) // do classification on image
        }
        
        // dismiss imagePicker and go back to our ViewController
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // method that will proces CIImage and get its clasification
    func detect(image: CIImage){
        // use inceptionV3 model
        //try will attempt to perform operation, if successful, the returned
        //object is wrapped as optional but if it fails, result will be nil.
        //So, if model is nill, trigger fatalError
        // VNCoreMLModel comes from Vision framework and allow us to perform
        // image analysis request that uses CoreML model to process images.
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        //create Vision CoreML request completion block
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            // get the higest result from classification
            if let firstResult = results.first {
                // tap into it
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                } else {
                    self.navigationItem.title = "Not Hotdog"
                }
            }
        }
        
        // perform request to clasiffy image using machine model
        let handler = VNImageRequestHandler(ciImage: image)
        //try! means we are forcing to execute the line but safer is to wrap it
        // into do catch block instead
        //try! handler.perform([request])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        // show camera, so present since it is ViewController which is our
        // imagePicker as animated and completion as null since we dont want
        // anything to happen after we present the imagePicker, we just
        // want user to be able to take pictures.
        present(imagePicker, animated: true, completion: nil)
        
        // ONce they pick image, we should be sending that to our machine
        // learning module.  In order to address that time point when user
        // has picked the image, we need to add delegate method which comes
        // from UIImagePickerController class and is called
        // didFinishPickingMediaWithInfo
    }
    
}

