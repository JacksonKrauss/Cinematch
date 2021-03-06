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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    // the reference for the Firebase Database
    let ref = Database.database().reference()
    var allUsernames:Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get list of used usernames and check client-side
        // to be secure, this needs to be checked server-side
        ref.child("user_info").observe(.value) { (snapshot) in
            self.allUsernames.removeAll()
            for user in snapshot.children {
                let userSnapshot:DataSnapshot = user as! DataSnapshot
                self.allUsernames.insert(userSnapshot.key)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // needed due to bug when typing in passwords, field locks up with autofill and
        // a strong password error pops up
        super.viewWillAppear(animated)
        if #available(iOS 12, *) {
            confirmPasswordTextField.textContentType = .oneTimeCode
            passwordTextField.textContentType = .oneTimeCode
        } else {     // iOS 11: Disables the autofill accessory view.
            emailTextField.textContentType = .init(rawValue: "")
            confirmPasswordTextField.textContentType = .init(rawValue: "")
            passwordTextField.textContentType = .init(rawValue: "")
        }
    }
    
    @IBAction func signUpDidPress(_ sender: Any) {
        // check if the fields have something in them and pass requirements
        guard let name = nameTextField.text,
              let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmedPassword = confirmPasswordTextField.text,
              name.count > 0,
              username.count > 0,
              email.count > 0,
              password.count >= 6,
              confirmedPassword.count >= 6,
              password == confirmedPassword,
              !allUsernames.contains(username)
        else {
            let fieldStr = "field is empty."
            if nameTextField.text?.count == 0 {
                errorLabel.text = "Name \(fieldStr)"
            } else if usernameTextField.text?.count == 0 {
                errorLabel.text = "Username \(fieldStr)"
            } else if emailTextField.text?.count == 0 {
                errorLabel.text = "Email \(fieldStr)"
            } else if passwordTextField.text?.count == 0 {
                errorLabel.text = "Password \(fieldStr)"
            } else if confirmPasswordTextField.text?.count == 0 {
                errorLabel.text = "Confirm Password \(fieldStr)"
            }
            else if passwordTextField.text?.count ?? 0 < 6 {
                errorLabel.text = "Password needs 6 or more characters"
            } else if confirmPasswordTextField.text?.count ?? 0 < 6 {
                errorLabel.text = "Confirm Password needs 6 or more characters"
            }
            if passwordTextField.text! != confirmPasswordTextField.text {
                errorLabel.text = "Passwords do not match."
            }
            if allUsernames.contains(usernameTextField.text!) {
                errorLabel.text = "Username already in use!"
            }
            return
        }
        
        // user is tied to their email, first name, and last name
        //add movie list
        let newUserInfo = [
            "name": name,
            "email": email,
            "bio": "",
            "privacy": "friends",
            "visual_mode": "light"
        ]
        
        // after sign in, user is automatically logged in
        Auth.auth().createUser(withEmail: email, password: password) {
            user, error in
            if error == nil {
                // cannot use snapshot init because snapshot does not exist
                CURRENT_USER = User(name: name,
                                    username: username,
                                    bio: "",
                                    email: email,
                                    privacy: UserPrivacy.friends,
                                    visualMode: VisualMode.light,
                                    profilePicture: UIImage(named: "image-placeholder")!,
                                    liked:[],
                                    disliked: [],
                                    watchlist: [],
                                    history: [])
                let newUser = self.ref.child("user_info").child(username)
                newUser.setValue(newUserInfo)
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let strongSelf = self else { print("failed to create uid to username map!");
                        return }
                    // map the user's UID to their username in the database
                    if let newlyCreatedUID = authResult?.user.uid {
                        strongSelf.ref.child("uid").child(newlyCreatedUID).setValue(username)
                    }
                  }
                self.performSegue(withIdentifier: "signUpSegue", sender: nil)
            } else {
                self.errorLabel.text = "An error occured while attempting to sign in."
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
