//
//  SearchViewController.swift
//  Cinematch
//
//  Created by Maegan Parfan on 10/19/20.
//

import UIKit
import Koloda
import TMDBSwift

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, SwipeDelegate {
    
    func reload() {
    }
    
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
//        let movie = moviesData[index]
//        Movie.clearMovie(movie: moviesData[index])
//        if(direction == .right){
//            CURRENT_USER.liked.append(movie)
//            movie.opinion = .like
//        }
//        else if(direction == .left){
//            CURRENT_USER.disliked.append(movie)
//            movie.opinion = .dislike
//        }
//        else if(direction == .up){
//            CURRENT_USER.watchlist.append(movie)
//            movie.opinion = .watchlist
//        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var searchTableView: UITableView!
    
    //hardcoded data to search
    var usersData = OTHER_USERS
    var filteredUsers:[User]!
    var moviesData:[MovieMDB] = []
    var page = 1
    var hitEnd = false
    var currentQuery = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchBar.delegate = self
        filteredUsers = usersData
        
        searchTableView.rowHeight = 166
    }
    
    func loadMovies() {
                                
        TMDBConfig.apikey = "da04189f6c8bb1116ff3c217c908b776"
            
        SearchMDB.movie(query: currentQuery, language: "en", page: page, includeAdult: true, year: nil, primaryReleaseYear: nil, completion: { [self]
            data, movies in
            if (movies?.count == 0) {
                hitEnd = true
            }
            for movie in movies! {
                self.moviesData.append(movie)
            }
            self.page = self.page + 1;
            self.searchTableView?.reloadData()
        })
        
    }
    
    func loadUsers() {
        //get all the users from firebase and add them to usersData
        //        filteredUsers = searchText.isEmpty ? usersData : filteredUsers.filter {
        //                        (user: User) -> Bool in
        //                        return user.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale:nil) != nil
        //                    }
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
            searchTableView.reloadData()
            filteredUsers = usersData
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    @IBAction func filterSelected(_ sender: Any) {
        // table view needs to be updated
        searchTableView.reloadData()
        switch searchTypeSegCtrl.selectedSegmentIndex {
            case 0:
                searchTableView.rowHeight = 166
                break
            case 1:
                searchTableView.rowHeight = 115
                break
            default:
                searchTableView.rowHeight = 166
                break
        }
    }
    
    // get count of table cells based on selected filter
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            return moviesData.count
        case 1:
            return usersData.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // populate the table view with data depending on the filter
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell

            if moviesData.count > indexPath.row {
                let currentMovie = moviesData[indexPath.row]
                
                //movie data
                cell.movieTitleLabel?.text = currentMovie.title
                cell.movieReleaseLabel?.text = currentMovie.release_date
                
                //rating
                if let rating = currentMovie.vote_average {
                    cell.movieRatingLabel?.text = String(rating)
                } else {
                    cell.movieRatingLabel?.text = "No rating"
                }
                
                //image
                if let path = currentMovie.poster_path {
                    DispatchQueue.main.async {
                        cell.moviePosterImageView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + path)!)
                    }
                } else {
                    cell.moviePosterImageView.backgroundColor = .gray
                }
                
            }
            
            if (indexPath.row == moviesData.count - 1 && !hitEnd){
                self.loadMovies()
                
            }
                    
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PeopleSearchTableViewCell
            let currentPerson = usersData[indexPath.row]
            cell.nameLabel?.text = currentPerson.name
            cell.usernameLabel?.text = currentPerson.username
            cell.profilePicImageView.image = currentPerson.profilePicture
            cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.height / 2
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // search bar functionality that updates the table view based on the selected filter
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentQuery = searchText
        moviesData = []
        usersData = []
        page = 1
        hitEnd = false
        
        switch searchTypeSegCtrl.selectedSegmentIndex {
            case 0:
                self.loadMovies()
                break
            case 1:
                self.loadUsers()
                break
            default:
                break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieSearchSegue" {
            if let detailViewController = segue.destination as? MovieDetailViewController{
                let index = searchTableView.indexPathForSelectedRow?.row
                detailViewController.delegate = self
                
                //get the movie in form
                let movie = Movie()
                movie.title = moviesData[index!].title
                movie.description = moviesData[index!].overview
                movie.release = moviesData[index!].release_date
                movie.rating = "\(moviesData[index!].vote_average)"
                movie.friends = []
                movie.poster = moviesData[index!].poster_path
                movie.actors = []
                movie.id = moviesData[index!].id
                //TODO: change movie to take in a MovieDB and populate it
                //Also make sure that it checks the movies a user has
                //looked at before
                
                detailViewController.movie = movie
                detailViewController.currentIndex = index
            }
        }
        if segue.identifier == "peopleSearchSegue" {
            let indexPath = searchTableView.indexPathForSelectedRow
            let selectedUser = usersData[indexPath!.row]
            let destination = segue.destination as! FriendProfileViewController
            destination.user = selectedUser
        }
    }
}
