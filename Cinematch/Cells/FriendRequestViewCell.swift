//
//  FriendRequestViewCell.swift
//  Cinematch
//
//  Created by Kyle Knight on 10/19/20.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class FriendRequestViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addFriend: UIImageView!
    @IBOutlet weak var rejectFriend: UIImageView!
    
    var positionInList = 0
    var currentUser:User? = nil
    var friendRequestUser:User? = nil
    var ref: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ref = Database.database().reference()
        
        addFriend.isUserInteractionEnabled = true
        rejectFriend.isUserInteractionEnabled = true
        let addFriendTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addFriend(gestureRecognizer:)))
        addFriend.addGestureRecognizer(addFriendTapRecognizer)
        
        let removeFriendTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeFriend(gestureRecognizer:)))
        
        rejectFriend.addGestureRecognizer(removeFriendTapRecognizer)
    }
    
    // User hit the checkmark to add this friend
    @objc func addFriend(gestureRecognizer: UITapGestureRecognizer) {
        // remove request by setting value to false
        self.ref.child("friend_request").child((currentUser?.username!)!).child((friendRequestUser?.username)!).setValue(false)
        
        // make current user a friend of the requesting user
        self.ref.child("friends").child((currentUser?.username!)!).child((friendRequestUser?.username)!).setValue(true)
        // make requesting user a friend of the requesting user
        self.ref.child("friends").child((friendRequestUser?.username)!).child((currentUser?.username!)!).setValue(true)
    }
    
    // User hit the X to remove this friend request
    @objc func removeFriend(gestureRecognizer: UITapGestureRecognizer) {
        // remove request by setting value to false
        self.ref.child("friend_request").child((currentUser?.username!)!).child((friendRequestUser?.username)!).setValue(false)
    }
    
    func loadProfilePicture(_ picturePath:String) {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child(picturePath)

        // Placeholder image
        let placeholderImage = UIImage(named: "image-placeholder")

        // Load the image using SDWebImage
        profilePicture.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
}
