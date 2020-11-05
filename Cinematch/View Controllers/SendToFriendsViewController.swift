//
//  SendToFriendsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class SendToFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // usersList replaced the default OTHER_USERS hardcoded data
    var usersList:[User] = []
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = usersList.filter { (user: User) -> Bool in
            return (user.name!.lowercased().contains(searchBar.text!.lowercased()) || user.username!.lowercased().contains(searchBar.text!.lowercased()))
        }
        if(searchText.isEmpty){
            filteredUsers = usersList
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
            filteredUsers = usersList
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
        if(selectedUsers.contains(filteredUsers[indexPath.row])){
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers?.append(filteredUsers[indexPath.row])
        print("added")
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUsers?.remove(object: filteredUsers[indexPath.row])
        print("removed")
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var filteredUsers: [User]!
    var selectedUsers: [User]!
    var movie: Movie?
    @IBAction func sendButtonPressed(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        searchBar.delegate = self
        self.selectedUsers = []
        self.filteredUsers = usersList
        // Do any additional setup after loading the view.
    }
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
