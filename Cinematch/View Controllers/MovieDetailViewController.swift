//
//  MovieDetailViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
protocol SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int)
    func reload()
}
class MovieDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movie!.actors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorCollectionViewCell
        cell.actorLabel.text = movie!.actors[indexPath.row].actorName
        cell.characterLabel.text = movie!.actors[indexPath.row].characterName
        return cell
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var movie: Movie?
    var delegate: SwipeDelegate?
    var currentIndex: Int?
    var trailerLink: String?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var watchlistButtonOutlet: UIButton!
    @IBOutlet weak var trailerButtonOutlet: UIButton!
    @IBOutlet weak var downButtonOutlet: UIButton!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func likeButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .right, index: currentIndex!)
        movie!.opinion = .like
        setButtonImages()
    }
    @IBAction func downButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .left, index: currentIndex!)
        movie!.opinion = .dislike
        setButtonImages()
    }
    @IBAction func addButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .up, index: currentIndex!)
        movie!.opinion = .watchlist
        setButtonImages()
    }
    @IBAction func shareButton(_ sender: Any) {
    }
    @IBAction func trailerButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: trailerLink!)!) { sucess in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = self.movie?.title
        self.descriptionLabel.text = self.movie?.description
        self.releaseLabel.text = self.movie?.release
        self.ratingLabel.text = self.movie?.rating
        movie!.actors = []
        setButtonImages()
        MovieMDB.credits(movieID: movie!.id){
            apiReturn, credits in
            if let credits = credits{
                for cast in credits.cast{
                    self.movie!.actors.append(Actor(actorName: cast.name, characterName: cast.character))
                }
                self.collectionView.reloadData()
            }
        }
        if(movie!.posterImg == nil){
            if(movie!.poster == nil){
                self.posterView.backgroundColor = .white
                self.posterView.image = UIImage(named: "no-image")
                movie!.posterImg = UIImage(named: "no-image")
            }
            else{
                let url = URL(string: "https://image.tmdb.org/t/p/original" + movie!.poster!)!
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self!.posterView.image = image
                                self!.movie!.posterImg = self!.posterView.image
                            }
                        }
                    }
                }
            }
        }
        else{
            posterView.image = movie!.posterImg!
        }
        MovieMDB.videos(movieID: movie!.id, language: "en"){
            apiReturn, videos in
            if let videos = videos{
                for i in videos {
                    if(i.site == "YouTube" && i.type == "Trailer")
                    {
                        self.trailerLink = "https://www.youtube.com/watch?v=\(i.key!)"
                        self.trailerButtonOutlet.isHidden = false
                        break
                    }
                }
            }
            if(videos!.isEmpty){
                self.trailerButtonOutlet.isHidden = true
            }
        }
        Movie.checkFriendOpinion(id: movie!.id!) { (friendMovies) in
            self.movie!.friends = friendMovies
            self.friendsLabel.text = "\(self.movie!.friends!.count) of your friends liked this movie"
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.reload()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "friendSegue"){
            if let sendToFriendsVC = segue.destination as? SendToFriendsViewController{
                sendToFriendsVC.movie = self.movie
            }
        }
    }
    func setButtonImages(){
        likeButtonOutlet.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        downButtonOutlet.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        watchlistButtonOutlet.setImage(UIImage(systemName: "plus.app"), for: .normal)
        switch movie!.opinion {
        case .like:
            likeButtonOutlet.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        case .dislike:
            downButtonOutlet.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        case .watchlist:
            watchlistButtonOutlet.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        default:
            break
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
