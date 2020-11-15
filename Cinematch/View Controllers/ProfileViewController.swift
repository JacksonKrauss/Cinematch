//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import FirebaseDatabase
protocol updateProfile {
    func updateProfilePicture(image: UIImage)
    func updateProfileTextFields(username: String, name: String, bio: String)
    func updateProfileColors()
}
class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, SwipeDelegate, updateProfile {
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: movieData[index]){
            self.collectionView.reloadData()
        }
        
    }
    
    func reload() {
        //collectionView.reloadData()
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var movieData: [Movie] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = CURRENT_USER
        usernameTextLabel.text = currentUser.username
        fullNameTextLabel.text = currentUser.name
        bioTextLabel.text = currentUser.bio
        profilePicture.image = currentUser.profilePicture
        profilePicture.layer.cornerRadius = 100 / 2 // fix
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    var currentUser: User!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = CURRENT_USER // kind of weird, but for some reason default sarab info will show up if this line is not here - figure out later
        collectionView.reloadData()
        renderViews()
        setColors(CURRENT_USER.visualMode, self.view)
        
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
    
    // function to update profile settings from settings view
    func updateProfilePicture(image: UIImage) {
        profilePicture.image = image
    }
    
    func updateProfileTextFields(username: String, name: String, bio: String) {
        usernameTextLabel.text = username
        fullNameTextLabel.text = name
        bioTextLabel.text = bio
    }
    
    func updateProfileColors() {
        setColors(CURRENT_USER.visualMode, self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue",
           let nextVC = segue.destination as? SettingsViewController {
            nextVC.delegate = self
        }
        if(segue.identifier == "profileDetailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = movieData[index]
                detailViewController.currentIndex = index
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            return CURRENT_USER.liked.count
        case 1:
            return CURRENT_USER.history.count
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profileDetailSegue", sender: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"profileCollectionViewCell", for:indexPath) as! ProfileCollectionViewCell
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            cell.historyView.isHidden = true
            movieData = CURRENT_USER.liked
        case 1:
            cell.historyView.isHidden = false
            movieData = CURRENT_USER.history.reversed()
            switch movieData[indexPath.row].opinion {
            case .like:
                cell.historyView.image = UIImage(systemName: "hand.thumbsup.fill")
                cell.historyView.tintColor = .systemGreen
            case .dislike:
                cell.historyView.image = UIImage(systemName: "hand.thumbsdown.fill")
                cell.historyView.tintColor = .systemRed
            case .watchlist:
                cell.historyView.image = UIImage(systemName: "plus.app.fill")
                cell.historyView.tintColor = .systemBlue
            default:
                print("No opinion")
            }
        default:
            break
        }
        if(movieData[indexPath.row].posterImg == nil){
            if(movieData[indexPath.row].poster == nil){
                cell.moviePoster.backgroundColor = .white
                cell.moviePoster.image = UIImage(named: "no-image")
                movieData[indexPath.row].posterImg = UIImage(named: "no-image")
            }
            else{
                cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + movieData[indexPath.row].poster!)!)
            }
        }
        else{
            cell.moviePoster.image = movieData[indexPath.row].posterImg!
        }
        
        return cell
    }
    @IBAction func movieViewSelected(_ sender: Any) {
        self.collectionView.reloadData()
    }
    
}
