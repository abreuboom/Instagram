//
//  CameraViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import CameraManager
import Sharaku



class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    let cameraManager = CameraManager()
    
    var capturedPhoto: UIImage?
    
    
    override func viewWillAppear(_ animated: Bool) {
        cameraLive()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
        captureButton.layer.masksToBounds = true
        
    }
    
    func cameraLive () {
        cameraManager.addPreviewLayerToView(self.liveView)
        cameraManager.cameraDevice = .front
        cameraManager.shouldEnableTapToFocus = true
        cameraManager.shouldEnablePinchToZoom = true
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.flashMode = .off
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                let imageToBeFiltered = image
                let vc = SHViewController(image: imageToBeFiltered!)
                vc.delegate = self
                self.present(vc, animated:true, completion: nil)
                self.performSegue(withIdentifier: "composeSegue", sender: sender)
            }
        })
    }
    
    @IBAction func flipCamera(_ sender: UIButton) {
        if cameraManager.cameraDevice == .front {
            cameraManager.cameraDevice = .back
        }
        else {
            cameraManager.cameraDevice = .front
        }
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraManager.flashMode == .off {
            cameraManager.flashMode = .on
            flashButton.setTitle("Flash ON", for: .normal)
        }
        else {
            cameraManager.flashMode = .off
            flashButton.setTitle("Flash OFF", for: .normal)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        capturedPhoto = editedImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "composeSegue", sender: self)
    }
    
    //    @IBAction func launchCamera(_ sender: UIButton) {
    //        let vc = UIImagePickerController()
    //        vc.delegate = self
    //        vc.allowsEditing = true
    //
    //        vc.sourceType = UIImagePickerControllerSourceType.camera
    //
    //        self.present(vc, animated: true, completion: nil)
    //
    //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
    //            print("Camera is available 📸")
    //            vc.sourceType = .camera
    //        } else {
    //            print("Camera 🚫 available so we will use photo library instead")
    //            vc.sourceType = .photoLibrary
    //        }
    //    }
    
    @IBAction func launchLibrary(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "composeSegue" {
            let composeView = segue.destination as! ComposeViewController
            composeView.chosenPhoto = self.capturedPhoto
        }
    }
}

extension CameraViewController: SHViewControllerDelegate {
    func shViewControllerImageDidFilter(image: UIImage) {
        capturedPhoto = image
    }
    
    func shViewControllerDidCancel(){
        return
        
    }
}
