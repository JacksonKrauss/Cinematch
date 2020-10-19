//
//  SendToFriendsViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 10/9/20.
//

import UIKit

class SendToFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTHER_USERS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! SendToFriendTableViewCell
        cell.nameLabel.text = OTHER_USERS[indexPath.row].name
        cell.userLabel.text = OTHER_USERS[indexPath.row].username
        cell.profilePicView.image = OTHER_USERS[indexPath.row].profilePicture
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers?.append(OTHER_USERS[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUsers?.remove(object: OTHER_USERS[indexPath.row])
    }

    @IBOutlet weak var tableView: UITableView!
    var selectedUsers: [User]?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        self.selectedUsers = []
        
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
