//
//  ViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 3/28/22.
//

import UIKit

/*
 Attributes for the side menu that gets shown when the setting button is hit in the View2Controller
 */
class SideViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    @IBOutlet weak var sideViewCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setting the delegate and the source of data for the sideViewCollection
        sideViewCollection.delegate = self
        sideViewCollection.dataSource = self
        
        // Setup the constraints for the sideViewCollection itself
        setupConstraints()
        sideViewCollection.translatesAutoresizingMaskIntoConstraints = false
        
        // Register the types of cells that exist to be able to display them in the sideViewCollection
        sideViewCollection.register(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "imageCCell")
        sideViewCollection.register(UINib(nibName: "InterfaceCollectionCell", bundle: nil), forCellWithReuseIdentifier: "interfaceCCell")
        sideViewCollection.register(UINib(nibName: "CustomizationCollectionCell", bundle: nil), forCellWithReuseIdentifier: "customizationCCell")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        Hardcoded, may be changed in the future upon updates
//        Returns the amount of cells in the sidemenu
        return 3
    }
    
    /*
     Iterates through all of the cells in the sideMenu and assigns each section a particular type of cell corresponding to the design
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCCell", for: indexPath) as! ImageCollectionCell
            
            return cell
            
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interfaceCCell", for: indexPath) as! InterfaceCollectionCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customizationCCell", for: indexPath) as! CustomizationCollectionCell
            return cell
            
        }
    }
    
    /*
     Constraint setup for the sideViewCollection similar to the other setupConstraints functions
     */
    func setupConstraints() {
        self.view.addSubview(sideViewCollection)
        NSLayoutConstraint.activate([
            sideViewCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            sideViewCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            sideViewCollection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            sideViewCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        
        ])
        
        // Layout attributes that control spacing between the cells
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        sideViewCollection.collectionViewLayout = layout
    }

}
// Sets the height and width of each cell to specific measurements based on the design
// Really specific to our phone size, does not generalize
extension SideViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: 336, height: 353)
        } else if indexPath.row == 1 {
            return CGSize(width: 336, height: 178)
        } else {
            return CGSize(width: 336, height: 395)
        }
    }
}

