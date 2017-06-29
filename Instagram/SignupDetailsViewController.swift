//
//  SignupDetailsViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/28/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class SignupDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var email: String?
    var username: String?
    var password: String?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var aboutMe: UITextField!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton.layer.cornerRadius = 5
        
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @IBAction func backToSignup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToLogin(_ sender: UIButton) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        photoView.image = editedImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func setProfilePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Set Profile Photo", message: "", preferredStyle: .actionSheet)
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            vc.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(vc, animated: true, completion: nil)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                print("Camera is available 📸")
                vc.sourceType = .camera
            } else {
                print("Camera 🚫 available so we will use photo library instead")
                vc.sourceType = .photoLibrary
            }
            
        })
        alert.addAction(UIAlertAction(title: "Library", style: .default) { action in
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(vc, animated: true, completion: nil)
        })
        
        self.present(alert, animated: true)
    }

    @IBAction func finishSignup(_ sender: UIButton) {
        let newUser = PFUser()
        
        let profilePhoto = getPFFileFromImage(image: resize(image: photoView.image!, newSize: CGSize(width: 500, height: 500)))
        let name = nameField.text ?? ""
        let about = aboutMe.text ?? ""
        
        // set user properties
        newUser.username = username?.trimmingCharacters(in: .whitespaces)
        newUser.email = email
        newUser.password = password
        
        newUser.setObject(name, forKey: "Name")
        newUser.setObject(about, forKey: "About")
        newUser.setObject(profilePhoto as Any, forKey: "ProfilePhoto")
        
        // call sign up function on the object
        newUser.signUpInBackground() { (success: Bool, error: Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User Registered successfully")
                // manually segue to logged in view
                self.performSegue(withIdentifier: "signupDetailsSegue", sender: nil)
            }
        }
        
        self.performSegue(withIdentifier: "signedUpSegue", sender: nil)
    }
    
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
