//
//  FriendsListViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class FriendsListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    let friendListData = OTHER_USERS
    let FRIEND_LIST_CELL_IDENTIFIER = "friendListViewCell"
    
    let friendRequestData = [CURRENT_USER] // fix, this doesn't make sense
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
        
        numFriendsLabel.text = "You have " + String(friendListData.count) + " friends"
        
        friendListCollectionView.delegate = self
        friendListCollectionView.dataSource = self
        
        self.friendListCollectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
             let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
            sectionHeader.label.text = (indexPath.section == 1) ? "Requests" : ""
            print("indexPath: " + String(indexPath.section))
             return sectionHeader
        } else { //No footer in this case but can add option for that
             return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        print("widthPerItem " + String(Float(widthPerItem)))
        
        return (indexPath.section == 0) ? CGSize(width: widthPerItem, height: 110) : CGSize(width: widthPerItem, height: 150)
      }
      
      //3
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
      }
      
      // 4
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
      }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? friendListData.count : friendRequestData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FRIEND_LIST_CELL_IDENTIFIER, for: indexPath) as! FriendListViewCell;
            let cellData = friendListData[indexPath.row]
            
            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.profilePicture.layer.cornerRadius = 78.5 / 2 // fix
            cell.positionInList = indexPath.row
            
            return cell;
        }
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:FRIEND_REQUEST_CELL_IDENTIFIER, for:indexPath) as! FriendRequestViewCell
            let cellData = friendRequestData[indexPath.row]

            cell.nameLabel.text = cellData.name
            cell.profilePicture.image = cellData.profilePicture
            cell.profilePicture.layer.cornerRadius = 78.5 / 2 // fix
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
         label.leftAnchor.constraint(equalTo: self.leftAnchor/*, constant: 20*/).isActive = true
         label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
