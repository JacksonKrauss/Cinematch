//
//  SignUpViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Firebase
import FirebaseDatabase
class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // the reference for the Firebase Database
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpDidPress(_ sender: Any) {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmedPassword = confirmPasswordTextField.text,
              password.count > 0,
              confirmedPassword.count > 0,
              password == confirmedPassword
        else {
            return
        }
        
        // user is tied to their email, first name, and last name
        let newUserInfo = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        let newUser = self.ref.child("user_info").child(username)
        newUser.setValue(newUserInfo)
        
        // after sign in, user is automatically logged in
        Auth.auth().createUser(withEmail: email, password: password) {
            user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: email, password: password)
            }
        }
    }
    
    // programmatic back button 
    @IBAction func backButtonDidPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
