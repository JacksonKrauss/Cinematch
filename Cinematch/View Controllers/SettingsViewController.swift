//
//  SettingsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var bioTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var privacySegControl: UISegmentedControl!
    
    @IBOutlet weak var appearanceSegControl: UISegmentedControl!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func editImagePressed(_ sender: Any) {
        print("Editing Image")
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        //Figure this out
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
