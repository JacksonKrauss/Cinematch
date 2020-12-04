//
//  DetailTableViewCell.swift
//  Cinematch
//
//  Created by Jackson Krauss on 11/12/20.
//

import UIKit
import TMDBSwift
class DetailTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(index! == 0){
            return DetailTableViewCell.movieTable!.actors.count/2
        }
        else{
            return DetailTableViewCell.movieTable!.friends!.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(index! == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorCollectionViewCell
            cell.actorLabel.text = DetailTableViewCell.movieTable!.actors[indexPath.row].actorName
            cell.characterLabel.text = DetailTableViewCell.movieTable!.actors[indexPath.row].characterName
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendOpCell", for: indexPath) as! FriendOpCollectionViewCell
            cell.nameLabel.text = DetailTableViewCell.movieTable!.friends![indexPath.row].user.username!
            switch DetailTableViewCell.movieTable!.friends![indexPath.row].opinion {
            case .like:
                cell.opinionImageView.image = UIImage(systemName: "hand.thumbsup.fill")
                cell.opinionImageView.tintColor = .systemGreen
            case .dislike:
                cell.opinionImageView.image = UIImage(systemName: "hand.thumbsdown.fill")
                cell.opinionImageView.tintColor = .systemRed
            case .watchlist:
                cell.opinionImageView.image = UIImage(systemName: "plus.app.fill")
                cell.opinionImageView.tintColor = .systemBlue
            case .none:
                cell.opinionImageView.isHidden = true
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (index! == 0) {
            let actorCell = cell as! ActorCollectionViewCell
            actorCell.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.white : darkModeBackground
            actorCell.actorLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
            actorCell.characterLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
        } else {
            let friendCell = cell as! FriendOpCollectionViewCell
            friendCell.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.white : darkModeBackground
            friendCell.nameLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
        }
    }
    
    static var movieTable: Movie?
    var index: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        MovieMDB.credits(movieID: DetailTableViewCell.movieTable!.id){
            apiReturn, credits in
            if let credits = credits{
                for cast in credits.cast{
                    DetailTableViewCell.movieTable!.actors.append(Actor(actorName: cast.name, characterName: cast.character))
                }
                Movie.checkFriendOpinion(id: DetailTableViewCell.movieTable!.id!) { (friendMovies) in
                    DetailTableViewCell.movieTable!.friends = friendMovies
                    self.collectionView.delegate = self
                    self.collectionView.dataSource = self
                    print(DetailTableViewCell.movieTable!.actors.count)
                    print(DetailTableViewCell.movieTable!.friends!.count)
                }
            }
        }
        // Initialization code
        collectionView.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.white : darkModeBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
