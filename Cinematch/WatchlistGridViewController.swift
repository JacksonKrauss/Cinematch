//
//  WatchlistGridViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import TMDBSwift
import Koloda
class WatchlistGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SwipeDelegate, UISearchBarDelegate{
    func reload() {
        filteredMovies = CURRENT_USER.watchlist
        collectionView.reloadData()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = CURRENT_USER.watchlist.filter { (movie: Movie) -> Bool in
            return movie.title!.lowercased().contains(searchBar.text!.lowercased())
        }
        if(searchText.isEmpty){
            filteredMovies = CURRENT_USER.watchlist
        }
        collectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            filteredMovies = CURRENT_USER.watchlist
            collectionView.reloadData()
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    @IBOutlet weak var searchBar: UISearchBar!
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        let movie = filteredMovies[index]
        Movie.clearMovie(movie: filteredMovies[index])
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
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCollectionViewCell
        cell.posterImageView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + filteredMovies[indexPath.row].poster!)!)
        return cell
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    var filteredMovies:[Movie]!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        filteredMovies = CURRENT_USER.watchlist
    }
    override func viewWillAppear(_ animated: Bool) {
        filteredMovies = CURRENT_USER.watchlist
        collectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath.row)
    }
    @IBAction func listButton(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: false)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = filteredMovies[index]
                detailViewController.currentIndex = index
            }
        }
    }

}
