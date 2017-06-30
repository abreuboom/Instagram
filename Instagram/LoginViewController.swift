//
//  LoginViewController.swift
//  
//
//  Created by John Abreu on 6/27/17.
//
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName:UIColor.white])
        passwordField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        
        if username.isEmpty {
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
            PFUser.logInWithUsername(inBackground: username.trimmingCharacters(in: .whitespaces), password: password, block: { (user: PFUser?, error: Error?) in
                if let error = error {
                    print("User log in failed: \(error.localizedDescription)")
                } else {
                    print("User logged in successfully")
                    
                    // display view controller that needs to shown after successful login
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            })
        }

    }

    @IBAction func signUp(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: nil)
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
