//
//  Colors.swift
//  Cinematch
//
//  Created by Maegan Parfan on 11/14/20.
//

import Foundation
import UIKit

var accentColor = UIColor(named: "AccentColor")
var darkModeBackground = UIColor(named: "DarkModeBackground")
var darkModeTextOrHighlight = UIColor(named: "DarkModeTextOrHighlight")
var textFieldBackground = UIColor(named: "TextFieldBackground")

//set to either light or dark mode
func setColors(_ visualMode:VisualMode, _ view:UIView) {
    view.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
    view.subviews.forEach { (view) in
        setViewColor(visualMode, view)
    }
}

//set specific colors for each UI element
func setViewColor(_ visualMode:VisualMode, _ view:UIView) {
    if let label = view as? UILabel {
        if (label.textColor!.isEqual(UIColor.white) || label.textColor!.isEqual(UIColor.label)) {
            label.textColor = visualMode == VisualMode.light ? UIColor.label : UIColor.white
        } else if (label.textColor!.isEqual(darkModeTextOrHighlight!) || label.textColor!.isEqual(darkModeTextOrHighlight!.inverse())){
            label.textColor = visualMode == VisualMode.light ? darkModeTextOrHighlight : darkModeTextOrHighlight!.inverse()
        } else if (label.textColor!.isEqual(UIColor.secondaryLabel) || label.textColor!.isEqual(UIColor.secondaryLabel.inverse())) {
            label.textColor = visualMode == VisualMode.light ? UIColor.secondaryLabel : UIColor.secondaryLabel.inverse()
        } else if (label.textColor!.isEqual(UIColor.tertiaryLabel) || label.textColor!.isEqual(UIColor.tertiaryLabel.inverse())) {
            label.textColor = visualMode == VisualMode.light ? UIColor.tertiaryLabel : UIColor.tertiaryLabel.inverse()
        }
    } else if let textField = view as? UITextField {
        textField.textColor = visualMode == VisualMode.light ? UIColor.black : UIColor.white
        textField.backgroundColor = textFieldBackground
    } else if let segmentedCtrl = view as? UISegmentedControl {
        if visualMode == VisualMode.light {
            setSegmentedControlColors(segmentedCtrl, backgroundColor: textFieldBackground!, selectedSegmentTintColor: UIColor.white, textColor: UIColor.black)
        } else {
            setSegmentedControlColors(segmentedCtrl, backgroundColor:UIColor.black, selectedSegmentTintColor: darkModeTextOrHighlight!, textColor: UIColor.white)
        }
    } else if let button = view as? UIButton {
        if !button.tintColor!.isEqual(accentColor) {
            if visualMode == VisualMode.light {
                button.tintColor = UIColor.black
            } else {
                button.tintColor = UIColor.white
            }
        }
    } else if let searchBar = view as? UISearchBar {
        searchBar.barTintColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        searchBar.searchTextField.leftView?.tintColor = visualMode == VisualMode.light ? UIColor.secondaryLabel : UIColor.secondaryLabel.inverse()
        searchBar.searchTextField.textColor = visualMode == VisualMode.light ?
            UIColor.label : UIColor.white
    }
    else if let scrollView = view as? UIScrollView {
        scrollView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        scrollView.subviews.forEach { (view) in
            setViewColor(visualMode, view)
        }
    }
    else if let tableView = view as? UITableView {
        tableView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        tableView.subviews.forEach { (view) in
            setViewColor(visualMode, view)
        }
    } else if let collectionView = view as? UICollectionView {
        collectionView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        collectionView.subviews.forEach { (view) in
            setViewColor(visualMode, view)
        }
    } else if let stackView = view as? UIStackView {
        stackView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        stackView.subviews.forEach { (view) in
            setViewColor(visualMode, view)
        }
    }
    else if let activityIndicator = view as? UIActivityIndicatorView {
        activityIndicator.color = visualMode == VisualMode.light ? UIColor.white : darkModeTextOrHighlight
        activityIndicator.backgroundColor = .clear
        activityIndicator.style = .large
    }
    else if let tabBar = view as? UITabBar {
        
    }
    else if let tabBarItem = view as? UITabBarItem {
        
    }
    else {
        view.backgroundColor = visualMode == VisualMode.light ? UIColor.white : darkModeBackground
        view.subviews.forEach { (view) in
            setViewColor(visualMode, view)
        }
    }
}

func setSegmentedControlColors(_ segmentedCtrl:UISegmentedControl, backgroundColor:UIColor, selectedSegmentTintColor:UIColor, textColor:UIColor) {
    segmentedCtrl.backgroundColor = backgroundColor
    segmentedCtrl.selectedSegmentTintColor = selectedSegmentTintColor
    let titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        segmentedCtrl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedCtrl.setTitleTextAttributes(titleTextAttributes, for: .selected)
}

extension UIColor {
    func inverse () -> UIColor {
        var r:CGFloat = 0.0;
        var g:CGFloat = 0.0;
        var b:CGFloat = 0.0;
        var a:CGFloat = 0.0;
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return .black // Return a default colour
    }
    
    func isEqualWithConversion(_ color: UIColor) -> Bool {
            guard let space = self.cgColor.colorSpace
                else { return false }
            guard let converted = color.cgColor.converted(to: space, intent: .absoluteColorimetric, options: nil)
                else { return false }
            return self.cgColor == converted
    }
}
