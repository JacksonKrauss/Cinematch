//
//  TabBarViewController.swift
//  Cinematch
//
//  Created by Jackson Krauss on 12/5/20.
//

import UIKit

class TabBarViewController: UITabBarController {

    //sets light or dark mode
    override func viewDidLoad() {
        super.viewDidLoad()
        switch CURRENT_USER.visualMode {
        case .light:
            self.tabBar.barStyle = .default
        case .dark:
            self.tabBar.barStyle = .black
        }
    }

}
