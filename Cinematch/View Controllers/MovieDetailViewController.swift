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
    //gets called when an opinion button is tapped
    func buttonTapped(direction: SwipeResultDirection, index: Int)
    //gets called when the modal view disappears
    func reload()
}
class MovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    //actors and user opinion lists
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
        cell.index = indexPath.row
        if indexPath.row == 0{
            cell.titleLabel.text = "Actors"
            return cell
        }
        else{
            cell.titleLabel.text = "Friends"
        }
        return cell

    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.white : darkModeBackground
    }
    
    @IBOutlet weak var tableView: UITableView!
    
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
    @IBOutlet weak var lineView: UIView!
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
    //opens trailer in safari
    @IBAction func trailerButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: trailerLink!)!) { sucess in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
    }
    //sets up all the view elements
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = self.movie?.title
        self.descriptionLabel.text = self.movie?.description
        self.releaseLabel.text = self.movie?.release
        self.releaseLabel.textColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.secondaryLabel : UIColor.secondaryLabel.inverse()
        self.ratingLabel.text = self.movie?.rating
        movie!.actors = []
        DetailTableViewCell.movieTable = self.movie
        setButtonImages()
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
        setColors(CURRENT_USER.visualMode, self.view)
        self.lineView.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.black : UIColor.white
        //pulls trailer from api
        MovieMDB.videos(movieID: movie!.id, language: "en"){
            apiReturn, videos in
            if let videos = videos{
                for i in videos {
                    if(i.site == "YouTube" && i.type == "Trailer")
                    {
                        //makes sure the video is playable and shows button
                        self.trailerLink = "https://www.youtube.com/watch?v=\(i.key!)"
                        self.trailerButtonOutlet.isHidden = false
                        break
                    }
                    else{
                        self.trailerButtonOutlet.isHidden = true
                    }
                }
            }
            if(videos!.isEmpty){
                //if there is no videos it hides button
                self.trailerButtonOutlet.isHidden = true
            }
        }

        //checks how many of your friends like the movie
        Movie.checkFriendOpinion(id: movie!.id!) { (friendMovies) in
            self.movie!.friends = friendMovies
            //filters opinions to only liked
            let moviesFB = friendMovies.filter({ (movie) -> Bool in
                return movie.opinion == Opinion.like
            })
            self.friendsLabel.text = "\(moviesFB.count) of your friends liked this movie"
        }
        self.tableView.reloadData()
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
    //checks user's opinion and displays the correct button icons
    func setButtonImages(){
        likeButtonOutlet.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        downButtonOutlet.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        watchlistButtonOutlet.setImage(UIImage(systemName: "plus.app"), for: .normal)
        if(CURRENT_USER.liked.contains(movie!)){
            likeButtonOutlet.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        else if(CURRENT_USER.disliked.contains(movie!)){
            downButtonOutlet.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        else if(CURRENT_USER.watchlist.contains(movie!)){
            watchlistButtonOutlet.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
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
