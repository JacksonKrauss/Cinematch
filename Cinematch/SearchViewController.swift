//
//  SearchViewController.swift
//  Cinematch
//
//  Created by Maegan Parfan on 10/19/20.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var searchTableView: UITableView!
    
    var moviesData = SampleMovies.getMovies() // from Movie class
    var usersData = OTHER_USERS // from Users class
    
    var currentFilter: ChosenFilter!
    
    enum ChosenFilter {
        case movies, users
    }
    
    var filteredMovies:[Movie]?
    var filteredUsers:[User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchBar.delegate = self
        filteredMovies = moviesData
        filteredUsers = usersData
        // Do any additional setup after loading the view.
        currentFilter = ChosenFilter.movies
    }
    
    @IBAction func filterSelected(_ sender: Any) {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            currentFilter = .movies
        case 1:
            currentFilter = .users
        default:
            return
        }
    }
    
    // populates tableview depending on current filter
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentFilter {
        case .movies:
            return filteredMovies!.count
        case .users:
            return filteredUsers!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentFilter == .movies{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! WatchlistTableViewCell
            var currentMovie = filteredMovies![indexPath.row]
            cell.titleLabel?.text = currentMovie.title
            cell.descriptionLabel?.text = currentMovie.description
            cell.ratingLabel?.text = currentMovie.rating
            var poster = UIImageView()
            poster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + currentMovie.poster!)!)
            cell.posterView = poster
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! SendToFriendTableViewCell
            var currentTableUser = filteredUsers![indexPath.row]
            cell.nameLabel?.text = currentTableUser.name
            cell.userLabel?.text = currentTableUser.username
            var profilePic = UIImage(named: "profile1")
            return cell
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if currentFilter == .movies {
            filteredMovies = searchText.isEmpty ? moviesData : moviesData.filter {
                (movie: Movie) -> Bool in
                return movie.title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        } else {
            filteredUsers = searchText.isEmpty ? usersData : usersData.filter {
                (user: User) -> Bool in
                return user.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        searchTableView.reloadData()
    }
}
