//
//  MapScrollCell.swift
//  Flash
//
//  Created by Sam Bohnett on 11/22/22.
//

import UIKit

class MapScrollCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    private var _floorMap: UICollectionView?
    
    var floorMap: UICollectionView {
        get {
            // If map is blank, may make a guard
            return _floorMap ?? UICollectionView()
        }
        
        set (mapIn) {
            _floorMap = mapIn
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    


}
