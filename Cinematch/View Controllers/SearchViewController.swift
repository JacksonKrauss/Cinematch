//
//  SearchViewController.swift
//  Cinematch
//
//  Created by Maegan Parfan on 10/19/20.
//

import UIKit
import Koloda
import TMDBSwift
import Firebase

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, SwipeDelegate {
    
    func reload() {
    }
    
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
            let movie = Movie()
            movie.setFromMovie(movie:  moviesData[index])
            Movie.addToList(direction: direction, movie: movie){
                
            }
    }
    
    var usersData:[User] = []
    var moviesData:[MovieMDB] = []
    var page = 1
    var hitEnd = false
    var currentQuery = ""
    var imageCache = NSCache<NSString, UIImage>()
    var startPeople = false
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTypeSegCtrl: UISegmentedControl!
    @IBOutlet weak var searchTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchBar.delegate = self
        searchTableView.rowHeight = 166
        searchTypeSegCtrl.selectedSegmentIndex = startPeople == true ? 1 : 0
    }
    
    @IBAction func filterSelected(_ sender: Any) {
        // table view needs to be updated
        searchTableView.reloadData()
        clickSearchButton(self)
        
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
    
    @IBAction func clickSearchButton(_ sender: Any) {
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
        
        usersData = []
            
        ref.child("user_info").observe(.value) {snapshot in
            for userSnap in snapshot.children.allObjects as! [DataSnapshot] {
                
                let user = User(userSnap, userSnap.key)
                
                if !self.currentQuery.isEmpty,
                   let name = user.name,
                   let username = user.username
                   {
                    let query = self.currentQuery.lowercased()
                    if name.lowercased().contains(query) ||
                        username.lowercased().contains(query)
                    {
                        self.usersData.append(user)
                    }
                }
            }
            self.searchTableView?.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        usersData = []
        searchBar.text = ""
        searchTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentQuery = searchText
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
        //MOVIE CELL
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieSearchTableViewCell

            if moviesData.count > indexPath.row {
                
                //movie data
                let currentMovie = moviesData[indexPath.row]
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
                                        
                    if let image = imageCache.object(forKey: path as NSString) {
                        cell.moviePosterImageView.image = image
                    } else {
                        
                        let url = "https://image.tmdb.org/t/p/original" + path
                        
                        URLSession.shared.dataTask(with: URL(string: url)!) { [self] (data, response, error) in
                                                        
                            if (error != nil) {
                                print(error)
                                return
                            }
                                                        
                            let image = UIImage(data: data!)
                            
                            imageCache.setObject(image!, forKey: path as NSString)
                                                        
                            DispatchQueue.main.async {
                                cell.moviePosterImageView.image = image
                            }
                            
                        }.resume()
                    }
                //No poster
                } else {
                    cell.moviePosterImageView.image = UIImage(named: "no-image")
                }
            }
            
            //load the next set of moviesData
            if (indexPath.row == moviesData.count - 1 && !hitEnd){
                self.loadMovies()
            }
                    
            return cell
        //PERSON CELL
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PeopleSearchTableViewCell
            //user data
            let currentPerson = usersData[indexPath.row]
            cell.nameLabel?.text = currentPerson.name
            cell.usernameLabel?.text = currentPerson.username
            
            //image settings
            cell.profilePicImageView.backgroundColor = .gray
            let placeholderImage = UIImage(named: "image-placeholder")
            let path = "profile_pictures/\(currentPerson.username ?? "")"
            print("path", path)
            let reference = storageRef.child(path)
            cell.profilePicImageView?.sd_setImage(with: reference, placeholderImage: placeholderImage)
            if (cell.profilePicImageView?.bounds.size.width)! > (cell.profilePicImageView?.bounds.size.height)! {
                cell.profilePicImageView?.contentMode = .scaleAspectFit
            } else {
                cell.profilePicImageView?.contentMode = .scaleAspectFill
            }
            cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.height / 2
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieSearchSegue" {
            if let detailViewController = segue.destination as? MovieDetailViewController{
                let index = searchTableView.indexPathForSelectedRow?.row
                
                //get the movie in form
                let movie = Movie()
                movie.setFromMovie(movie:  moviesData[index!])
                detailViewController.delegate = self
                detailViewController.movie = movie
                detailViewController.currentIndex = index
            }
        }
        if segue.identifier == "peopleSearchSegue" {
            let indexPath = searchTableView.indexPathForSelectedRow
            let selectedUser = usersData[indexPath!.row]
            let destination = segue.destination as! FriendProfileViewController
            destination.user = selectedUser
            //Get real user
            //destination.user = selectedUser
        }
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
