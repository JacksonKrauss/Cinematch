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

enum FriendStatus {
    case Friend
    case Requested
    case RequestedMe
    case NotFriend
}

class FriendProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, SwipeDelegate {
    
    //adds the movie to the correct list
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: userMoviesData[index]){
        }
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var friendStatusButton: UIButton!
    let FRIEND_PROFILE_CELL_IDENTIFIER = "friendProfileViewCell"
    
    var user:User = User()
    var userMoviesData:[Movie] = []
    var numMoviesUpdated = 0
    var expectedNumMoviesUpdated = 0
    
    // default to not a friend
    var userFriendStatus:FriendStatus = FriendStatus.NotFriend
    
    var privacy: UserPrivacy!
    var ref: DatabaseReference!
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Util.makeImageCircular(profilePicture)
        
        ref = Database.database().reference()
    }
    
    func updateFriendMovies(_ moviesFB:[MovieFB]) {
        userMoviesData.removeAll()
        var i = 0
        for mFB in moviesFB {
            i += 1
            Movie.getMovieFromFB(id: mFB.id, opinion: mFB.opinion,recommended: "") { (m) in
                self.userMoviesData.append(m)
                self.numMoviesUpdated += 1
                
                if self.numMoviesUpdated == self.expectedNumMoviesUpdated {
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check the current friend value and update state accordingly
        ref.child("friends").child(CURRENT_USER.username!).child(user.username!).observeSingleEvent(of: .value) { (snapshot) in
            let friendValue = snapshot.value
            if let value = friendValue {
                if (!(value is NSNull) && (value as! Bool == true)) {
                    self.friend()
                } else {
                    self.notFriend()
                }
            }
        }
        
        // Update the view with this friend's basic information
        usernameTextLabel.text = user.username
        fullNameTextLabel.text = user.name
        bioTextLabel.text = user.bio
        userMoviesData = user.liked
        privacy = user.privacy
        loadProfilePicture()
        
        // Get this user's liked movies from firebase
        ref.child("movies").child(user.username!).observeSingleEvent(of: .value, with: { (snapshot) in
            Movie.getMoviesForUser(username: self.user.username!) { (moviesFBList) in
                let moviesFB = moviesFBList.filter({ (movie) -> Bool in
                    return movie.opinion == Opinion.like
                })
                self.expectedNumMoviesUpdated = moviesFB.count
                self.updateFriendMovies(moviesFB)
            }
        })
        
        setColors(CURRENT_USER.visualMode, self.view)
        self.queryFriendInformation()
        
        if (CURRENT_USER.visualMode == VisualMode.light) {
            self.friendStatusButton.setTitleColor(UIColor.white, for: .normal)
            self.friendStatusButton.backgroundColor = darkModeBackground
        } else {
            self.friendStatusButton.setTitleColor(UIColor.label, for: .normal)
            self.friendStatusButton.backgroundColor = UIColor.white
        }
        
        // Special case: hide action button if this is your profile page
        if user == CURRENT_USER {
            friendStatusButton.isHidden = true
        } else {
            friendStatusButton.isHidden = false
        }
    }
    
    func queryRequestInformation() {
        // the user is not a friend
        // check if i requested them
        ref.child("friend_request").child(user.username!).child(CURRENT_USER.username!).observeSingleEvent(of: .value) { (snapshot) in
            let requestValue = snapshot.value
            if let value = requestValue {
                if !(value is NSNull) {
                    if value as! Bool == true {
                        self.requested()
                    } else if value as! Bool == false {
                        self.notFriend()
                    } else {
                        print("Invalid state reached when fetching friend request boolean!")
                    }
                    self.checkIfUserRequestedMe()
                } else {
                    print("i did not request")
                    self.notFriend()
                    self.checkIfUserRequestedMe()
                }
            }
        }
        
    }
    
    func checkIfUserRequestedMe() {
        // check if they requested me
        ref.child("friend_request").child(CURRENT_USER.username!).child(user.username!).observeSingleEvent(of: .value) { (snapshot) in
            let requestValue = snapshot.value
            if let value = requestValue {
                if !(value is NSNull) {
                    if value as! Bool == true {
                        self.requestedMe()
                    } else if value as! Bool == false {
                        if self.userFriendStatus != FriendStatus.Requested {
                            self.notFriend()
                        }
                    } else {
                        print("Invalid state reached when fetching friend request boolean!")
                    }
                } else {
                    if self.userFriendStatus != FriendStatus.Requested {
                        self.notFriend()
                    }
                }
            }
        }
    }
    
    // State updater methods
    
    func friend() {
        self.friendStatusButton.setTitle("Unfriend", for: .normal)
        self.userFriendStatus = FriendStatus.Friend
        updatePrivacy()
        self.queryFriendInformation()
    }
    
    func requested() {
        self.friendStatusButton.setTitle("Cancel Request", for: .normal)
        self.userFriendStatus = FriendStatus.Requested
        updatePrivacy()
    }
    
    func requestedMe() {
        self.friendStatusButton.setTitle("Accept Request", for: .normal)
        self.userFriendStatus = FriendStatus.RequestedMe
        updatePrivacy()
    }
    
    func notFriend() {
        self.friendStatusButton.setTitle("Friend", for: .normal)
        self.userFriendStatus = FriendStatus.NotFriend
        updatePrivacy()
    }
    
    func updatePrivacy() {
        var display = false
        if (user.name == CURRENT_USER.name) {
            display = true
        } else if (privacy == UserPrivacy.everyone){
            display = true
        } else if (privacy == UserPrivacy.friends && userFriendStatus == FriendStatus.Friend){
            display = true
        }
        
        if (display) {
            privateView.isHidden = true
            collectionView.isHidden = false
        } else {
            privateView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    func loadProfilePicture() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let reference = storageRef.child("profile_pictures/" + user.username!)
        
        // Placeholder image
        let placeholderImage = UIImage(named: "image-placeholder")
        
        profilePicture.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userMoviesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_PROFILE_CELL_IDENTIFIER, for:indexPath) as! FriendProfileViewCell
        if(userMoviesData[indexPath.row].posterImg == nil){
            if(userMoviesData[indexPath.row].poster == nil){
                //no poster, use default image
                cell.moviePoster.image = UIImage(named: "image-placeholder")
                userMoviesData[indexPath.row].posterImg = UIImage(named: "image-placeholder")
            }
            else{
                //load poster from internet
                cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + userMoviesData[indexPath.row].poster!)!)
            }
        }
        else{
            //poster has already been loaded previously
            cell.moviePoster.image = userMoviesData[indexPath.row].posterImg!
        }
        
        return cell
    }
    
    func queryFriendInformation() {
        // first check if they are confirmed friends
        ref.child("friends").child(CURRENT_USER.username!).child(user.username!).observeSingleEvent(of: .value) { (snapshot) in
            let friendValue = snapshot.value
            if let value = friendValue {
                if !(value is NSNull) {
                    if value as! Bool == true {
                        self.friend()
                    } else if value as! Bool == false {
                        self.queryRequestInformation()
                    } else {
                        print("Invalid state reached when fetching friend boolean!")
                    }
                } else {
                    self.queryRequestInformation()
                }
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
            if self.userFriendStatus == FriendStatus.Friend {
                // remove friend
                self.ref.child("friends").child(currentUsername!).child(self.user.username!).setValue(false)
                self.ref.child("friends").child(self.user.username!).child(currentUsername!).setValue(false)
                
                self.notFriend()
            } else if self.userFriendStatus == FriendStatus.Requested {
                // cancel friend request
                self.ref.child("friend_request").child(self.user.username!).child((currentUser?.username!)!).setValue(false)
                
                self.notFriend()
            } else if self.userFriendStatus == FriendStatus.NotFriend {
                // add friend
                self.ref.child("friend_request").child(self.user.username!).child((currentUser?.username!)!).setValue(true)
                
                self.requested()
            } else if self.userFriendStatus == FriendStatus.RequestedMe {
                // add friend
                self.ref.child("friends").child(currentUsername!).child(self.user.username!).setValue(true)
                self.ref.child("friends").child(self.user.username!).child(currentUsername!).setValue(true)
                // remove pending friend request
                self.ref.child("friend_request").child(self.user.username!).child((currentUser?.username!)!).setValue(false)
                self.ref.child("friend_request").child((currentUser?.username!)!).child(self.user.username!).setValue(false)
                
                self.friend()
            } else {
                print("Error: userFriendStatus is an invalid value! Value: " + String(reflecting: self.userFriendStatus))
            }
            
        }
    }
    
    // This method is because of the protocol SwipeDelegate
    // We don't want to do anything on reload
    func reload() {
    }
    
    /*
     // MARK: - Navigation
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "friendMovieDetail", sender: indexPath.row)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendMovieDetail"{
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                userMoviesData[index].opinion = nil
                detailViewController.movie = userMoviesData[index]
                detailViewController.currentIndex = index
            }
        }
    }
}
