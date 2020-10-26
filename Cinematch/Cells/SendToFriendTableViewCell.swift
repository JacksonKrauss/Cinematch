//
//  SendToFriendTableViewCell.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/18/20.
//

import UIKit

class SendToFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }

}
