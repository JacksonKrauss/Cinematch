//
//  FriendProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class FriendProfileViewController: UIViewController {
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func changeFriendStatus(_ sender: Any) {
    }
}
