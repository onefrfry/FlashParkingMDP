//
//  CustomizationCollectionCell.swift
//  Flash
//
//  Created by Sam Bohnett on 4/29/22.
//

import UIKit

/*
 This is the class that controls the bottom section with all of the toggle switches in the pull out menu in the navigation screen
 These will ultimately enable and disable all of their respective elements and will need to communicate with that view eventually
 */
class CustomizationCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var estimatedTimeToggle: UISwitch!
    @IBOutlet weak var turnSignToggle: UISwitch!
    @IBOutlet weak var distanceToggle: UISwitch!
    @IBOutlet weak var floorToggle: UISwitch!
    @IBOutlet weak var futureStepsToggle: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        estimatedTimeToggle.setOnValueChangeListener {
            // Toggle the estimated time
        }
        turnSignToggle.setOnValueChangeListener {
            // Toggle the turn sign
        }
        distanceToggle.setOnValueChangeListener {
            // Toggle the distance to go on the map
        }
        floorToggle.setOnValueChangeListener {
            // Toggle the floor
        }
        futureStepsToggle.setOnValueChangeListener {
            // Toggle future steps option
        }
    }
  
}
//MARK: - UISwitch Extension
extension UISwitch {
    func setOnValueChangeListener(onValueChanged :@escaping () -> Void){
        self.addAction(UIAction(){ action in onValueChanged() }, for: .valueChanged)
        
    }
}
