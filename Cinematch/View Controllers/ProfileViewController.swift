//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import FirebaseDatabase

// tiny protocol to update profile picture from settings view
protocol updateProfilePicture {
    func updateProfilePicture(image: UIImage)
}

class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, updateProfilePicture {
    var ref: DatabaseReference!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentUser = CURRENT_USER
    let PROFILE_CELL_IDENTIFIER = "profileCollectionViewCell"
    
    let userMovieData = [CURRENT_USER.liked, CURRENT_USER.watchlist]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = CURRENT_USER // kind of weird, but for some reason default sarab info will show up if this line is not here - figure out later
    
        renderViews()
        
        // make the profile picture fit in the circle
        if profilePicture.frame.width > profilePicture.frame.height {
            profilePicture.contentMode = .scaleAspectFit
        } else {
            profilePicture.contentMode = .scaleAspectFill
        }
    }
    
    func renderViews() {
        usernameTextLabel.text = currentUser.username
        fullNameTextLabel.text = currentUser.name
        bioTextLabel.text = currentUser.bio
        profilePicture.image = currentUser.profilePicture
        profilePicture.layer.cornerRadius = 100 / 2 // fix
    }
    
    // function to update profile picture from settings view
    func updateProfilePicture(image: UIImage) {
        profilePicture.image = image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue",
           let nextVC = segue.destination as? SettingsViewController {
            nextVC.delegate = self
        }
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
