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
        //now you need a tap gesture recognizer
        //note that target and action point to what happens when the action is recognized.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gestureRecognizer:)))
        //Add the recognizer to your view.
        addFriend.addGestureRecognizer(tapRecognizer)
        
        let removeTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappedRemove(gestureRecognizer:)))
        
        rejectFriend.addGestureRecognizer(removeTapRecognizer)
    }
    
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        self.ref.child("friend_request").child((currentUser?.username!)!).child((friendRequestUser?.username)!).setValue(false)
        self.ref.child("friends").child((currentUser?.username!)!).child((friendRequestUser?.username)!).setValue(true)
    }
    
    @objc func imageTappedRemove(gestureRecognizer: UITapGestureRecognizer) {
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
