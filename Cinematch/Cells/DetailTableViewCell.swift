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
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorCollectionViewCell
        if(index! == 0){
            cell.actorLabel.text = DetailTableViewCell.movieTable!.actors[indexPath.row].actorName
            cell.characterLabel.text = DetailTableViewCell.movieTable!.actors[indexPath.row].characterName
        }
        else{
            cell.actorLabel.text = "hi"
            cell.characterLabel.text = "bye"
        }
        return cell
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
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                print(DetailTableViewCell.movieTable!.actors.count)
            }
        }
        

        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
