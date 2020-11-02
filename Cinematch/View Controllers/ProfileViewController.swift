//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import FirebaseDatabase

class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    var ref: DatabaseReference!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    // ask about making a consistent class for pfp
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentUser = CURRENT_USER
    let PROFILE_CELL_IDENTIFIER = "profileCollectionViewCell"
    
    let userMovieData = [CURRENT_USER.liked, CURRENT_USER.watchlist]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("user_info").child(self.currentUser.username!).observe(.value) { (snapshot) in
            let updatedUser = User(snapshot, self.currentUser.username!)
            CURRENT_USER = updatedUser
            self.currentUser = updatedUser
            
            self.renderViews()
        }
                
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        renderViews()
        
        profilePicture.image = currentUser.profilePicture
    }
    
    func renderViews() {
        usernameTextLabel.text = currentUser.username
        fullNameTextLabel.text = currentUser.name
        bioTextLabel.text = currentUser.bio
        profilePicture.image = currentUser.profilePicture
        profilePicture.layer.cornerRadius = 100 / 2 // fix
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
