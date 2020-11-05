//
//  FriendProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Koloda
class FriendProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: userMoviesData[index]){
            self.collectionView.reloadData()
        }
    }
    
    func reload() {
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var friendStatusButton: UIButton!
    let FRIEND_PROFILE_CELL_IDENTIFIER = "friendProfileViewCell"
    
    var user:User = User()
    var userMoviesData:[Movie] = []
    var numMoviesUpdated = 0
    var expectedNumMoviesUpdated = 0
    var userIsFriend = false
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        profilePicture.layer.cornerRadius = 125 / 2 // fix this jank
        
        ref = Database.database().reference()
    }
    
    func updateFriendMovies(_ moviesFB:[MovieFB]) {
        userMoviesData.removeAll()
        var i = 0
        for mFB in moviesFB {
            i += 1
            Movie.getMovieFromFB(movieFB: mFB) { (m) in
                self.userMoviesData.append(m)
                self.numMoviesUpdated += 1
                
                if self.numMoviesUpdated == self.expectedNumMoviesUpdated {
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref.child("friends").child(CURRENT_USER.username!).child(user.username!).observeSingleEvent(of: .value) { (snapshot) in
            let friendValue = snapshot.value
            if let value = friendValue {
                if !(value is NSNull) {
                    if value as! Bool == true {
                        self.friend()
                    }
                }
            }
        }
        
        usernameTextLabel.text = user.username
        fullNameTextLabel.text = user.name
        bioTextLabel.text = user.bio
        userMoviesData = user.liked
        loadProfilePicture()
        if self.profilePicture.frame.width > self.profilePicture.frame.height {
            self.profilePicture.contentMode = .scaleAspectFit
        } else {
            self.profilePicture.contentMode = .scaleAspectFill
        }
        
        ref.child("movies").child(user.username!).observeSingleEvent(of: .value, with: { (snapshot) in
            Movie.getMoviesForUser(username: self.user.username!) { (moviesFBList) in
                let moviesFB = moviesFBList.filter({ (movie) -> Bool in
                    return movie.opinion != Opinion.like
                })
                self.expectedNumMoviesUpdated = moviesFB.count
                self.updateFriendMovies(moviesFB)
            }
        })
    }
    
    func friend() {
        self.friendStatusButton.setTitle("Unfriend", for: .normal)
        self.userIsFriend = true
    }
    
    func unfriend() {
        self.friendStatusButton.setTitle("Friend", for: .normal)
        self.userIsFriend = false
    }
    
    func loadProfilePicture() {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child("profile_pictures/" + user.username!)

        // Placeholder image
        let placeholderImage = UIImage(named: "image-placeholder")

        // Load the image using SDWebImage
        profilePicture.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userMoviesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_PROFILE_CELL_IDENTIFIER, for:indexPath) as! FriendProfileViewCell
        let cellData = userMoviesData[indexPath.row]
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "friendMovieDetail", sender: indexPath.row)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendMovieDetail"{
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = userMoviesData[index]
                detailViewController.currentIndex = index
            }
        }
    }

    @IBAction func changeFriendStatus(_ sender: Any) {
        // add to friend requests
        var currentUser:User? = nil
        var currentUsername:String? = nil
        
        currentUsername = CURRENT_USER.username
        
        ref.child("user_info").child(currentUsername!).observeSingleEvent(of: .value) { (snapshot) in
            currentUser = User(snapshot, currentUsername!)
            if self.userIsFriend {
                // remove friend
                self.ref.child("friends").child(currentUsername!).child(self.user.username!).setValue(false)
                self.ref.child("friends").child(self.user.username!).child(currentUsername!).setValue(false)
                
                self.unfriend()
            } else {
                // add friend
                self.ref.child("friend_request").child(self.user.username!).child((currentUser?.username!)!).setValue(true)
                
                self.friend()
            }
            
        }

        
    }
}
