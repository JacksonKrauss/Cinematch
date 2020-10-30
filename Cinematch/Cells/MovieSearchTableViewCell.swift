//
//  MovieSearchTableViewCell.swift
//  Cinematch
//
//  Created by Maegan Parfan on 10/20/20.
//

import UIKit

// class for table view cells when searching for movies
class MovieSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieReleaseLabel: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        moviePosterImageView.image = nil
        moviePosterImageView.backgroundColor = .white
    }
    
}
