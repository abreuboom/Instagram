//
//  EditProfileViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/29/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    
    let user = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width / 2
        profilePhotoView.layer.masksToBounds = true
        
        if let photo = user?.object(forKey: "ProfilePhoto")as? PFFile {
            photo.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    self.profilePhotoView.image = image
                }
            })
        }
        else {
            self.profilePhotoView.image = #imageLiteral(resourceName: "temp-profile")
        }
        
        if let fullName = user?.object(forKey: "Name")as? String {
            nameField.placeholder = fullName
        }
        
        if let aboutme = user?.object(forKey: "About")as? String {
            aboutField.placeholder = aboutme
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        profilePhotoView.image = editedImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func changeProfilePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Profile Photo", message: "", preferredStyle: .actionSheet)
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
    
    @IBAction func saveChanges(_ sender: UIButton) {
        if let name = nameField.text{
            user?.setObject(name, forKey: "Name")
        }
        if let about = aboutField.text {
            user?.setObject(about, forKey: "About")
        }
        if let image = profilePhotoView.image {
            let profilePhoto = getPFFileFromImage(image: resize(image:image, newSize: CGSize(width: 500, height: 500)))
            user?.setObject(profilePhoto as Any, forKey: "ProfilePhoto")
        }
        user?.saveInBackground() { (success: Bool, error: Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Updated user info")
            }
            
        }
        self.navigationController?.popViewController(animated: true)
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
