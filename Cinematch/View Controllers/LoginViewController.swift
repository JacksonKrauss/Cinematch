//
//  LoginViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Firebase
import FirebaseDatabase
class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginDidPress(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text
        else {
            return
        }
        
        ref.child("user_info").child(username).observeSingleEvent(of: .value, with: {
            snapshot in
            if !snapshot.exists() {
                return
            }
            // if the username exists, log the user in with the associated email
            if let email = snapshot.childSnapshot(forPath: "email").value as? String {
                Auth.auth().signIn(withEmail: email, password: password) {
                    user, error in
                    if error == nil {
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
            }
        })
    }
    
    // programmatic back button
    @IBAction func backButtonDidPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}