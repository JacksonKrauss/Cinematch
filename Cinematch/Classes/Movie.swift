//
//  Movie.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/15/20.
//

import Foundation
import UIKit
import TMDBSwift

extension Array where Element: Equatable {
 mutating func remove(object: Element) {
     guard let index = firstIndex(of: object) else {return}
     remove(at: index)
 }

}
enum Opinion {
    case like
    case dislike
    case watchlist
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
    var actors: [String] = []
    var id: Int?
    var opinion: Opinion?
    var friends: [User]?
    var duration:String?
    func setVars(id:Int){
        print("Starting vars")
        self.id = id
        MovieMDB.movie(movieID: id, language: "en"){
             apiReturn, movie in
             if let movie = movie{
                self.title = movie.title
                self.description = movie.overview
                self.rating = String(movie.vote_average!)
                self.release = movie.release_date
                self.poster = movie.poster_path
             }
            
           }
        MovieMDB.credits(movieID: id){
              apiReturn, credits in
              if let credits = credits{
                for cast in credits.cast{
                    self.actors.append(cast.name)
                }
              }
            }
        print("end vars")
    }
    static func clearMovie(movie: Movie){
        CURRENT_USER.liked.remove(object: movie)
        CURRENT_USER.disliked.remove(object: movie)
        CURRENT_USER.watchlist.remove(object: movie)
    }
}
class SampleMovies{
    static func getMovies() -> [Movie]{
        var movieList:[Movie] = []
        let blackPanther = Movie()
        blackPanther.description = "King T'Challa returns home from America to the reclusive, technologically advanced African nation of Wakanda to serve as his country's new leader. However, T'Challa soon finds that he is challenged for the throne by factions within his own country as well as without. Using powers reserved to Wakandan kings, T'Challa assumes the Black Panther mantel to join with girlfriend Nakia, the queen-mother, his princess-kid sister, members of the Dora Milaje (the Wakandan 'special forces') and an American secret agent, to prevent Wakanda from being dragged into a world war."
        blackPanther.title = "Black Panther"
        blackPanther.id = 284054
        blackPanther.poster = "/uxzzxijgPIY7slzFvMotPv8wjKA.jpg"
        blackPanther.rating = "3.7"
        blackPanther.release = "2018"
        blackPanther.actors = ["Chadwick Boseman","Michael B. Jordan","Lupita Nyong'o","Danai Gurira"]
        blackPanther.duration = "2h 15m"
        blackPanther.friends = [otherUser1, otherUser2]
        movieList.append(blackPanther)
        let mulan = Movie()
        mulan.description = "When the Emperor of China issues a decree that one man per family must serve in the Imperial Chinese Army to defend the country from Huns, Hua Mulan, the eldest daughter of an honored warrior, steps in to take the place of her ailing father. She is spirited, determined and quick on her feet. Disguised as a man by the name of Hua Jun, she is tested every step of the way and must harness her innermost strength and embrace her true potential."
        mulan.title = "Mulan"
        mulan.id = 337401
        mulan.poster = "/aKx1ARwG55zZ0GpRvU2WrGrCG9o.jpg"
        mulan.rating = "3.7"
        mulan.release = "2020"
        mulan.actors = ["Liu Yifei","Jet Li","Tzi Ma","Donnie Yen"]
        mulan.duration = "1h 55m"
        mulan.friends = [otherUser3]
        movieList.append(mulan)
        return movieList
    }
    
    
}

