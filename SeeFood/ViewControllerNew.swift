//
//  ViewController.swift
//  SeeFood
//
//  Created by ben on 2019/2/20.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit
import Vision

class ViewControllerNew: UIViewController,
                      UINavigationControllerDelegate {
    // attributes
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hint: UILabel!
    
    // laod model and create the request
    let model = try? VNCoreMLModel(for: Inceptionv3().model)
    lazy var hotdogRequest: VNCoreMLRequest = {
        if let model = model {
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassification(for: request, error: error)
            })
            return request
        } else {
            fatalError("Fail to load CoreML model")
        }
    }()
    
    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        hint.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    // update the title
    func processClassification(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let result = request.results else {
                self.navigationItem.title = "\(error!.localizedDescription)"
                return
            }
            
            let classifications = result as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.navigationItem.title = "???"
            } else {
                if let topClassification = classifications.first {
                    if topClassification.identifier.contains("hotdog") {
                        self.navigationItem.title = "hot dog！"
                    } else {
                        self.navigationItem.title = "not hot dog！"
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // handle the request
    func updateClassifications(for ciImage: CIImage) {
        self.navigationItem.title = "Classifying..."
        
//        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
//            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.hotdogRequest])
            } catch {
               /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}

extension ViewControllerNew: UIImagePickerControllerDelegate {
    
    // take image and invoke the hooks to update UI
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // deep learning hook
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Unable to create \(CIImage.self) from \(userPickedImage).")
            }
            updateClassifications(for: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

