//
//  ViewController.swift
//  DankApp
//
//  Created by Evan Chang on 16/09/17.
//  Copyright © 2017 Evan Chang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var loginImage: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToSignUp", sender: Any?.self)
    }
    
    func login() {
        guard let usernameTextField = usernameTextField.text else {
            print("Invalid email")
            return
        }
        guard let passwordTextField = passwordTextField.text else {
            print("Invalid password")
            return
        }
        Auth.auth().signIn(withEmail: usernameTextField, password: passwordTextField
            , completion: {(user, error) in
                if error != nil {
                    print(error!)
                    return
                } else {
                    self.performSegue(withIdentifier: "loginToHome", sender: Any?.self)
                }
                //self.dismiss(animated:true, completion:nil)
        })
    }
    
}

