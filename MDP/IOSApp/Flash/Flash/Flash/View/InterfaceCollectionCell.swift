//
//  InterfaceCollectionCell.swift
//  Flash
//
//  Created by Sam Bohnett on 4/29/22.
//

import UIKit

/*
 This is the class that will handle the change in UI from 2D to AR
 AFTER RECENT MEETINGS, THIS WILL PROBABLY BE DELETED AS AR IS NOW A STRETCH GOAL
 */
class InterfaceCollectionCell: UICollectionViewCell {
   
    @IBOutlet weak var mapDisplayLabel: UILabel!
    @IBOutlet weak var interfaceDecider: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        interfaceDecider.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Switch visuals to 2D
        } else if sender.selectedSegmentIndex == 1 {
            // Switch visuals to AR
        } else if sender.selectedSegmentIndex == 2 {
            // Switch visuals to Both
        }
    }
    
}


