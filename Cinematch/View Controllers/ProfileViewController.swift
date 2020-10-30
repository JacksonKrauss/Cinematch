//
//  ProfileViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        Movie.addToList(direction: direction, movie: movieData[index])
        collectionView.reloadData()
    }
    
    func reload() {
        collectionView.reloadData()
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var fullNameTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var movieViewSegCtrl: UISegmentedControl!
    // ask about making a consistent class for pfp
    @IBOutlet weak var collectionView: UICollectionView!
    var movieData: [Movie] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextLabel.text = CURRENT_USER.username
        fullNameTextLabel.text = CURRENT_USER.name
        bioTextLabel.text = CURRENT_USER.bio
        profilePicture.image = CURRENT_USER.profilePicture
        profilePicture.layer.cornerRadius = 100 / 2 // fix
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        profilePicture.image = CURRENT_USER.profilePicture
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            return CURRENT_USER.liked.count
        case 1:
            return CURRENT_USER.history.count
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profileDetailSegue", sender: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"profileCollectionViewCell", for:indexPath) as! ProfileCollectionViewCell
        switch movieViewSegCtrl.selectedSegmentIndex {
        case 0:
            cell.historyView.isHidden = true
            movieData = CURRENT_USER.liked
        case 1:
            cell.historyView.isHidden = false
            movieData = CURRENT_USER.history.reversed()
            switch movieData[indexPath.row].opinion {
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
                print("No opinion")
            }
        default:
            break
        }
        if(movieData[indexPath.row].posterImg == nil){
            if(movieData[indexPath.row].poster == nil){
                cell.moviePoster.backgroundColor = .white
                cell.moviePoster.image = UIImage(named: "no-image")
                movieData[indexPath.row].posterImg = UIImage(named: "no-image")
            }
            else{
                cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/original" + movieData[indexPath.row].poster!)!)
            }
        }
        else{
            cell.moviePoster.image = movieData[indexPath.row].posterImg!
        }
        
        return cell
    }
    @IBAction func movieViewSelected(_ sender: Any) {
        self.collectionView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "profileDetailSegue"){
            let index:Int = sender as! Int
            if let detailViewController = segue.destination as? MovieDetailViewController{
                detailViewController.delegate = self
                detailViewController.movie = movieData[index]
                detailViewController.currentIndex = index
            }
        }
    }
    
}
