//
//  Colors.swift
//  Cinematch
//
//  Created by Maegan Parfan on 11/14/20.
//

import Foundation
import UIKit

func setColors(_ visualMode:VisualMode, _ view:UIView) {
    view.backgroundColor = visualMode == VisualMode.light ? UIColor.white : UIColor(named: "DarkModeBackground")
    
    view.subviews.forEach { (view) in
        setViewColor(visualMode, view)
    }
}

func setViewColor(_ visualMode:VisualMode, _ view:UIView) {
    if let label = view as? UILabel {
//        print("\(label) \(label.textColor) \(UIColor(named: "DarkModeSegSelect"))")
        if (label.textColor!.isEqual(UIColor.white) || label.textColor!.isEqual(UIColor.label)) {
            label.textColor = visualMode == VisualMode.light ? UIColor.label : UIColor.white
        } else if (label.textColor!.isEqual(UIColor(named: "DarkModeSegSelect")!) || label.textColor!.isEqual(UIColor(named: "DarkModeSegSelect")!.inverse())){
            label.textColor = visualMode == VisualMode.light ? UIColor(named: "DarkModeSegSelect") : UIColor(named: "DarkModeSegSelect")!.inverse()
        } else if (label.textColor!.isEqual(UIColor.secondaryLabel) || label.textColor!.isEqual(UIColor.secondaryLabel.inverse())) {
            label.textColor = visualMode == VisualMode.light ? UIColor.secondaryLabel : UIColor.secondaryLabel.inverse()
        } else if (label.textColor!.isEqual(UIColor.tertiaryLabel) || label.textColor!.isEqual(UIColor.tertiaryLabel.inverse())) {
            label.textColor = visualMode == VisualMode.light ? UIColor.tertiaryLabel : UIColor.tertiaryLabel.inverse()
        }
    }
    if let textField = view as? UITextField {
        textField.textColor = visualMode == VisualMode.light ? UIColor.black : UIColor.white
        textField.backgroundColor = UIColor(named: "TextFieldBackground")
    }
    if let segmentedCtrl = view as? UISegmentedControl {
        if visualMode == VisualMode.light {
            setSegmentedControlColors(segmentedCtrl, backgroundColor:UIColor(named: "TextFieldBackground")!, selectedSegmentTintColor: UIColor.white, textColor: UIColor.black)
        } else {
            setSegmentedControlColors(segmentedCtrl, backgroundColor:UIColor.black, selectedSegmentTintColor: UIColor(named: "DarkModeSegSelect")!, textColor: UIColor.white)
        }
    }
    if let button = view as? UIButton {
        if !button.tintColor!.isEqual(UIColor(named: "AccentColor")) {
            if visualMode == VisualMode.light {
                button.tintColor = UIColor.black
            } else {
                button.tintColor = UIColor.white
            }
        }
    }
//    if let posterCell = view as? PosterCollectionViewCell {
//        posterCell.backgroundColor = visualMode == VisualMode.light ? UIColor.white : UIColor(named: "DarkModeBackground")
//    }
    if let tableView = view as? UITableView {
        tableView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : UIColor(named: "DarkModeBackground")
    }
    if let collectionView = view as? UICollectionView {
        collectionView.backgroundColor = visualMode == VisualMode.light ? UIColor.white : UIColor(named: "DarkModeBackground")
    }
    if let stackView = view as? UIStackView {
        stackView.subviews.forEach { (view) in
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
