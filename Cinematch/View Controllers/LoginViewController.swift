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
              let password = passwordTextField.text,
              username.count > 0,
              password.count > 0
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
                        let pfpRef = Storage.storage().reference(withPath: "profile_pictures/\(username)")
                        
                        pfpRef.getData(maxSize: 600 * 600) { (data, error) in
                            if let error = error {
                                CURRENT_USER = User(name: (snapshot.childSnapshot(forPath: "name").value as? String)!,
                                                    username: username,
                                                    bio: (snapshot.childSnapshot(forPath: "bio").value as? String)!,
                                                    email: email,
                                                    privacy: stringToPrivacy(privacy: snapshot.childSnapshot(forPath: "privacy").value as? String ?? ""),
                                                    visualMode: stringToVisual(visualMode: snapshot.childSnapshot(forPath: "visual_mode").value as? String ?? ""),
                                                    profilePicture: UIImage(named: "Popcorn Logo")!,
                                                    liked:[],
                                                    disliked: [],
                                                    watchlist: [],
                                                    history: [])
                            } else {
                                if let image = UIImage(data: data!) {
                                    CURRENT_USER = User(name: (snapshot.childSnapshot(forPath: "name").value as? String)!,
                                                        username: username,
                                                        bio: (snapshot.childSnapshot(forPath: "bio").value as? String)!,
                                                        email: email,
                                                        privacy: stringToPrivacy(privacy: snapshot.childSnapshot(forPath: "privacy").value as? String ?? ""),
                                                        visualMode: stringToVisual(visualMode: snapshot.childSnapshot(forPath: "visual_mode").value as? String ?? ""),
                                                        profilePicture: image,
                                                        liked:[],
                                                        disliked: [],
                                                        watchlist: [],
                                                        history: [])
                                } else {
                                    print("Should not have been able to get here")
                                }
                            }
                            
                        }
                        
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
