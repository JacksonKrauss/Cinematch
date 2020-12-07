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
    @IBOutlet weak var errorLabel: UILabel!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginDidPress(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              username.count > 0,
              password.count > 0
        else {
            if usernameTextField.text?.count == 0 {
                errorLabel.text = "Username field is empty."
            } else {
                errorLabel.text = "Password field is empty."
            }
            return
        }
        
        ref.child("user_info").child(username).observeSingleEvent(of: .value, with: {
            snapshot in
            if !snapshot.exists() {
                self.errorLabel.text = "An error occured while attempting to log in."
                return
            }
            // if the username exists, log the user in with the associated email
            if let email = snapshot.childSnapshot(forPath: "email").value as? String {
                Auth.auth().signIn(withEmail: email, password: password) {
                    user, error in
                    if error == nil {
                        // current user is one associated with this username
                        CURRENT_USER = User(snapshot, username)
                        
                        let pfpRef = Storage.storage().reference(withPath: "profile_pictures/\(username)")
                        pfpRef.getData(maxSize: 1024 * 1024) { (data, error) in
                            if error != nil {
                                // error in getting profile picture
                                CURRENT_USER.profilePicture = UIImage(named: "image-placeholder")!
                            } else {
                                if let image = UIImage(data: data!) {
                                    // profile picture exists
                                    CURRENT_USER.profilePicture = image
                                } else {
                                    print("Should not have been able to get here")
                                }
                            }
                        }
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    } else {
                        self.errorLabel.text = "An error occured while attempting to log in."
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
