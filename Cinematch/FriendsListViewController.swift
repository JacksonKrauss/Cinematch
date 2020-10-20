//
//  FriendsListViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class FriendsListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let friendListData = OTHER_USERS
    let FRIEND_LIST_CELL_IDENTIFIER = "friendListViewCell"
    
    let friendRequestData = [CURRENT_USER] // fix, this doesn't make sense
    let FRIEND_REQUEST_CELL_IDENTIFIER = "friendRequestViewCell"
    
    @IBOutlet weak var numFriendsLabel: UILabel!
    @IBOutlet weak var addFriend: UIButton!
    @IBOutlet weak var friendListCollectionView: UICollectionView!
    @IBOutlet weak var friendRequestCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numFriendsLabel.text = "You have " + String(friendListData.count) + " friends"
        
        friendListCollectionView.delegate = self
        friendListCollectionView.dataSource = self
        
        friendRequestCollectionView.delegate = self
        friendRequestCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendListCollectionView {
            return friendListData.count
        }
        if collectionView == self.friendRequestCollectionView {
            return friendListData.count
        }
        print("Error: Invalid state reached in FriendsListViewController!")
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.friendListCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FRIEND_LIST_CELL_IDENTIFIER, for: indexPath) as! FriendListViewCell;
            let cellData = friendListData[indexPath.row]
            
            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.profilePicture.layer.cornerRadius = 50.0 // fix
            cell.positionInList = indexPath.row
            
            return cell;
        }
        if collectionView == self.friendRequestCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_REQUEST_CELL_IDENTIFIER, for:indexPath) as! FriendRequestViewCell
            let cellData = friendRequestData[indexPath.row]
            
            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.profilePicture.layer.cornerRadius = 50.0 // fix
            cell.positionInList = indexPath.row
            
            return cell
        }
        print("Error: Unexpected state reached in FriendsListViewController!")
        return UICollectionViewCell()
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
    }

}
