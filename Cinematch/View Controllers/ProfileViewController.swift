//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    // ask about making a consistent class for pfp
    @IBOutlet weak var collectionView: UICollectionView!
    
    let currentUser = CURRENT_USER
    let PROFILE_CELL_IDENTIFIER = "profileCollectionViewCell"
    
    let userMovieData = [CURRENT_USER.liked, CURRENT_USER.watchlist]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextLabel.text = currentUser.username
        fullNameTextLabel.text = currentUser.name
        bioTextLabel.text = currentUser.bio
        profilePicture.image = currentUser.profilePicture
        profilePicture.layer.cornerRadius = 100 / 2 // fix
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userMovieData[movieViewSegCtrl.selectedSegmentIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:PROFILE_CELL_IDENTIFIER, for:indexPath) as! ProfileCollectionViewCell
        let cellData = userMovieData[movieViewSegCtrl.selectedSegmentIndex][indexPath.row]
        cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + (cellData.poster!))!)
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func movieViewSelected(_ sender: Any) {
        self.collectionView.reloadData()
    }
    
}