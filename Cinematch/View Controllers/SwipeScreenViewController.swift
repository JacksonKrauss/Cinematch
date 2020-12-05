//
//  SwipeScreenViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
import Firebase
class SwipeScreenViewController: UIViewController,SwipeDelegate {
    func reload() {
    }
    
    func buttonTapped(direction: SwipeResultDirection, index:Int) {
        //swipes card away
        if(index==kolodaView.currentCardIndex){
            self.kolodaView.swipe(direction)
        }
        //just adds movie to list without swiping
        else{
            Movie.addToList(direction: direction, movie: movies[index]){
                
            }
        }
    }
    
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var watchlistImage: UIImageView!
    @IBOutlet weak var dislikeImage: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var page = 1 //stores the current page of popular movies for the queue
    let ref = Database.database().reference()
    var movies: [Movie] = [] //movie queue
    //loads the queue from firebase and if the isnt a queue it gets popular movies
    func loadMovieQueue(){
        activityIndicator.startAnimating()
        //pulls queue from firebase
        Movie.updateQueueFB { (movieList) in
            for x in movieList{
                //checks if the movie has already been seen
                if(!self.movies.contains(x) && !CURRENT_USER.history.contains(x)){
                    self.movies.append(x)
                }
                else{
                    //removes movie from queue in firebase if it has been seen
                    self.ref.child("queue").child(CURRENT_USER.username!).child(x.id!.description).removeValue { (error: Error?, DatabaseReference) in
                        //print(error!)
                    }
                }
            }
            if(movieList.isEmpty){
                //if there is no queue in firebase it loads from the popular movies
                Movie.getMovies(page: self.page) { (list) in
                    self.movies.append(contentsOf: list)
                    self.page += 1
                    self.kolodaView.reloadData()
                }
            }
            self.kolodaView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        TMDBConfig.apikey = "da04189f6c8bb1116ff3c217c908b776"
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
        self.friendLabel.text = ""
        self.starView.isHidden = true
        //pulls user's history from firebase and then creates the queue
        Movie.updateFromFB{
            self.loadMovieQueue()
        }
        self.kolodaView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.textColor = UIColor.label
        setColors(CURRENT_USER.visualMode, self.view)
        if CURRENT_USER.visualMode == VisualMode.light {
            watchlistImage.tintColor = darkModeTextOrHighlight
            dislikeImage.tintColor = darkModeTextOrHighlight
            likeImage.tintColor = darkModeTextOrHighlight
            separatorView.backgroundColor = darkModeTextOrHighlight
            activityIndicator.color = darkModeTextOrHighlight
        } else {
            watchlistImage.tintColor = UIColor.white
            dislikeImage.tintColor = UIColor.white
            likeImage.tintColor = UIColor.white
            separatorView.backgroundColor = UIColor.white
            activityIndicator.color = UIColor.white
        }
        watchlistImage.backgroundColor = .clear
        dislikeImage.backgroundColor = .clear
        likeImage.backgroundColor = .clear
        activityIndicator.backgroundColor = .clear

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
//swiping functionality
extension SwipeScreenViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        loadMovieQueue()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        self.performSegue(withIdentifier: "detailSegue", sender: index)
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
    //queue of posters, loads images
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let imageView = UIImageView()
        if(movies[index].posterImg == nil){
            if(movies[index].poster == nil){
                //no image, load default image
                imageView.backgroundColor = .white
                imageView.image = UIImage(named: "no-image")
                self.movies[index].posterImg = UIImage(named: "no-image")
                activityIndicator.stopAnimating()
            }
            else{
                //load image from internet
                let url = URL(string: "https://image.tmdb.org/t/p/original" + movies[index].poster!)!
                activityIndicator.startAnimating()
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                imageView.image = image
                                self!.movies[index].posterImg = imageView.image
                                self!.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
        else{
            //image has been previously loaded
            imageView.image = movies[index].posterImg!
            activityIndicator.stopAnimating()
        }
        return imageView
    }
    //shows view for each movie
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        self.descriptionLabel.text = movies[index].release
        self.titleLabel.text = movies[index].title
        if(!movies[index].recommended!.isEmpty && movies[index].recommended! != CURRENT_USER.username!){
            self.friendLabel.isHidden = false
            self.starView.isHidden = false
            self.friendLabel.text = "\(movies[index].recommended!) Recommended this movie!"
        }
        else{
            self.friendLabel.isHidden = true
            self.starView.isHidden = true
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return OverlayView()
    }
    //called when user swipes on a movie
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //adds movie to the correct list based on swipe direction
        Movie.addToList(direction: direction, movie: movies[index]){
            //removes movie from queue
            self.ref.child("queue").child(CURRENT_USER.username!).child(self.movies[index].id!.description).removeValue { (error: Error?, DatabaseReference) in
                //print(error!)
            }
            if(direction == .right){
                //Recommendation engine, when the user swipes right it adds similar movies
                Movie.getRecommended(page: 1, id: self.movies[index].id!) { (list) in
                    for m in list{
                        if(!CURRENT_USER.history.contains(m)){
                            self.movies.append(m)
                            self.ref.child("queue").child(CURRENT_USER.username!).child(m.id!.description).setValue(CURRENT_USER.username!)
                        }
                    }
                    koloda.reloadData()
                }
            }
        }
        //if you reach final card
        if(index == movies.endIndex-1){
            self.descriptionLabel.text = ""
            self.titleLabel.text = ""
            self.friendLabel.text = ""
        }
    }
}
//loads image from internet
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
