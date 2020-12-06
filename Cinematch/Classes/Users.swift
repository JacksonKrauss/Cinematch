//
//  Users.swift
//  Cinematch
//
//  Created by Kyle Knight on 10/15/20.
//

//import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

enum UserPrivacy {
    case me
    case friends
    case everyone
}
//returns a list of friend user objects for the current user for the movie detail page
func getFriendsUser(completion: @escaping(_ friends: [User]) -> ()){
    let ref = Database.database().reference()
    var friendListData:[User] = []
    getFriends { (friendList) in
        ref.child("user_info").observeSingleEvent(of: .value, with: { (snapshot) in
            for userSnap in snapshot.children.allObjects as! [DataSnapshot] {
                let user = User(userSnap, userSnap.key)
                //checks to make sure the friend is not private
                if(friendList.contains(userSnap.key) && user.privacy != .me){
                    friendListData.append(user)
                }
            }
            completion(friendListData)
        })
    }
}
//returns a list of friends usernames for the current user
func getFriends(completion: @escaping(_ friendList: [String]) -> ()){
    let ref = Database.database().reference()
    var friendListData:[String] = []
    ref.child("friends").child(CURRENT_USER.username!).observeSingleEvent(of: .value) { (snapshot) in
        for f in snapshot.children {
            let friend:DataSnapshot = f as! DataSnapshot
            if(friend.value as! Bool == true) {
                friendListData.append(friend.key)
            }
        }
        completion(friendListData)
    }
}
func privacyToString(privacy: UserPrivacy) -> String {
    switch privacy {
    case .me:
        return "me"
    case .friends:
        return "friends"
    case .everyone:
        return "everyone"
    }
}

func stringToPrivacy(privacy: String) -> UserPrivacy {
    switch privacy {
    case "me":
        return UserPrivacy.me
    case "friends":
        return UserPrivacy.friends
    case "everyone":
        return UserPrivacy.everyone
    default:
        return UserPrivacy.friends
    }
}

enum VisualMode {
    case dark
    case light
}

func visualToString(visualMode: VisualMode) -> String {
    switch visualMode {
    case .dark:
        return "dark"
    case .light:
        return "light"
    }
}

func stringToVisual(visualMode: String) -> VisualMode {
    switch visualMode {
    case "dark":
        return VisualMode.dark
    case "light":
        return VisualMode.light
    default:
        return VisualMode.light
    }
}

class User: Equatable {
//allows you to check if two users are equal
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    var name:String?
    var username:String?
    var bio:String?
    var email:String?
    var privacy:UserPrivacy = UserPrivacy.friends  // default to friends
    var visualMode:VisualMode = VisualMode.light   // default to light mode
    var profilePicture:UIImage?
    var liked:[Movie] = []
    var disliked:[Movie] = []
    var watchlist:[Movie] = []
    var history:[Movie] = []
        
    init() {
        // all default values
    }
    
    init(name:String, username:String, bio:String, email:String, privacy:UserPrivacy, visualMode:VisualMode, profilePicture:UIImage, liked:[Movie], disliked:[Movie], watchlist:[Movie], history:[Movie]) {
        self.name = name
        self.username = username
        self.bio = bio
        self.email = email
        self.privacy = privacy
        self.visualMode = visualMode
        self.profilePicture = profilePicture
        self.liked = liked
        self.disliked = disliked
        self.watchlist = watchlist
        self.history = history
    }
    
    // build this object from a data snapshot of a user json object
    // if snapshot malformed, this init will return the same result as init()
    init(_ snapshot:DataSnapshot, _ username:String) {
        let dataDictionary = snapshot.value as! NSDictionary
        
        self.name = dataDictionary["name"] as? String
        self.username = username
        self.email = dataDictionary["email"] as? String
        self.privacy = stringToPrivacy(privacy: (dataDictionary["privacy"] as? String)!)
        self.bio = dataDictionary["bio"] as? String
        self.visualMode = stringToVisual(visualMode: (dataDictionary["visual_mode"] as? String)!)
        self.profilePicture = UIImage(named: "image-placeholder") // placeholder needed before image set manually
    }
    
    // no getters/setters, directly read/update vars instead
}

// global, holds the logged-in user object
var CURRENT_USER = User()

let storage = Storage.storage()

let storageRef = storage.reference()

