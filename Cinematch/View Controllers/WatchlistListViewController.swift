//
//  WatchlistListViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
class WatchlistListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, SwipeDelegate, UISearchBarDelegate {
    func reload() {
        filteredMovies = CURRENT_USER.watchlist
        tableView.reloadData()
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
        tableView.reloadData()
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
            tableView.reloadData()
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        let movie = filteredMovies[index]
        Movie.clearMovie(movie: filteredMovies[index])
        if(direction == .right){
            CURRENT_USER.liked.append(movie)
            movie.opinion = .like
            tableView.reloadData()
        }
        else if(direction == .left){
            CURRENT_USER.disliked.append(movie)
            movie.opinion = .dislike
            tableView.reloadData()
        }
        else if(direction == .up){
            CURRENT_USER.watchlist.append(movie)
            movie.opinion = .watchlist
            tableView.reloadData()
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! WatchlistTableViewCell
        if(filteredMovies[indexPath.row].posterImg == nil){
            if(filteredMovies[indexPath.row].poster == nil){
                cell.posterView.backgroundColor = .white
                cell.posterView.image = UIImage(named: "no-image")
                filteredMovies[indexPath.row].posterImg = UIImage(named: "no-image")
            }
            else{
                cell.posterView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + filteredMovies[indexPath.row].poster!)!)
            }
        }
        else{
            cell.posterView.image = filteredMovies[indexPath.row].posterImg!
        }
        cell.titleLabel.text = filteredMovies[indexPath.row].title!
        cell.descriptionLabel.text = filteredMovies[indexPath.row].release
        cell.ratingLabel.text = filteredMovies[indexPath.row].rating
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    var filteredMovies:[Movie]!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        filteredMovies = CURRENT_USER.watchlist
    }
    override func viewWillAppear(_ animated: Bool) {
        filteredMovies = CURRENT_USER.watchlist
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    @IBAction func switchToList(_ sender: Any) {
        print("switched to list")
        //segue
    }
    
    @IBAction func switchToGrid(_ sender: Any) {
        print("switched to grid")
        //segue
    }
}
