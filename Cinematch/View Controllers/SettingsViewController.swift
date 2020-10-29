//
//  SettingsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var bioTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var privacySegControl: UISegmentedControl!
    
    @IBOutlet weak var appearanceSegControl: UISegmentedControl!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextField.text = CURRENT_USER.name
        usernameTextField.text = CURRENT_USER.username
        bioTextField.text = CURRENT_USER.bio
        emailTextField.text = CURRENT_USER.email
        
        switch CURRENT_USER.privacy {
        case .me:
            privacySegControl.selectedSegmentIndex = 0
            break
        case .friends:
            privacySegControl.selectedSegmentIndex = 1
            break
        case .everyone:
            privacySegControl.selectedSegmentIndex = 2
        }
        
        switch CURRENT_USER.visualMode {
        case .light:
            appearanceSegControl.selectedSegmentIndex = 0
            break
        case .dark:
            appearanceSegControl.selectedSegmentIndex = 1
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let name = nameTextField.text,
              let username = usernameTextField.text,
              let bio = bioTextField.text,
              let email = emailTextField.text
        else {
            return
        }
        
        let privacyIndex = privacySegControl.selectedSegmentIndex
        let visualIndex = appearanceSegControl.selectedSegmentIndex
        
        let userRef = ref.child("user_info").child(CURRENT_USER.username!)
        
        if username == CURRENT_USER.username {
            // just update children
            // if email changes, update email in sign in
            var updateUserValues: [String:String] = [:]
            if name != CURRENT_USER.name {
                updateUserValues.updateValue(name, forKey: "name")
                CURRENT_USER.name = name
            }
            if bio != CURRENT_USER.bio {
                updateUserValues.updateValue(bio, forKey: "bio")
                CURRENT_USER.bio = bio
            }
            
            var selectedPrivacy: UserPrivacy
            switch privacyIndex {
            case 0:
                selectedPrivacy = .me
                break
            case 1:
                selectedPrivacy = .friends
                break
            case 2:
                selectedPrivacy = .everyone
            default:
                selectedPrivacy = .friends
            }
            if selectedPrivacy != CURRENT_USER.privacy {
                updateUserValues.updateValue(privacyToString(privacy: selectedPrivacy), forKey: "privacy")
            }
            
            var selectedVisual: VisualMode
            switch visualIndex {
            case 0:
                selectedVisual = .light
                break
            case 1:
                selectedVisual = .dark
                break
            default:
                selectedVisual = .light
            }
            if selectedVisual != CURRENT_USER.visualMode {
                updateUserValues.updateValue(visualToString(visualMode: selectedVisual), forKey: "visual_mode")
            }
            
            if email != CURRENT_USER.email {
                updateUserValues.updateValue(email, forKey: "email")
                CURRENT_USER.email = email
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                  print(error)
                }
            }
            userRef.updateChildValues(updateUserValues)
        } else {
            print("in else")
            // have to create new node
            var userValues:[String:String] = [:]
            
            userValues.updateValue(name, forKey: "name")
            CURRENT_USER.name = name
            
            userValues.updateValue(bio, forKey: "bio")
            CURRENT_USER.bio = bio
            
            var selectedPrivacy: String
            switch privacyIndex {
            case 0:
                selectedPrivacy = "me"
                CURRENT_USER.privacy = .me
                break
            case 1:
                selectedPrivacy = "friends"
                CURRENT_USER.privacy = .friends
                break
            case 2:
                selectedPrivacy = "everyone"
                CURRENT_USER.privacy = .everyone
                break
            default:
                selectedPrivacy = ""
            }
            
            userValues.updateValue(selectedPrivacy, forKey: "privacy")
            var selectedVisual: String
            switch visualIndex {
            case 0:
                selectedVisual = "light"
                CURRENT_USER.visualMode = .light
                break
            case 1:
                selectedVisual = "dark"
                CURRENT_USER.visualMode = .dark
                break
            default:
                selectedVisual = ""
            }
            userValues.updateValue(selectedVisual, forKey: "visual_mode")
            
            if email != CURRENT_USER.email {
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                    print(error)
                }
            }
            userValues.updateValue(email, forKey: "email")
            
            userRef.removeValue()
            
            ref.child("user_info").child(username).setValue(userValues)
            
            CURRENT_USER.username = username
        }
    }
    
    @IBAction func editImagePressed(_ sender: Any) {
        print("Editing Image")
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        //Figure this out
        // set CURRENT_USER to nil, segue to initial screen?
        // Auth.auth().signOut() or something like that
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

        
        //self.view.window?.rootViewController?.presentedViewController!.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
