//
//  MovieDetailViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
protocol SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int)
}
class MovieDetailViewController: UIViewController {
    var movie: Movie?
    var delegate: SwipeDelegate?
    var currentIndex: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actor1Label: UILabel!
    @IBOutlet weak var actor2Label: UILabel!
    @IBOutlet weak var actor3Label: UILabel!
    @IBAction func likeButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .right, index: currentIndex!)
    }
    @IBAction func downButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .left, index: currentIndex!)
    }
    @IBAction func addButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .up, index: currentIndex!)
    }
    @IBAction func shareButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = self.movie?.title
        self.descriptionLabel.text = self.movie?.description
        self.releaseLabel.text = self.movie?.release
        self.ratingLabel.text = self.movie?.rating
        self.friendsLabel.text = "\(movie!.friends!.count) liked this movie"
        self.actor1Label.text = self.movie?.actors[0]
        self.actor2Label.text = self.movie?.actors[1]
        self.actor3Label.text = self.movie?.actors[2]
        self.posterView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + (self.movie!.poster!))!)
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
