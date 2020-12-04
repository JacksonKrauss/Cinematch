//
//  SettingsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var privacySegControl: UISegmentedControl!
    @IBOutlet weak var appearanceSegControl: UISegmentedControl!
    @IBOutlet weak var profileImage: UIImageView!
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        passwordTextField.delegate = self
        bioTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBAction func appearanceSelect(_ sender: Any) {
        switch appearanceSegControl.selectedSegmentIndex {
        case 0:
            setColors(VisualMode.light, self.view)
        case 1:
            setColors(VisualMode.dark, self.view)
        default:
            print("Error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set the current user fields for this view controller
        super.viewWillAppear(animated)
        
        if #available(iOS 12, *) {     // iOS 12 & 13: Not the best solution, but it works.
            passwordTextField.textContentType = .oneTimeCode
        } else {     // iOS 11: Disables the autofill accessory view.
            emailTextField.textContentType = .init(rawValue: "")
            passwordTextField.textContentType = .init(rawValue: "")
        }
        
        nameTextField.text = CURRENT_USER.name
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
            setColors(CURRENT_USER.visualMode, self.view)
            break
        }
        
        profileImage.image = CURRENT_USER.profilePicture
        if self.profileImage.frame.width > self.profileImage.frame.height {
            self.profileImage.contentMode = .scaleAspectFit
        } else {
            self.profileImage.contentMode = .scaleAspectFill
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let bio = bioTextField.text,
              let email = emailTextField.text
        else {
            return
        }
        
        let privacyIndex = privacySegControl.selectedSegmentIndex
        let visualIndex = appearanceSegControl.selectedSegmentIndex
        
        let userRef = ref.child("user_info").child(CURRENT_USER.username!)
        
        // updated values do not include username
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
            break
        default:
            selectedPrivacy = .friends
        }
        if selectedPrivacy != CURRENT_USER.privacy {
            CURRENT_USER.privacy = selectedPrivacy
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
            CURRENT_USER.visualMode = selectedVisual
        }
        
        if email != CURRENT_USER.email {
            Auth.auth().currentUser?.updateEmail(to: email) { error in
                if error == nil {
                    CURRENT_USER.email = email
                    updateUserValues.updateValue(email, forKey: "email")
                } else {
                    print(error)
                }
            }
        }
        
        if password.count != 0 {
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                if error != nil {
                    print(error)
                }
            }
        }
        saveProfilePictureToStorage()
        userRef.updateChildValues(updateUserValues)
        
        let otherVC = delegate as! updateProfile
        otherVC.updateProfileTextFields(name: name, bio: bio)
        otherVC.updateProfileColors()
    }
    
    // user wants to edit profile picture with photos from photo library
    @IBAction func editImagePressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
    
    // user has selected a photo, updates photo for settings view
    func imagePickerController(_ picker: UIImagePickerController,
          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = image
            if self.profileImage.frame.width > self.profileImage.frame.height {
                self.profileImage.contentMode = .scaleAspectFit
            } else {
                self.profileImage.contentMode = .scaleAspectFill
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // save the selected profile picture to firebase storage
    func saveProfilePictureToStorage() {
        CURRENT_USER.profilePicture = profileImage.image
        
        // if the profile picture already exists, delete it
        let profileRef = storageRef.child("profile_pictures/" + CURRENT_USER.username!)
        profileRef.delete() {
            error in
            if let error = error {
                guard let errorCode = (error as NSError?)?.code else {
                    return
                }
                guard let err = StorageErrorCode(rawValue: errorCode) else {
                    return
                }
                switch err {
                case .objectNotFound:
                    print("Correct error returned")
                    break
                default:
                    print("Uh oh, some other error returned")
                    return
                }
            }
        }
        
        // upload the new profile picture (resized smaller if needed) to firebase storage
        if let uploadData = profileImage.image!.resized(toWidth: 200.0)?.pngData() {
            profileRef.putData(uploadData, metadata: nil) {
                metadata, error in
                if error != nil {
                    print(error)
                }
            }
        }
        
        // update profile picture in profile view
        let otherVC = delegate as! updateProfile
        otherVC.updateProfilePicture(image: CURRENT_USER.profilePicture!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var countLimit = 10
        
        switch textField {
        case passwordTextField:
            countLimit = 20
            break
        case nameTextField:
            countLimit = 20
            break
        case bioTextField:
            countLimit = 75
            break
        case emailTextField:
            countLimit = 75
            break
        default:
            break
        }
        
        if textField == passwordTextField {
            countLimit = 20
        }
        
        let nsString = NSString(string: textField.text!)
        let newText = nsString.replacingCharacters(in: range, with: string)
        return  newText.count <= countLimit
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        CURRENT_USER = User(name: "defaultName",
                            username: "defaultUsername",
                            bio: "defaultBio",
                            email: "defaultEmail@email.com",
                            privacy: UserPrivacy.everyone,
                            visualMode: VisualMode.light,
                            profilePicture: UIImage(named: "Popcorn Logo")!,
                            liked: [],
                            disliked: [],
                            watchlist: [],
                            history: [])
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        // segue goes back to login/signup screen
        self.performSegue(withIdentifier: "unwindToStartView", sender: self)
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension UIImage {
    // function to resize image smaller if it is too big in firebase storage
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
