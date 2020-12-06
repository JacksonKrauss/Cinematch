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
        let storage = Storage.storage()

        let storageRef = storage.reference()
        let reference = storageRef.child(picturePath)

        let placeholderImage = UIImage(named: "image-placeholder")

        profilePicture.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
}
