//
//  Movie.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/15/20.
//

import Foundation
import UIKit
import TMDBSwift
import Koloda
import Firebase

//allows us to remove an equatable object from an array
extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}
//stores a movie as it is stored in firebase
struct MovieFB: Equatable {
    //allows us to equate two objects
    static func == (lhs: MovieFB, rhs: MovieFB) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int
    var opinion: Opinion
}
//stores a movie from the queue as it is stored in firebase
struct QueueFB: Equatable {
    //allows us to equate two objects
    static func == (lhs: QueueFB, rhs: QueueFB) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int
    var user: String
}
//stores a user and their opinion of the movie
struct FriendMovie {
    var user: User
    var opinion: Opinion
}
//keeps track of the user's opinion of the movie
enum Opinion {
    case like
    case dislike
    case watchlist
    case none
}
//stores an actor and the associated character name
struct Actor {
    var actorName: String?
    var characterName: String?
}
//stores all the information about a movie and has varous helper functions
class Movie:Equatable{
    //allows us to equate two objects
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    var poster: String? //link to poster
    var title: String?
    var description: String?
    var rating: String?
    var release: String? // release date
    var actors: [Actor] = []
    var id: Int?
    var opinion: Opinion?
    var friends: [FriendMovie]? //list of friends who reacted to the movie
    var duration:String?
    var recommended: String? // name of friend who recommended the movie
    var posterImg: UIImage? //image of poster

    //takes in a swipe direction/button press and adds the movie to the correct list
    static func addToList(direction: SwipeResultDirection, movie: Movie, completion: @escaping() -> ()){
        let ref = Database.database().reference()
        var op:String?
        //clears the movie from all lists
        CURRENT_USER.liked.remove(object: movie)
        CURRENT_USER.disliked.remove(object: movie)
        CURRENT_USER.watchlist.remove(object: movie)
        CURRENT_USER.history.remove(object: movie)
        //checks the direction and adds it to the right list
        if(direction == .right){
            movie.opinion = .like
            op = "l"
            //RECOMMENDATION ENGINE, gets similar movies and adds it to the queue
            Movie.getRecommended(page: 1, id: movie.id!) { (list) in
                for m in list{
                    //checks to make sure the user hasn't already seen the movie
                    if(!CURRENT_USER.history.contains(m)){
                        ref.child("queue").child(CURRENT_USER.username!).child(m.id!.description).setValue(CURRENT_USER.username!)
                    }
                }
            }
            CURRENT_USER.liked.append(movie)
        }
        else if(direction == .left){
            movie.opinion = .dislike
            op = "d"
            CURRENT_USER.disliked.append(movie)
        }
        else if(direction == .up){
            movie.opinion = .watchlist
            op = "w"
            CURRENT_USER.watchlist.append(movie)
        }
        //adds the movie to firebase with the user's opinion
        ref.child("movies").child(CURRENT_USER.username!).child(movie.id!.description).setValue(op!)
        //removes the movie if it is in the queue
        ref.child("queue").child(CURRENT_USER.username!).child(movie.id!.description).removeValue { (error: Error?, DatabaseReference) in
            //print(error!)
        }
        CURRENT_USER.history.append(movie)
        completion()
    }
    //takes a movie from the api and converts it to a movie object
    func setFromMovie(movie: MovieMDB){
        self.id = movie.id
        self.title = movie.title
        self.description = movie.overview
        self.rating = String(movie.vote_average!)
        self.release = movie.release_date
        self.poster = movie.poster_path
        self.recommended = ""
        
        //populate from the user/ other source
        self.actors = []
        self.friends = []
        //opinion
        //self.duration = movie.runtime
    }
    //recommendation algorithm, gets movies similar to the current movie
    static func getRecommended(page: Int, id: Int, completion: @escaping(_ movieList: [Movie]) -> ()){
        var movieList:[Movie] = []
        //pulls similar movies from api
        MovieMDB.recommendations(movieID: id, page: page, language: "en") { (ClientReturn, movies: [MovieMDB]?) in
            if let recs = movies{
                //only gets the 4 best recommendations and adds them to the queue
                let prefix = recs.prefix(4)
                for rec in prefix{
                    let curr = Movie()
                    curr.title = rec.title
                    curr.description = rec.overview
                    curr.poster = rec.poster_path
                    curr.rating = rec.vote_average!.description
                    curr.id = rec.id
                    curr.release = rec.release_date
                    curr.friends = []
                    curr.recommended = ""
                    movieList.append(curr)
                }
                completion(movieList)
            }
        }
    }
    //gets the initial swiping queue of popular movies
    static func getMovies(page: Int,completion: @escaping (_ movieList: [Movie]) -> ()){
        var movieList:[Movie] = []
        //gets the 20 most popular movies from the api
        MovieMDB.popular(language: "en", page: page){
            data, popularMovies in
            if let movie = popularMovies{
                for m in movie {
                    let curr = Movie()
                    curr.title = m.title
                    curr.description = m.overview
                    curr.poster = m.poster_path
                    curr.rating = m.vote_average?.description
                    curr.id = m.id
                    curr.release = m.release_date
                    curr.friends = []
                    curr.recommended = ""
                    //checks to make sure the user hasn't already seen the movie
                    if(!CURRENT_USER.history.contains(curr)){
                        movieList.append(curr)
                    }
                }
                if(movieList.isEmpty){
                    //if the user has seen all the popular movies it recursively
                    //gets the next page of popular movies
                    getMovies(page: page+1) { (movieList2) in
                        completion(movieList2)
                    }
                }
                else{
                    completion(movieList)
                }
            }
        }
    }
    //returns the queue of QueueFB objects from firebase for a given user
    static func getQueueForUser(username: String, completion: @escaping(_ movieList: [QueueFB]) -> ()){
        let ref = Database.database().reference()
        var movieList:[QueueFB] = []
        ref.child("queue").child(username).observeSingleEvent(of: .value) { (snapshot) in
            for m in snapshot.children {
                let movieData:DataSnapshot = m as! DataSnapshot
                let movie: QueueFB = QueueFB(id: Int(movieData.key)!, user: movieData.value as! String)
                movieList.append(movie)
            }
            completion(movieList)
        }
    }
    //returns the user's movie history MovieFB objects from firebase
    static func getMoviesForUser(username: String, completion: @escaping(_ movieList: [MovieFB]) -> ()){
        let ref = Database.database().reference()
        var movieList:[MovieFB] = []
        ref.child("movies").child(username).observeSingleEvent(of: .value) { (snapshot) in
            for m in snapshot.children {
                let movieData:DataSnapshot = m as! DataSnapshot
                var currentOP: Opinion?
                //checks the opinion of the movie
                if((movieData.value as! String) == "l"){
                    currentOP = .like
                }
                if((movieData.value as! String) == "w"){
                    currentOP = .watchlist
                }
                if((movieData.value as! String) == "d"){
                    currentOP = .dislike
                }
                let movie: MovieFB = MovieFB(id: Int(movieData.key)!, opinion: currentOP!)
                movieList.append(movie)
            }
            completion(movieList)
        }
    }
    //creates a Movie object from a MovieFB object
    static func getMovieFromFB(id: Int, opinion: Opinion, recommended: String, completion: @escaping(_ movie: Movie) -> ()){
        //calls the api to get information about the specific movie id
        MovieMDB.movie(movieID: id, language: "en"){
              apiReturn, movie in
              if let movie = movie{
                let curr = Movie()
                curr.title = movie.title
                curr.description = movie.overview
                curr.poster = movie.poster_path
                curr.rating = movie.vote_average!.description
                curr.id = movie.id
                curr.release = movie.release_date
                curr.friends = []
                curr.opinion = opinion
                curr.recommended = recommended
                //checks to see if the movie has a poster
                if(curr.poster == nil){
                    //default image
                    curr.posterImg = UIImage(named: "image-placeholder")
                }
                else{
                    //downloads the poster of the movie
                    let url = URL(string: "https://image.tmdb.org/t/p/original" + curr.poster!)!
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url) {
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    curr.posterImg = image
                                }
                            }
                        }
                    }
                }
                completion(curr)
              }
            }
    }
    //takes in a list of movies and separates them by opinion
    static func getUserListsFromMovies(movieList: [Movie]){
        for movie in movieList{
            switch movie.opinion {
            case .like:
                CURRENT_USER.liked.append(movie)
            case .watchlist:
                CURRENT_USER.watchlist.append(movie)
            case .dislike:
                CURRENT_USER.disliked.append(movie)
            default:
                break
            }
            CURRENT_USER.history.append(movie)
        }
    }
    //gets a list of Movie objects for the current user's queue
    static func updateQueueFB(completion: @escaping(_ movieList: [Movie]) -> ()){
        var userMovies: [Movie] = []
        //gets QueueFB objects
        Movie.getQueueForUser(username: CURRENT_USER.username!) { (userQueue) in
            for x in userQueue{
                //converts the QueueFB object to a Movie object
                Movie.getMovieFromFB(id: x.id, opinion: .none,recommended: x.user) { (movie) in
                    //if the movie was recommended by another user it is put first
                    if(movie.recommended != CURRENT_USER.username){
                        userMovies.insert(movie, at: 0)
                    }
                    else{
                        userMovies.append(movie)
                    }
                    //checks to make sure all the movies are finished loading
                    if(userMovies.count == userQueue.count){
                        //returns the first 10 from the queue
                        let prefix = userMovies.prefix(10)
                        completion(Array(prefix))
                    }
                }
            }
            //makes sure the function returns even if there is no queue
            if(userQueue.isEmpty){
                completion(userMovies)
            }
        }
    }
    //gets all the current user's lists from firebase
    static func updateFromFB(completion: @escaping() -> ()){
        var userMovies: [Movie] = []
        //clears all lists
        CURRENT_USER.watchlist = []
        CURRENT_USER.disliked = []
        CURRENT_USER.liked = []
        CURRENT_USER.history = []
        //gets MovieFB objects from firebase
        Movie.getMoviesForUser(username: CURRENT_USER.username!) { (userHist) in
            for x in userHist{
                //converts them to Movie objects
                Movie.getMovieFromFB(id: x.id, opinion: x.opinion,recommended: "") { (movie) in
                    userMovies.append(movie)
                    if(userMovies.count == userHist.count){
                        //separates the movies into their correct lists
                        Movie.getUserListsFromMovies(movieList: userMovies)
                        completion()
                    }
                }
            }
            //no movies for the current user / new account
            if(userHist.isEmpty){
                completion()
            }
        }
    }
    //takes in a movie id and returns a list of your friends reactions to it
    static func checkFriendOpinion(id: Int, completion: @escaping(_ movieList: [FriendMovie]) -> ()){
        var friendOp: [FriendMovie] = []
        //gets a list of your friend's usernames
        getFriendsUser { (friendsList) in
            for f in friendsList{
                //gets each friend's movies
                getMoviesForUser(username: f.username!) { (movieList) in
                    //checks if the user has seen the specific movie
                    let index = movieList.firstIndex(of: MovieFB(id: id, opinion: .like))
                    //if they have then add to list
                    if(index != nil){
                        friendOp.append(FriendMovie(user: f, opinion: movieList[index!].opinion))
                    }
                    //makes sure the function is finished before returning
                    if(f == friendsList.last){
                        completion(friendOp)
                    }
                }
            }
            //returns even if you have no friends
            if(friendsList.isEmpty){
                completion(friendOp)
            }
            
        }
    }
    
}
