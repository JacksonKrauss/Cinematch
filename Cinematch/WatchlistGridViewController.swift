//
//  WatchlistGridViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import TMDBSwift
import Koloda
class WatchlistGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        let movie = CURRENT_USER.watchlist[index]
        Movie.clearMovie(movie: CURRENT_USER.watchlist[index])
        if(direction == .right){
            CURRENT_USER.liked.append(movie)
            movie.opinion = .like
        }
        else if(direction == .left){
            CURRENT_USER.disliked.append(movie)
            movie.opinion = .dislike
        }
        else if(direction == .up){
            CURRENT_USER.watchlist.append(movie)
            movie.opinion = .watchlist
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CURRENT_USER.watchlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCollectionViewCell
        cell.posterImageView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + CURRENT_USER.watchlist[indexPath.row].poster!)!)
        return cell
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath.row)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = CURRENT_USER.watchlist[index]
                detailViewController.currentIndex = index
            }
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
