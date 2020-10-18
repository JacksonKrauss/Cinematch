//
//  SwipeScreenViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
class SwipeScreenViewController: UIViewController {
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    var user: User?
    fileprivate var movies: [Movie] = {
        var array: [Movie] = SampleMovies.getMovies()
        return array
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        TMDBConfig.apikey = "da04189f6c8bb1116ff3c217c908b776"
        user = User()
        //workaround because it didnt show label of first movie
        self.descriptionLabel.text = movies[0].release
        self.titleLabel.text = movies[0].title
        //add check for empty
        self.friendLabel.text = movies[0].friends![0].name! + " liked this movie!"
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("yo")
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
extension SwipeScreenViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("tapped")
    }
}
extension SwipeScreenViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        //workaround for first movie not showing
        return movies.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [SwipeResultDirection.left,SwipeResultDirection.right,SwipeResultDirection.up]
    }
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        print("loading")
        let image = UIImageView()
        image.load(url: URL(string: "https://image.tmdb.org/t/p/original" + movies[index].poster!)!)
        print("loaded")
        return image
    }
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        self.descriptionLabel.text = movies[index].release
        self.titleLabel.text = movies[index].title
        //add check for empty
        self.friendLabel.text = movies[index].friends![0].name! + " liked this movie!"
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return OverlayView()
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if(direction == .right){
            user?.liked.append(movies[index])
            movies[index].opinion = .like
        }
        else if(direction == .left){
            user?.disliked.append(movies[index])
            movies[index].opinion = .dislike
        }
        else if(direction == .up){
            user?.watchlist.append(movies[index])
            movies[index].opinion = .watchlist
        }
        user?.history.append(movies[index])
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
