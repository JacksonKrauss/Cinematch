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
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    
    var filteredMovies: [Movie]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = CURRENT_USER
        
        searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    var currentUser: User!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = CURRENT_USER
        collectionView.reloadData()
        renderViews()
        setColors(CURRENT_USER.visualMode, self.view)
        
        filteredMovies = CURRENT_USER.liked
        if filteredMovies.count == 0 {
            collectionView.isHidden = true
            noMoviesView.isHidden = false
            noMoviesLabel.text = "You do not have any liked movies."
        } else {
            collectionView.isHidden = false
            noMoviesView.isHidden = true
        }
    }
    
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
    
    func updateProfileTextFields(name: String, bio: String) {
        fullNameTextLabel.text = name
        bioTextLabel.text = bio
    }
    
    func updateProfileColors() {
        setColors(CURRENT_USER.visualMode, self.view)
        switch CURRENT_USER.visualMode {
        case .light:
            self.tabBarController!.tabBar.barStyle = .default
            //print(self.tabBarController!.tabBar.barStyle.rawValue)
        case .dark:
            self.tabBarController!.tabBar.barStyle = .black
            //print(self.tabBarController!.tabBar.barStyle.rawValue)
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

    @IBAction func selectCollection(_ sender: Any) {
        switch movieViewSegCtrl.selectedSegmentIndex {
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
        case 0:
            cell.historyView.isHidden = true
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
        
        if(filteredMovies[indexPath.row].posterImg == nil){
            if(filteredMovies[indexPath.row].poster == nil){
                cell.moviePoster.backgroundColor = .white
                cell.moviePoster.image = UIImage(named: "no-image")
                filteredMovies[indexPath.row].posterImg = UIImage(named: "no-image")
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            switch movieViewSegCtrl.selectedSegmentIndex {
            case 0:
                filteredMovies = CURRENT_USER.liked
            case 1:
                filteredMovies = CURRENT_USER.history.reversed()
            default:
                break
            }
        } else {
            switch movieViewSegCtrl.selectedSegmentIndex {
            case 0:
                filteredMovies = CURRENT_USER.liked.filter { (movie: Movie) -> Bool in
                    return (movie.title!.lowercased().contains(searchBar.text!.lowercased()))
                    
                }
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

