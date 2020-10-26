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
    func reload()
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
    @IBAction func likeButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .right, index: currentIndex!)
        print("liked")
    }
    @IBAction func downButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .left, index: currentIndex!)
        print("disliked")
    }
    @IBAction func addButton(_ sender: Any) {
        self.delegate?.buttonTapped(direction: .up, index: currentIndex!)
        print("watchlist")
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
        self.friendsLabel.text = "\(movie!.friends!.count) of your friends liked this movie"
        if(movie!.posterImg == nil){
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
        else{
            posterView.image = movie!.posterImg!
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.reload()
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
