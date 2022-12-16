//
//  ViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 3/28/22.
//

import UIKit
import MapKit
import CoreLocation

/*
 This is the entire view controller for the screen after having pressed "Mark My Car"
 
 */
class View1Controller: UIViewController, SetupDelegate, NavigateDelegate {
    /*
     This is the function that will change all of the floor button colors when one of them is pressed
     TODO: Change this to only change the one clicked and the one previously clicked, don't iterate through them all. Too lazy to do it now
     */
    func changeButtons(_ sender: Any) {
        if let buttonPressed = sender as? FloorCell {
            for cell in collectionView.visibleCells as! [FloorCell] {
                if cell == buttonPressed {
                    setButtonClickedOn(on: cell)
                    
                } else {
                    setButtonClickedOff(on: cell)
                    
                }
            }
        }
        
        
    }
    /*
     Takes in a on or off choice and will show or hide the spinner view
     Is triggered when "Try Again" is hit
     */
    func toggleBlur(_ toggle: Bool) {
        if (toggle) {
            customSpinnerView.show()
        } else {
            customSpinnerView.hide()
        }
        blurEffectView.isHidden = !toggle
        blurEffectView.isUserInteractionEnabled = toggle
    }
    // Moves findCarView to the front of all other views
    func removeView() {
        self.view?.bringSubviewToFront(findCarView)
    }
    // Sets the label after localization or user chooses them
    func changeLabels(for inputs: [String]) {
        areaLabel.text = "Area " + inputs[0] + " Lot " + inputs[1]
    }
    
    func runTestMain() {
        runTestNavMain()
    }
    

    @IBOutlet weak var mapCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tabBar: UITabBar!
    var delegate: SetupDelegate?
    var navDelegate: NavigateDelegate?
    var userLocation: Coord?
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var garage: NSMutableArray?
    var navOutput: NSMutableArray?
    var amountOfFloors: Int?
    var widthOfMap: Int32?
    var heightOfMap: Int32?
    
//    Dummy values
//    Will see how these work later
    // TODO: Figure out the significance and how to get these
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "A495DE30-C5B1-4B44-B512-1370F02D74DF"
    
    /*
     Could probably refactor this mess lol
     More or less just setups some of the attributes with the beaconRegion and locationManager (THIS IS UNTESTED DUE TO IT BEING ONLY ON A SIMULATOR)
    More research is needed here since this is getting into the localization stuff
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let uuid = NSUUID(uuidString: BRAND_UUID)
        
        // beaconRegion information/setup
        beaconRegion = CLBeaconRegion(uuid: uuid! as UUID, identifier: BRAND_IDENTIFIER)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        // locationManager information/setup
        locationManager.delegate = self
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        
        // Setup the collectionView, what contains the floor buttons
        
        collectionView.delegate = self
        delegate = self
        navDelegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constants.floorCell, bundle: nil), forCellWithReuseIdentifier: Constants.floorButton)
        
        generateMapCollectionView()
        
        // Setting up spinner view
        customSpinnerView.center = CGPoint(
                x: blurEffectView.bounds.midX,
                y: blurEffectView.bounds.midY
            )
        
        // Setup constraints for UI elements as well as presenting other screens
        presentModalController()
        setupConstraints()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        //TODO: Find a way to fix the map dissappearing
        runTestNavMain()
    }
    
    /*
     Setting up the button that appears when the "try-again and "confirm" screen descends
     */
    lazy var findMyCarButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(red: 0xDA/0xFF, green: 0xDA/0xFF, blue: 0xDA/0xFF, alpha: 1)
        // Configures title information
        button.setTitle("Find My Car", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        
        button.layer.cornerRadius = 5
        
        // Button functionality by adding target
        button.addTarget(self, action: #selector(moveToNavigation), for: .touchUpInside)
        
        
        // Button shadow attributes
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        
        
        return button
        
    }()
    /*
     The view that contains the "confirm" and "try again" buttons
     TODO: Fix the problem that the view covers the whole screen
     */
    lazy var findCarView: UIView = {
        let view = UIView()
        // Set the background color
        view.backgroundColor = UIColor(red: 0xFF / 0xFF, green: 0xFF / 0xFF, blue: 0xFF / 0xFF, alpha: 1)
        
        view.layer.cornerRadius = 10
        
        // Set the shadow attributes
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.0
        
        return view
    }()
    /*
     The label that matches the current UI design
     The one that goes before the numbers that are typed in by the user if the localization messes up
     */
    lazy var staticLabel: UILabel = {
        let label = UILabel()
        label.text = "Your car is parked in"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    /*
     This is the label that displays the parking lot number and area numbers
     */
    lazy var areaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 35)
        return label
    }()
    
    /*
     This is a container that allows elements within it to be laid out in a convenient way
     Easy to adjust spacing between elements, allow for vertical or horizantal stacking, and if all elements are to be centered
     */
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [staticLabel, areaLabel, findMyCarButton])
        stackView.axis = .vertical
        stackView.spacing = 10.0
        stackView.alignment = .center
        return stackView
    }()
    
    /*
     The view that appears to blur everything when the color spinner shows up
     */
    lazy var blurEffectView: UIVisualEffectView = {
        // Making the actual blurEffect using the built in library
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        
        // Create the view using the blur effect
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Configuring some of the other attributes of the view
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isHidden = true
        blurEffectView.alpha = 0.9
        blurEffectView.isUserInteractionEnabled = false
        
        return blurEffectView
    }()
    
    /*
     Create the actual view containing the spinner itself
     */
    lazy var customSpinnerView: CustomActivityIndicator = {
        let view = CustomActivityIndicator()
        return view
    }()
    
    /*
     The function that actually allows the "Find My Car" view to be displayed
     The entire view itself comes from the CustomModalViewController class
     */
    @objc func presentModalController() {
        let vc = CustomModalViewController()
        vc.modalPresentationStyle = .overCurrentContext
        // Keep animated value as false
        // Custom Modal presentation animation will be handled in VC itself
        vc.delegate = self.delegate
        self.present(vc, animated: false)
        
        
    }
    // Just assigns the appropriate ending to the numbers in the floor buttons
    // Probably went overkill, but whatever
    func assignEnding(for button: UIButton, with number: Int) {
        if ((number + 1) % 10 == 1 && (number + 1) % 100 != 11) {
            button.setTitle("\(number + 1)st Floor", for: .normal)
        } else if ((number + 1) % 10 == 2 && (number + 1) % 100 != 12) {
            button.setTitle("\(number + 1)nd Floor", for: .normal)
        } else if ((number + 1) % 10 == 3 && (number + 1) % 100 != 13) {
            button.setTitle("\(number + 1)rd Floor", for: .normal)
        } else {
            button.setTitle("\(number + 1)th Floor", for: .normal)
        }
    }
    
    /*
     This moves us into the screen where the navigation takes our user back to their car
     At this point, the Nav code as it stands is ran through the wrapping of the C++
     */
    @objc func moveToNavigation() {
        performSegue(withIdentifier: Constants.navigation, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? View2Controller
        vc?.collectionViewMap = mapCollectionView
        vc?.navOutput = navOutput
        vc?.delegate = navDelegate
        vc?.userLocation = userLocation
        vc?.widthOfMap = widthOfMap
        vc?.heightOfMap = heightOfMap
    }
    
    /*
     Function that setups up the order of the screens and constrains the UI elements
     NOTE: This will probably only look well on the IPhone 13 pro max, to save time
     */
    func setupConstraints() {
        // Adding views on top of the main view
        view.addSubview(findCarView)
        view.addSubview(blurEffectView)
        view.addSubview(customSpinnerView)
        
        // Adding views on top of the findCarView
        findCarView.addSubview(contentStackView)
        
        
        findCarView.translatesAutoresizingMaskIntoConstraints = false;
        contentStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        // TabBar attributes
        // Probably won't keep this
        tabBar.layer.cornerRadius = 10
        tabBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        tabBar.layer.shadowOpacity = 1.0
        tabBar.layer.shadowRadius = 0.0
        
        /*
         Setting the constraints for the individual sides of the bounding boxes for all of the UI elements
            TOP-ANCHOR: Top of the object
            LEADING-ANCHOR: Left side of the object
            TRAILING-ANCHOR: Right side of the object
            BOTTOM-ANCHOR: Bottom of the object
            HEIGHT-ANCHOR: The height of the object
            WIDTH-ANCHOR: The width of the anchor
         */
        NSLayoutConstraint.activate([
        
            // findMyCar anchor constraints
            findCarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 659),
            findCarView.heightAnchor.constraint(equalToConstant: 180),
            findCarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            findCarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            // ContentStackView anchor constraints
            contentStackView.bottomAnchor.constraint(equalTo: findCarView.bottomAnchor, constant: 0),
            contentStackView.topAnchor.constraint(equalTo: findCarView.topAnchor, constant: 0),
            contentStackView.leadingAnchor.constraint(equalTo: findCarView.leadingAnchor, constant: 0),
            contentStackView.trailingAnchor.constraint(equalTo: findCarView.trailingAnchor, constant: 0),
            
            // Find My Car button anchor constraints
            findMyCarButton.bottomAnchor.constraint(equalTo: findCarView.bottomAnchor, constant: -20),
            findMyCarButton.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -20),
            findMyCarButton.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 20),
            
            // Blur effect view anchor consraints
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    /*
     Avi's Nav main function
     Constants are defined and changed as necessary in the Constants.swift
     NavWrapper is obviously the wrapper of C++
     */
    func runTestNavMain() {
        // Serves as an example of the code in C++ main
        if (garage != nil) {
            reloadAllMapCollectionViewCells(on: Int(userLocation!.z), with: mapCollectionView)
        } else {
            let testGarage = NavWrapper();
            widthOfMap = 13
            heightOfMap = 13
            testGarage.initMap(3, widthOfMap ?? 1, heightOfMap ?? 1);
            
            
            testGarage.setMapRange(0, 0, 1, 0, 1, Constants.cCharE);
            testGarage.setMapRange(0, 0, 1, 11, 12, Constants.cCharE);
            testGarage.setMapRange(0, 11, 12, 0, 1, Constants.cCharE);
            testGarage.setMapRange(0, 11, 12, 11, 12, Constants.cCharE);
            testGarage.setMapRange(0, 2, 10, 0, 1, Constants.cCharP);
            testGarage.setMapRange(0, 2, 10, 11, 12, Constants.cCharP);
            testGarage.setMapRange(0, 0, 1, 3, 9, Constants.cCharP);
            testGarage.setMapRange(0, 11, 12, 3, 9, Constants.cCharP);
            testGarage.setMapRange(0, 4, 5, 3, 9, Constants.cCharP);
            testGarage.setMapRange(0, 7, 8, 3, 9, Constants.cCharP);
            testGarage.setMapRange(0, 6, 6, 3, 9, Constants.cCharX);
            testGarage.setMapRange(1, 2, 10, 0, 1, Constants.cCharP);
            testGarage.setMapRange(1, 2, 10, 11, 12, Constants.cCharP);
            testGarage.setMapRange(1, 0, 1, 3, 9, Constants.cCharP);
            testGarage.setMapRange(1, 11, 12, 3, 9, Constants.cCharP);
            testGarage.setMapRange(1, 4, 5, 3, 9, Constants.cCharP);
            testGarage.setMapRange(1, 7, 8, 3, 9, Constants.cCharP);
            testGarage.setMapRange(1, 6, 6, 3, 9, Constants.cCharX);
            testGarage.setMapRange(2, 2, 10, 0, 1, Constants.cCharP);
            testGarage.setMapRange(2, 2, 10, 11, 12, Constants.cCharP);
            testGarage.setMapRange(2, 0, 1, 3, 9, Constants.cCharP);
            testGarage.setMapRange(2, 11, 12, 3, 9, Constants.cCharP);
            testGarage.setMapRange(2, 4, 5, 3, 9, Constants.cCharP);
            testGarage.setMapRange(2, 7, 8, 3, 9, Constants.cCharP);
            testGarage.setMapRange(2, 6, 6, 3, 9, Constants.cCharX);
            
            testGarage.setMapPoint(0, 7, 10, Constants.cCharS);
            testGarage.setMapPoint(2, 9, 1, Constants.cCharC);
            testGarage.navigateRegular();
            testGarage.printNavMap()
            navOutput = testGarage.returnOutput();
            garage = testGarage.returnGarage();
            
            amountOfFloors = garage!.count
            //For testing purposes
            userLocation = Coord()
            userLocation!.x = 7
            userLocation!.y = 10
            userLocation!.z = 0
        }
        
    }
    /*
     Setting the color of the floor buttons to be different when they are clicked and when they aren't clicked
     */
    private func setButtonClickedOn(on cell: FloorCell) {
        cell.floorButton.isSelected = true
        cell.changeButtonBackgroundColor(to: UIColor(red: 0xE9/0xFF, green: 0x74/0xFF, blue: 0x57/0xFF, alpha: 1))

        cell.floorButton.setTitleColor(UIColor.white, for: .selected)
    }
    private func setButtonClickedOff(on cell: FloorCell) {
        cell.floorButton.isSelected = false
        cell.floorButton.setTitleColor(UIColor(red: 0xB3/0xFF, green: 0xB2/0xFF, blue: 0xB5/0xFF, alpha: 1), for: .normal)
        cell.changeButtonBackgroundColor(to: UIColor(red: 0xF9/0xFF, green: 0xF6/0xFF, blue: 0xFE/0xFF, alpha: 1))
    }
    
    func generateMapCollectionView() {
        // Setup the mapCollectionView which will contain the map characters
        // TODO: Switch these to contained images as opposed to characters
        mapCollectionView.delegate = self
        mapCollectionView.dataSource = self
        mapCollectionView.register(UINib(nibName: Constants.mapCell, bundle: nil), forCellWithReuseIdentifier: Constants.mapCell)
    }
    
}
/*
 The delegate for the collection view
 Methods that have to be ran to define the element of the collectionView
 */
extension View1Controller: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == mapCollectionView) {
            return Int(widthOfMap! * heightOfMap!)
        }
        return amountOfFloors!
    }
    
    /*
     Creating "amountOfFloors" cells and setting up their properties
     This gets called when the collectionView gets created
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Functionality for the floor buttons collectionView
        if (collectionView != mapCollectionView) {
            // Creating the cell from the FloorCell framework
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.floorButton, for: indexPath) as! FloorCell
          
            // Assign the ending based on the number
            assignEnding(for: cell.floorButton, with: indexPath.row)
            
            // Add the functionality to the button upon clicking it
            cell.floorButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
            // Setting all of the buttons but the first one to the "on" position
            if (indexPath.row == 0) {
                setButtonClickedOn(on: cell)
            } else {
                setButtonClickedOff(on: cell)
            }
            
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.mapCell, for: indexPath) as! MapCell
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         
        if (collectionView == mapCollectionView) {
            let height = collectionView.frame.height
            let width = collectionView.frame.width
            
            return CGSize(width: width / CGFloat(widthOfMap!), height: height / CGFloat(heightOfMap!))
        }
        // The size of the cell hardcoded to work on Iphone 13
        // Make this able to scale to different phone sizes
        return CGSize(width: 245, height: 76)
    }
    // Will go through the entire map and update all of the symbols that need updating
    // Will fail if the whole map isn't displayed (all cells displayed)
    func reloadAllMapCollectionViewCells(on floor: Int, with map: UICollectionView) {
        var count: Int = 0
        if let garage = garage, let rows = garage[floor] as? NSMutableArray {
            for x in 0 ... rows.count - 1 {
                if let cols = rows[x] as? NSMutableArray {
                    for y in 0 ... cols.count - 1 {
                        if let tileVal = cols[y] as? Tile, let openedCell = map.cellForItem(at: [0, count]) as? MapCell {
                            imageTranslation(on: openedCell, String(UnicodeScalar(UInt8(tileVal.value))))
                            
                            count = count + 1
                        }
                    }
                }
            }
        }
    }
    // Sets the correct image for each tile of the map
    func imageTranslation(on openedCell: MapCell, _ stringVal: String) {
        var picType: String;
        
        switch(stringVal) {
            case "P":
                picType = "Parking Icon"
                break
            
            case "E":
                picType = "elevator"
                break
            
            case "X":
                picType = "X"
                break
            
            case "S":
                picType = "Current Nav Icon"
                break
            
            case "C":
                picType = "Destination"
                break
            
            case ".":
                picType = "Blank"
                break
            
            default:
            // Unexpected Character, will assume a walking space
                picType = "Blank"
                break
        }
        
        openedCell.floorLabelPiece.image = UIImage(named: picType)
    }
    /*
     This is the function where the map will change depending on the floor that is selected
     Essentially the floor button functionality
     */
    @objc func tap(_ sender: UITapGestureRecognizer) {

       let location = sender.location(in: self.collectionView)
       let indexPath = self.collectionView.indexPathForItem(at: location)

        if let index = indexPath {
            if let buttonPressed = collectionView.visibleCells[index.row] as? FloorCell {
                delegate?.changeButtons(buttonPressed)
                reloadAllMapCollectionViewCells(on: index.row, with: mapCollectionView)
            }
        }
        
        
    }
    
}
/*
 The delegate method that will run depending on the amount of beacons that the phone detects nearby
 TODO: Learn more about how this delegate manager works with the localization team
 */
extension View1Controller: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if beacons.count > 0 {
            // Obtain RSSI Values that we can use for the localization algorithm
        } else {
            // Let the user know that they have ventured out of bounds of this app's usefulness
        }
    }
    
}

