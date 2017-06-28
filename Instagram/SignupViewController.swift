//
//  SignupViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/28/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        // initialize a user object
        
        
        
        let email = emailField.text ?? ""
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        
        
        
        if email.isEmpty {
            let alertController = UIAlertController(title: "Email Required", message: "Please input email", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: {
                    self.usernameField.becomeFirstResponder()
                })
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true)
        }
        else if username.isEmpty {
            let alertController = UIAlertController(title: "Username Required", message: "Please input username", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: {
                    self.usernameField.becomeFirstResponder()
                })
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true)
        }
        else if password.isEmpty{
            let alertController = UIAlertController(title: "Password Required", message: "Please input password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: {
                    self.passwordField.becomeFirstResponder()
                })
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
            present(alertController, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "signupDetailsSegue", sender: nil)
        }
        
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsViewController = segue.destination as! SignupDetailsViewController
        let email = emailField.text ?? ""
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        detailsViewController.email = email
        detailsViewController.username = username
        detailsViewController.password = password
     }
    
}
