//
//  SwipeScreenViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
class SwipeScreenViewController: UIViewController,SwipeDelegate {
    func reload() {
        
    }
    
    func buttonTapped(direction: SwipeResultDirection, index:Int) {
        Movie.clearMovie(movie: movies[index])
        if(index==kolodaView.currentCardIndex){
            self.kolodaView.swipe(direction)
        }
        else if(direction == .right){
            CURRENT_USER.liked.append(movies[index])
            movies[index].opinion = .like
        }
        else if(direction == .left){
            CURRENT_USER.disliked.append(movies[index])
            movies[index].opinion = .dislike
        }
        else if(direction == .up){
            CURRENT_USER.watchlist.append(movies[index])
            movies[index].opinion = .watchlist
        }
        
    }
    
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    var page = 1
    var movies: [Movie] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        TMDBConfig.apikey = "da04189f6c8bb1116ff3c217c908b776"
        Movie.getMovies(page: page) { (list) in
            self.movies = list
            self.kolodaView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = movies[index]
                detailViewController.currentIndex = index
            }
        }
    }
}
extension SwipeScreenViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        page += 1
        Movie.getMovies(page: page) { (list) in
            self.movies.addAll(array: list)
            self.kolodaView.reloadData()
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        performSegue(withIdentifier: "detailSegue", sender: index)
    }
}
extension SwipeScreenViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return movies.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [SwipeResultDirection.left,SwipeResultDirection.right,SwipeResultDirection.up]
    }
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let imageView = UIImageView()
        print(movies[index].title!)
        if(movies[index].posterImg == nil){
            if(movies[index].poster == nil){
                imageView.backgroundColor = .white
                imageView.image = UIImage(named: "no-image")
                self.movies[index].posterImg = UIImage(named: "no-image")
            }
            else{
                let url = URL(string: "https://image.tmdb.org/t/p/original" + movies[index].poster!)!
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                imageView.image = image
                                self!.movies[index].posterImg = imageView.image
                            }
                        }
                    }
                }
            }
        }
        else{
            imageView.image = movies[index].posterImg!
        }
        return imageView
    }
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        self.descriptionLabel.text = movies[index].release
        self.titleLabel.text = movies[index].title
        if(movies[index].friends!.count > 0){
            self.friendLabel.text = movies[index].friends![0].name! + " liked this movie!"
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return OverlayView()
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        Movie.clearMovie(movie: movies[index])
        if(direction == .right){
            CURRENT_USER.liked.append(movies[index])
            movies[index].opinion = .like
            Movie.getRecommended(page: 1, id: movies[index].id!) { (list) in
                self.movies.addAll(array: list)
                print("adding \(list)")
                koloda.reloadData()
            }
        }
        else if(direction == .left){
            CURRENT_USER.disliked.append(movies[index])
            movies[index].opinion = .dislike
        }
        else if(direction == .up){
            CURRENT_USER.watchlist.append(movies[index])
            movies[index].opinion = .watchlist
        }
        CURRENT_USER.history.append(movies[index])
        if(index == movies.endIndex-1){
            self.descriptionLabel.text = ""
            self.titleLabel.text = ""
            self.friendLabel.text = ""
        }
    }
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
