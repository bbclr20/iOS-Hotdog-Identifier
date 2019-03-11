//
//  ViewController.swift
//  SeeFood
//
//  Created by ben on 2019/2/20.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {
    // attributes
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    lazy var model = try? VNCoreMLModel(for: Inceptionv3().model)
    
    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
        
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("can't convert the image to CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    /**
    Predict CIImage.

    - Parameters
        image: a CIImage as CoreML model input.

     */
    func detect(image: CIImage) {
        guard let model = self.model else {
            fatalError("fail to load CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error)	 in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("fail to process the image")
            }
            
            print(results)
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "hot dog！"
                } else {
                    self.navigationItem.title = "not hot dog！"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        try! handler.perform([request])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

