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
        //return movie!.actors.count
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorCollectionViewCell
//        cell.actorLabel.text = movie!.actors[indexPath.row].actorName
//        cell.characterLabel.text = movie!.actors[indexPath.row].characterName
        cell.actorLabel.text = "Hi"
        cell.characterLabel.text = "Bye"
        return cell
    }
    var movie: Movie?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
