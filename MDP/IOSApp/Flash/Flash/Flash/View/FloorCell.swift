//
//  FloorCell.swift
//  Flash
//
//  Created by Sam Bohnett on 4/3/22.
//

import UIKit

/*
 The buttons at the top of the screen when we are inputting in our information about where we parked. These buttons would hopefully be able to show different floors of the map depending on which one is selected.
 NOT SURE IF WE ARE KEEPING THESE
 */

class FloorCell: UICollectionViewCell {

    
    @IBOutlet weak var floorButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        floorButton.layer.cornerRadius = floorButton.frame.height / 3
        floorButton.clipsToBounds = true
    }
    
    
    @IBAction func floorButtonPressed(_ sender: Any) {
        // Change the map to show the current floor
    }
    
    func changeButtonBackgroundColor(to color: UIColor) {
        floorButton.backgroundColor = color
    }
    
}
