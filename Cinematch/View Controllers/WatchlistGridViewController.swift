//
//  WatchlistGridViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import TMDBSwift
import Koloda
class WatchlistGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SwipeDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout{
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 25.0,
                                             left: 10.0,
                                             bottom: 25.0,
                                             right: 10.0)
    //resets the search bar and reloads the view
    func reload() {
        filteredMovies = CURRENT_USER.watchlist
        collectionView.reloadData()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    //searched for the movie title and filters results
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
    //cancel search resets data
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            filteredMovies = CURRENT_USER.watchlist
            collectionView.reloadData()
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    @IBOutlet weak var searchBar: UISearchBar!
    //adds movie to list and reloads view
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: filteredMovies[index]) {
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCollectionViewCell
        //checks to make sure the movie has a poster
        if(filteredMovies[indexPath.row].posterImg == nil){
            if(filteredMovies[indexPath.row].poster == nil){
                //no poster, use default image
                cell.posterImageView.image = UIImage(named: "no-image")
                filteredMovies[indexPath.row].posterImg = UIImage(named: "no-image")
            }
            else{
                //load poster from internet
                cell.posterImageView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + filteredMovies[indexPath.row].poster!)!)
            }
        }
        else{
            //poster has already been loaded previously
            cell.posterImageView.image = filteredMovies[indexPath.row].posterImg!
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = CURRENT_USER.visualMode == VisualMode.light ? UIColor.white : darkModeBackground
    }
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
                
        return CGSize(width: widthPerItem, height: 150)
      }
      
      //3
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
      }
      
      // 4
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
      }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    var filteredMovies:[Movie]!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        //hide navigation bar
        self.navigationController?.navigationBar.isHidden = true
        filteredMovies = CURRENT_USER.watchlist
    }
    override func viewWillAppear(_ animated: Bool) {
        filteredMovies = CURRENT_USER.watchlist
        collectionView.reloadData()
        setColors(CURRENT_USER.visualMode, self.view)
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
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
