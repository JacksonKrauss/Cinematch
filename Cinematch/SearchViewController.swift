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
        
        searchTableView.rowHeight = 166
    }
    
    @IBAction func filterSelected(_ sender: Any) {
        // table view needs to be updated
        searchTableView.reloadData()
        switch searchTypeSegCtrl.selectedSegmentIndex {
            case 0:
                searchTableView.rowHeight = 166
            case 1:
                searchTableView.rowHeight = 115
            default:
                searchTableView.rowHeight = 166
        }
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
            let currentMovie = filteredMovies[indexPath.row]
            cell.movieTitleLabel?.text = currentMovie.title!
            cell.movieRatingLabel?.text = currentMovie.rating!
            cell.moviePosterImageView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + currentMovie.poster!)!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PeopleSearchTableViewCell
            let currentPerson = filteredUsers[indexPath.row]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieSearchSegue" {
            // "Cannot complete segue at this time, as movie detail view needs a swipe delegate"
            // DO NOT CLICK
        }
        if segue.identifier == "peopleSearchSegue" {
            let indexPath = searchTableView.indexPathForSelectedRow
            let selectedUser = usersData[indexPath!.row]
            let destination = segue.destination as! FriendProfileViewController
            destination.user = selectedUser
        }
    }
}
