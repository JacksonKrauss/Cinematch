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
extension Array where Element: Equatable {
    mutating func addAll(array: [Element]) {
        for item in array{
            if(!self.contains(item)){
                self.append(item)
            }
        }
    }
}
extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}
struct MovieFB {
    var id: Int
    var opinion: Opinion
}
enum Opinion {
    case like
    case dislike
    case watchlist
}
struct Actor {
    var actorName: String?
    var characterName: String?
}
class Movie:Equatable{
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    var poster: String?
    var title: String?
    var description: String?
    var rating: String?
    var release: String?
    var actors: [Actor] = []
    var id: Int?
    var opinion: Opinion?
    var friends: [User]?
    var duration:String?
    var posterImg: UIImage?

    static func addToList(direction: SwipeResultDirection, movie: Movie){
        let ref = Database.database().reference()
        var op:String?
        if(direction == .right){
            movie.opinion = .like
            op = "l"
        }
        else if(direction == .left){
            movie.opinion = .dislike
            op = "d"
        }
        else if(direction == .up){
            movie.opinion = .watchlist
            op = "w"
        }
        ref.child("movies").child(CURRENT_USER.username!).child(movie.id!.description).setValue(op!)
        Movie.updateFromFB {
            
        }
    }
    
    func setFromMovie(movie: MovieMDB){
        self.id = movie.id
        self.title = movie.title
        self.description = movie.overview
        self.rating = String(movie.vote_average!)
        self.release = movie.release_date
        self.poster = movie.poster_path
        
        //populate from the user/ other source
        self.actors = []
        self.friends = []
        //opinion
        //self.duration = movie.runtime
    }
    
    static func getRecommended(page: Int, id: Int, completion: @escaping(_ movieList: [Movie]) -> ()){
        var movieList:[Movie] = []
        MovieMDB.recommendations(movieID: id, page: page, language: "en") { (ClientReturn, movies: [MovieMDB]?) in
            if let recs = movies{
                for rec in recs{
                    let curr = Movie()
                    curr.title = rec.title
                    curr.description = rec.overview
                    curr.poster = rec.poster_path
                    curr.rating = rec.vote_average!.description
                    curr.id = rec.id
                    curr.release = rec.release_date
                    curr.friends = []
                    movieList.append(curr)
                }
                completion(movieList)
            }
        }
    }
    
    static func getMovies(page: Int,completion: @escaping (_ movieList: [Movie]) -> ()){
        var movieList:[Movie] = []
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
                    if(!CURRENT_USER.history.contains(curr)){
                        movieList.append(curr)
                    }
                }
                if(movieList.isEmpty){
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
    static func getMoviesForUser(username: String, completion: @escaping(_ movieList: [MovieFB]) -> ()){
        let ref = Database.database().reference()
        var movieList:[MovieFB] = []
        ref.child("movies").child(username).observeSingleEvent(of: .value) { (snapshot) in
            for m in snapshot.children {
                let movieData:DataSnapshot = m as! DataSnapshot
                var currentOP: Opinion?
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
    static func getMovieFromFB(movieFB: MovieFB, completion: @escaping(_ movie: Movie) -> ()){
        MovieMDB.movie(movieID: movieFB.id, language: "en"){
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
                curr.opinion = movieFB.opinion
                if(curr.poster == nil){
                    curr.posterImg = UIImage(named: "no-image")
                }
                else{
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
    static func updateFromFB(completion: @escaping() -> ()){
        var userMovies: [Movie] = []
        CURRENT_USER.watchlist = []
        CURRENT_USER.disliked = []
        CURRENT_USER.liked = []
        CURRENT_USER.history = []
        Movie.getMoviesForUser(username: CURRENT_USER.username!) { (userHist) in
            for x in userHist{
                Movie.getMovieFromFB(movieFB: x) { (movie) in
                    userMovies.append(movie)
                    if(userMovies.count == userHist.count){
                        Movie.getUserListsFromMovies(movieList: userMovies)
                        print("done")
                        completion()
                    }
                }
            }
            if(userHist.isEmpty){
                print("no movies")
                completion()
            }
        }
    }
}
