//
//  FriendProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    let FRIEND_PROFILE_CELL_IDENTIFIER = "friendProfileViewCell"
    
    var user:User = User()
    var userMoviesData:[Movie] = []
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        profilePicture.image = user.profilePicture
        usernameTextLabel.text = user.username
        fullNameTextLabel.text = user.name
        bioTextLabel.text = user.bio
        userMoviesData = user.liked
        
        profilePicture.layer.cornerRadius = 125 / 2 // fix this jank
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userMoviesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_PROFILE_CELL_IDENTIFIER, for:indexPath) as! FriendProfileViewCell
        let cellData = userMoviesData[indexPath.row]
        cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + (cellData.poster!))!)
        
        return cell
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
        // add to friend requests
        var currentUser:User? = nil
        var currentUsername:String? = nil
        ref = Database.database().reference()
        
        if Auth.auth().currentUser != nil {
            let currentUserAuth = Auth.auth().currentUser!
            
            print("user signed in. email: ")
            
            
            ref.child("uid").child(currentUserAuth.uid).observeSingleEvent(of: .value) { [self] (snapshot) in
                currentUsername = snapshot.value as? String
                ref.child("user_info").child(currentUsername!).observeSingleEvent(of: .value) { (snapshot) in
                    currentUser = User(snapshot, currentUsername!)
                    // add friend
                    
                    ref.child("friend_request").child(user.username!).child((currentUser?.username!)!).setValue(true)
                    
                    // success
                    
                }
                
            }
            
            
            
        } else {
          print("no user is signed in ")
        }
        
    }
}
