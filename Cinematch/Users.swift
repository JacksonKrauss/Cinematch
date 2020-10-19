//
//  Users.swift
//  Cinematch
//
//  Created by Kyle Knight on 10/15/20.
//

//import Foundation
import UIKit

enum UserPrivacy {
    case me
    case friends
    case everyone
}

enum VisualMode {
    case dark
    case light
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
    
    // no getters/setters, directly read/update vars instead
}

// sarah
var CURRENT_USER = User(name: "Sarah Brown", username: "sarab", bio: "Hi, my name is sara and I like movies", email: "sarab@gmail.com", privacy: UserPrivacy.friends, visualMode: VisualMode.light, profilePicture: UIImage(named: "profileCurrent"), liked: [], disliked: [], watchlist: [], history: [])

// other users
var otherUser1 = User(name: "Greg Broughton", username: "gregb", bio: "hi, its greg, dis my bio", email: "greggboi@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.dark, profilePicture: UIImage(named: "profile1"), liked: [], disliked: [], watchlist: [], history: [])

var otherUser2 = User(name: "Cathy Boone", username: "cathyboo", bio: "lover of movies, dog mom", email: "boocathy@hotmail.org", privacy: UserPrivacy.me, visualMode: VisualMode.light, profilePicture: UIImage(named: "profile2"), liked: [], disliked: [], watchlist: [], history: [])

var otherUser3 = User(name: "Keane Bloom", username: "keanbloom", bio: "all kinds of movies are my favorite", email: "keaaaanbloo@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.light, profilePicture: UIImage(named: "profile3"), liked: [], disliked: [], watchlist: [], history: [])

var otherUser4 = User(name: "Reem Schafer", username: "reemmovies", bio: "movie producer and cinephile", email: "schafer.reem@gmail.com", privacy: UserPrivacy.everyone, visualMode: VisualMode.dark, profilePicture: UIImage(named: "profile4"), liked: [], disliked: [], watchlist: [], history: [])


var OTHER_USERS = [otherUser1, otherUser2, otherUser3, otherUser4]
