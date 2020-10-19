//
//  WatchlistListViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit
import Koloda
import TMDBSwift
class WatchlistListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, SwipeDelegate {
    func buttonTapped(direction: SwipeResultDirection, index: Int) {
        let movie = CURRENT_USER.watchlist[index]
        Movie.clearMovie(movie: CURRENT_USER.watchlist[index])
        if(direction == .right){
            CURRENT_USER.liked.append(movie)
            movie.opinion = .like
        }
        else if(direction == .left){
            CURRENT_USER.disliked.append(movie)
            movie.opinion = .dislike
        }
        else if(direction == .up){
            CURRENT_USER.watchlist.append(movie)
            movie.opinion = .watchlist
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CURRENT_USER.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! WatchlistTableViewCell
        cell.posterView.load(url: URL(string: "https://image.tmdb.org/t/p/original" + CURRENT_USER.watchlist[indexPath.row].poster!)!)
        cell.titleLabel.text = CURRENT_USER.watchlist[indexPath.row].title!
        cell.descriptionLabel.text = CURRENT_USER.watchlist[indexPath.row].release!
        cell.ratingLabel.text = CURRENT_USER.watchlist[indexPath.row].rating
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
                detailViewController.movie = CURRENT_USER.watchlist[index]
                detailViewController.currentIndex = index
            }
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchToList(_ sender: Any) {
        print("switched to list")
        //segue
    }
    
    @IBAction func switchToGrid(_ sender: Any) {
        print("switched to grid")
        //segue
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
