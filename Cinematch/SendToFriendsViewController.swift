//
//  SendToFriendsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class SendToFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = OTHER_USERS.filter { (user: User) -> Bool in
            return (user.name!.lowercased().contains(searchBar.text!.lowercased()) || user.username!.lowercased().contains(searchBar.text!.lowercased()))
        }
        if(searchText.isEmpty){
            filteredUsers = OTHER_USERS
        }
        tableView.reloadData()
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
            filteredUsers = OTHER_USERS
            tableView.reloadData()
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! SendToFriendTableViewCell
        cell.nameLabel.text = filteredUsers[indexPath.row].name
        cell.userLabel.text = filteredUsers[indexPath.row].username
        cell.profilePicView.image = filteredUsers[indexPath.row].profilePicture
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers?.append(filteredUsers[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUsers?.remove(object: filteredUsers[indexPath.row])
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var filteredUsers: [User]!
    var selectedUsers: [User]!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        searchBar.delegate = self
        self.selectedUsers = []
        self.filteredUsers = OTHER_USERS
        
        // Do any additional setup after loading the view.
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
