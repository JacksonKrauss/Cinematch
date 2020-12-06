//
//  TabBarViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 12/5/20.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        switch CURRENT_USER.visualMode {
        case .light:
            self.tabBar.barStyle = .default
        case .dark:
            self.tabBar.barStyle = .black
        }
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
