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
    
    //hardcoded data to search
    var moviesData = SampleMovies.getMovies()
    var filteredMovies:[Movie]!
    var usersData = OTHER_USERS
    var filteredUsers:[User]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        // initial data source
        filteredMovies = moviesData
        filteredUsers = usersData
    }
    
    @IBAction func filterSelected(_ sender: Any) {
        // table view needs to be updated
        searchTableView.reloadData()
    }
    
    // get count of table cells based on selected filter
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            return filteredMovies.count
        case 1:
            return filteredUsers.count
        default:
            return 0
        }
    }
    
    // populate the table view with data depending on the filter
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell
            var currentMovie = filteredMovies[indexPath.row]
            cell.movieTitleLabel?.text = currentMovie.title!
            cell.movieRatingLabel?.text = currentMovie.rating!
            var poster = UIImageView()
            poster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + currentMovie.poster!)!)
            cell.moviePosterImageView? = poster
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PeopleSearchTableViewCell
            var currentPerson = filteredUsers[indexPath.row]
            cell.nameLabel?.text = currentPerson.name
            cell.usernameLabel?.text = currentPerson.username
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // search bar functionality that updates the table view based on the selected filter
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchTypeSegCtrl.selectedSegmentIndex {
        case 0:
            filteredMovies = searchText.isEmpty ? moviesData : filteredMovies.filter {
                (movie: Movie) -> Bool in
                return movie.title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            break
        case 1:
            filteredUsers = searchText.isEmpty ? usersData : filteredUsers.filter {
                (user: User) -> Bool in
                return user.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale:nil) != nil
            }
            break
        default:
            break
        }
        searchTableView.reloadData()
    }
}
