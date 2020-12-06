//
//  FriendsListViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var ref: DatabaseReference!
    
    var currentUser:User? = nil
    
    var friendListData:[User] = []
    let FRIEND_LIST_CELL_IDENTIFIER = "friendListViewCell"
    
    var friendRequestData:[User] = []
    let FRIEND_REQUEST_CELL_IDENTIFIER = "friendRequestViewCell"
        
    private let itemsPerRow: CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 25.0,
                                             left: 10.0,
                                             bottom: 25.0,
                                             right: 10.0)
    
    @IBOutlet weak var numFriendsLabel: UILabel!
    @IBOutlet weak var addFriend: UIButton!
    @IBOutlet weak var friendListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
                
        friendListCollectionView.delegate = self
        friendListCollectionView.dataSource = self
        
        self.friendListCollectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        fetchFriends(CURRENT_USER.username!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColors(CURRENT_USER.visualMode, self.view)
    }
    
    func updateNumFriendsLabel() {
        let friendsPlural = friendListData.count == 1 ? "" : "s"
        
        numFriendsLabel.text = "You have " + String(friendListData.count) + " friend" + friendsPlural
    }
    
    // Fetch friends and friend requests for the current user
    // from firebase
    func fetchFriends(_ username:String) {
        ref.child("user_info").child(username).observeSingleEvent(of: .value) { (snapshot) in
            self.currentUser = User(snapshot, username)
        }
        
        ref.child("friends").child(username).observe(.value) { (snapshot) in
            self.friendListData = []
            for f in snapshot.children {
                let friend:DataSnapshot = f as! DataSnapshot
                if(friend.value as! Bool == true) {
                    self.ref.child("user_info").child(friend.key).observeSingleEvent(of: .value) { (snapshot) in
                        self.friendListData.append(User(snapshot, friend.key))
                        self.updateNumFriendsLabel()
                        self.friendListCollectionView.reloadData()
                    }
                }
                self.updateNumFriendsLabel()
                self.friendListCollectionView.reloadData()
            }
            self.updateNumFriendsLabel()
            self.friendListCollectionView.reloadData()
        }
        
        ref.child("friend_request").child(username).observe(.value) { (snapshot) in
            self.friendRequestData = []
            for f in snapshot.children {
                let friend:DataSnapshot = f as! DataSnapshot
                if(friend.value as! Bool == true) {
                
                    self.ref.child("user_info").child(friend.key).observeSingleEvent(of: .value) { (snapshot) in
                        self.friendRequestData.append(User(snapshot, friend.key))
                        
                        self.friendListCollectionView.reloadData()
                    }
                }
            }
            self.friendListCollectionView.reloadData()
        }
        
    }
    
    // Add Friend Request Header to Collection View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
             let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
            sectionHeader.label.text = (indexPath.section == 1) ? "Requests" : ""
            sectionHeader.label.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
             return sectionHeader
        } else {
             return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return (indexPath.section == 0) ? CGSize(width: widthPerItem, height: 110) : CGSize(width: widthPerItem, height: 150)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Hide friend requests section if user has none
        return friendRequestData.isEmpty ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? friendListData.count : friendRequestData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Friends List
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FRIEND_LIST_CELL_IDENTIFIER, for: indexPath) as! FriendListViewCell;
            let cellData = friendListData[indexPath.row]
            
            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.positionInList = indexPath.row
            
            Util.makeImageCircular(cell.profilePicture)
            
            cell.loadProfilePicture("profile_pictures/" + cellData.username!)
            
            return cell;
        }
        
        // Friend Request List
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_REQUEST_CELL_IDENTIFIER, for:indexPath) as! FriendRequestViewCell
            let cellData = friendRequestData[indexPath.row]

            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.positionInList = indexPath.row
            
            Util.makeImageCircular(cell.profilePicture)
            
            cell.loadProfilePicture("profile_pictures/" + cellData.username!)
            cell.currentUser = self.currentUser
            cell.friendRequestUser = cellData

            return cell
        }
        
        print("Error: Unexpected state reached in FriendsListViewController!")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Friends
        if indexPath.section == 0 {
            let cell = cell as! FriendListViewCell
            cell.nameLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
        }
        
        // Friend Requests
        if indexPath.section == 1 {
            let cell = cell as! FriendRequestViewCell
            cell.nameLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.label : UIColor.white
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendListToProfile" {
            let senderCell = sender as! FriendListViewCell
            let friendToViewIndex = senderCell.positionInList
            let destination = segue.destination as! FriendProfileViewController
            
            destination.user = friendListData[friendToViewIndex]
        }
        if segue.identifier == "friendRequestToProfile" {
            let senderCell = sender as! FriendRequestViewCell
            let friendToViewIndex = senderCell.positionInList
            let destination = segue.destination as! FriendProfileViewController
            
            destination.user = friendRequestData[friendToViewIndex]
        }
        if segue.identifier == "searchFriend" {
            let destination = segue.destination as! SearchViewController
            destination.startPeople = true
        }
    }

}

// Friend Request Section Header
class SectionHeader: UICollectionReusableView {
     var label: UILabel = {
         let label: UILabel = UILabel()
         label.textColor = .black
         label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
         label.sizeToFit()
         return label
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(label)

         label.translatesAutoresizingMaskIntoConstraints = false
         label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
         label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
         label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
