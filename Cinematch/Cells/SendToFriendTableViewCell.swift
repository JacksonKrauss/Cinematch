//
//  SendToFriendTableViewCell.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/18/20.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class SendToFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Util.makeImageCircular(profilePicView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }
    
    func loadProfilePicture(_ picturePath:String) {
        let storage = Storage.storage()

        let storageRef = storage.reference()
        let reference = storageRef.child(picturePath)

        let placeholderImage = UIImage(named: "image-placeholder")

        profilePicView.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
}
