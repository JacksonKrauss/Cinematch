//
//  ProfileTableViewCell.swift
//  Cinematch
//
//  Created by Maegan Parfan on 10/12/20.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var leftMoviePoster: UIImageView!
    @IBOutlet weak var middleMoviePoster: UIImageView!
    @IBOutlet weak var rightMoviePoster: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
