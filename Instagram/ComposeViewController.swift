//
//  ComposeViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var chosenPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = chosenPhoto
        
        chosenPhoto = resize(image: chosenPhoto!, newSize: CGSize(width: 1000, height: 1000))
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func post(_ sender: UIButton) {
        let caption = captionField.text ?? ""
        Post.postUserImage(image: chosenPhoto, withCaption: caption) { (success: Bool, error: Error?)-> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: sender)
            }
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
