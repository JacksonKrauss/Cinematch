//
//  Users.swift
//  Cinematch
//
//  Created by Kyle Knight on 10/15/20.
//

//import Foundation
import UIKit
import FirebaseDatabase

enum UserPrivacy {
    case me
    case friends
    case everyone
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

struct User: Equatable {
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
    
    var remoteProfilePath:String?
    
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
        print(type(of: dataDictionary))
        
        self.name = dataDictionary["name"] as? String
        self.username = username
        self.email = dataDictionary["email"] as? String
        self.bio = dataDictionary["bio"] as? String
        self.profilePicture = UIImage(named: "image-placeholder") // placeholder needed before image set manually
        self.remoteProfilePath = dataDictionary["profile_path"] as? String
    }
    
    // no getters/setters, directly read/update vars instead
}

// sarah
var CURRENT_USER = User(name: "Sarah Brown", username: "sarab", bio: "Hi, my name is sara and I like movies", email: "sarab@gmail.com", privacy: UserPrivacy.friends, visualMode: VisualMode.light, profilePicture: UIImage(named: "profileCurrent")!, liked: [], disliked: [], watchlist: [], history: [])

// other users
var otherUser1 = User(name: "Greg Broughton", username: "gregb", bio: "hi, its greg, dis my bio", email: "greggboi@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.dark, profilePicture: UIImage(named: "profile1")!, liked: [], disliked: [], watchlist: [], history: [])

var otherUser2 = User(name: "Cathy Boone", username: "cathyboo", bio: "lover of movies, dog mom", email: "boocathy@hotmail.org", privacy: UserPrivacy.me, visualMode: VisualMode.light, profilePicture: UIImage(named: "profile2")!, liked: [], disliked: [], watchlist: [], history: [])

var otherUser3 = User(name: "Keane Bloom", username: "keanbloom", bio: "all kinds of movies are my favorite", email: "keaaaanbloo@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.light, profilePicture: UIImage(named: "profile3")!, liked: [], disliked: [], watchlist: [], history: [])

var otherUser4 = User(name: "Reem Schafer", username: "reemmovies", bio: "movie producer and cinephile", email: "schafer.reem@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.dark, profilePicture: UIImage(named: "profile4")!, liked: [], disliked: [], watchlist: [], history: [])


var OTHER_USERS = [otherUser1, otherUser2, otherUser3, otherUser4]
