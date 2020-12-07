//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import FirebaseDatabase

protocol updateProfile {
    func updateProfilePicture(image: UIImage)
    func updateProfileTextFields(name: String, bio: String)
    func updateProfileColors()
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, SwipeDelegate, updateProfile {
    
    //adds a movie to the correct list and reloads the collectionview
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: filteredMovies[index]){
            self.collectionView.reloadData()
        }
        
    }
    
    func reload() {
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            filteredMovies = CURRENT_USER.liked
        case 1:
            filteredMovies = CURRENT_USER.history
        default:
            break
        }
        collectionView.reloadData()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noMoviesView: UIView!
    @IBOutlet weak var noMoviesLabel: UILabel!
    
    var currentUser: User!
    var filteredMovies: [Movie]!
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = CURRENT_USER
        movieViewSegCtrl.selectedSegmentIndex = 0
        collectionView.reloadData()
        renderViews()
        setColors(CURRENT_USER.visualMode, self.view)
        filteredMovies = CURRENT_USER.liked
        //display message if there are no liked movies
        if filteredMovies.count == 0 {
            collectionView.isHidden = true
            noMoviesView.isHidden = false
            noMoviesLabel.text = "You do not have any liked movies."
        } else {
            collectionView.isHidden = false
            noMoviesView.isHidden = true
        }
    }
    
    //sets up users profile information
    func renderViews() {
        usernameTextLabel.text = currentUser.username
        fullNameTextLabel.text = currentUser.name
        bioTextLabel.text = currentUser.bio
        profilePicture.image = currentUser.profilePicture
        Util.makeImageCircular(profilePicture)
    }
    
    // function to update profile settings from settings view
    func updateProfilePicture(image: UIImage) {
        profilePicture.image = image
    }
    
    // updates profile settings from settings view
    func updateProfileTextFields(name: String, bio: String) {
        fullNameTextLabel.text = name
        bioTextLabel.text = bio
    }
    
    // updates dark mode settings from settings view
    func updateProfileColors() {
        setColors(CURRENT_USER.visualMode, self.view)
        switch CURRENT_USER.visualMode {
        case .light:
            self.tabBarController!.tabBar.barStyle = .default
        case .dark:
            self.tabBarController!.tabBar.barStyle = .black
        }
        //force reloads the tab bar
        let tab = self.tabBarController!.tabBar
        let sup = self.tabBarController!.tabBar.superview
        tab.removeFromSuperview()
        sup!.addSubview(tab)
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue",
           let nextVC = segue.destination as? SettingsViewController {
            nextVC.delegate = self
        }
        if(segue.identifier == "profileDetailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = filteredMovies[index]
                detailViewController.currentIndex = index
            }
        }
    }

    //show either liked movies or the history view
    @IBAction func selectCollection(_ sender: Any) {
        switch movieViewSegCtrl.selectedSegmentIndex {
        //liked movies
        case 0:
            if CURRENT_USER.liked.count == 0 {
                collectionView.isHidden = true
                noMoviesView.isHidden = false
                noMoviesLabel.text = "You do not have any liked movies."
                return
            } else {
                collectionView.isHidden = false
                noMoviesView.isHidden = true
            }
            if (searchBar.text!.isEmpty) {
                filteredMovies = CURRENT_USER.liked
            } else {
                filteredMovies = CURRENT_USER.liked.filter { (movie: Movie) -> Bool in
                    return (movie.title!.lowercased().contains(searchBar.text!.lowercased()))
                    
                }
            }
        //user history
        case 1:
            if CURRENT_USER.history.count == 0 {
                collectionView.isHidden = true
                noMoviesView.isHidden = false
                noMoviesLabel.text = "You do not have any movies in your history."
                return
            } else {
                collectionView.isHidden = false
                noMoviesView.isHidden = true
            }
            if (searchBar.text!.isEmpty) {
                filteredMovies = CURRENT_USER.history.reversed()
            } else {
                filteredMovies = CURRENT_USER.history.filter { (movie: Movie) -> Bool in
                    return (movie.title!.lowercased().contains(searchBar.text!.lowercased()))
                }.reversed()
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profileDetailSegue", sender: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"profileCollectionViewCell", for:indexPath) as! ProfileCollectionViewCell
        switch movieViewSegCtrl.selectedSegmentIndex {
        //liked movies
        case 0:
            cell.historyView.isHidden = true
        //all movie history - opinions on movies should be shown
        case 1:
            cell.historyView.isHidden = false
            cell.historyView.backgroundColor = .none
            switch filteredMovies[indexPath.row].opinion {
            case .like:
                cell.historyView.image = UIImage(systemName: "hand.thumbsup.fill")
                cell.historyView.tintColor = .systemGreen
            case .dislike:
                cell.historyView.image = UIImage(systemName: "hand.thumbsdown.fill")
                cell.historyView.tintColor = .systemRed
            case .watchlist:
                cell.historyView.image = UIImage(systemName: "plus.app.fill")
                cell.historyView.tintColor = .systemBlue
            default:
                break
            }
        default:
            break
        }
        
        //add images
        if(filteredMovies[indexPath.row].posterImg == nil){
            if(filteredMovies[indexPath.row].poster == nil){
                cell.moviePoster.backgroundColor = .white
                cell.moviePoster.image = UIImage(named: "image-placeholder")
                filteredMovies[indexPath.row].posterImg = UIImage(named: "image-placeholder")
            }
            else{
                cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + filteredMovies[indexPath.row].poster!)!)
            }
        }
        else{
            cell.moviePoster.image = filteredMovies[indexPath.row].posterImg!
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
                
        return CGSize(width: widthPerItem, height: 160)
    }
      
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
      
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    @IBAction func movieViewSelected(_ sender: Any) {
        self.collectionView.reloadData()
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //filters through the movie data when there is search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // no search query
        if (searchText.isEmpty) {
            switch movieViewSegCtrl.selectedSegmentIndex {
            case 0:
                filteredMovies = CURRENT_USER.liked
            case 1:
                filteredMovies = CURRENT_USER.history.reversed()
            default:
                break
            }
        // populated search query
        } else {
            switch movieViewSegCtrl.selectedSegmentIndex {
            //filters through liked movie data
            case 0:
                filteredMovies = CURRENT_USER.liked.filter { (movie: Movie) -> Bool in
                    return (movie.title!.lowercased().contains(searchBar.text!.lowercased()))
                    
                }
            //filters through history data
            case 1:
                filteredMovies = CURRENT_USER.history.filter { (movie: Movie) -> Bool in
                    return (movie.title!.lowercased().contains(searchBar.text!.lowercased()))
                    
                }.reversed()
            default:
                break
            }
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
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            filteredMovies = CURRENT_USER.liked
        case 1:
            filteredMovies = CURRENT_USER.history.reversed()
        default:
            break
        }
        collectionView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

