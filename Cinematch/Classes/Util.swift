//
//  Util.swift
//  Cinematch
//
//  Created by Kyle Knight on 12/6/20.
//

import Foundation
import UIKit
class Util {
    static func makeImageCircular(_ imageView:UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        // make the profile picture fit in the circle
        if imageView.frame.width > imageView.frame.height {
            imageView.contentMode = .scaleToFill
        } else {
            imageView.contentMode = .scaleAspectFill
        }
    }
}

