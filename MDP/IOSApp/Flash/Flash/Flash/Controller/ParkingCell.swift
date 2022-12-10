//
//  ParkingCell.swift
//  Flash
//
//  Created by Sam Bohnett on 4/2/22.
//

import UIKit

/*
 These are the cells that are in the tableview for the screen where we enter in the parking lot number
 */
class ParkingCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var informationField: UITextField!
    @IBOutlet weak var highlighterImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var textFieldResult: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // We allow this class to be able to handle tasks that each cell needs to do
        informationField?.delegate = self
        informationField?.isHidden = true
        textFieldResult?.text = ""
    }

    /*
     This allows the cells to change colors when selected and deselected. It also brings up the textfield box and hides it from view when deselected
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if (selected) {
            self.returnView().backgroundColor = UIColor.black.withAlphaComponent(0.1)
            informationField.isHidden = false
            informationField.text = textFieldResult.text
        } else {
            self.returnView().backgroundColor = UIColor.black.withAlphaComponent(0.0)
            informationField.isHidden = true
        }
    }
    
    /*
     Getters and setters for the main view and the textLabels
     */
    func returnView() -> UIView {
        return mainView
    }
    func returnLabel() -> UILabel {
        return textFieldResult
    }
    
    
    
}

/*
 Delegate functions that fire when a user is about to end the interaction with the text field and after it happens
 */
extension ParkingCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        informationField.endEditing(true);
        return true;
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldResult.text = textField.text
        textField.isHidden = true
    }
    
}

