//
//  FriendListViewCell.swift
//  Cinematch
//
//  Created by Kyle Knight on 10/19/20.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class FriendListViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var positionInList = 0
    
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
