//
//  ViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 3/28/22.
//


// Going to add sliding view from bottom containing the "Try Again" and "Confirm" buttons, as well as any other elements to attach
import UIKit


class View2Controller: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setUpFloors()
        return floorTraverse!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Make the cells by dynamically creating a collectionView and constraining it to the view
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.mapScrollCell, for: indexPath)
        return cell
    }
    
    
    @IBOutlet weak var collectionViewMaps: UICollectionView!
    //var garage: NSMutableArray?
    var collectionViewMap: UICollectionView?
    var navOutput: NSMutableArray?
    var delegate: NavigateDelegate?
    
    var userLocation: Coord?
    var heightOfMap: Int32?
    var widthOfMap: Int32?
    
    // Making these next 5 variables is a result of me being dumb and not remembering how timers and #selectors work
    // These could get removed and made local to the beginNavigation function, but due to time, I will keep this messy solution
    var timer: Timer? = nil
    var floorTraverse: [[Coord]]?
    
    private var tempIndex: Int = 0
    private var futureChar: UIImage?
    private var startingFloor: Int = 0
    
    
    private var sideMenu: SideViewController!
    private var sideMenuWidth: CGFloat = 336
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var sideMenuShadowView: UIView!
    
    private var sideMenuTConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    
    //var heightOfMap: Int32?
    //var widthOfMap: Int32?
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    /*
     TODO: Refactor this code, make it easier to follow
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        generateMapCollectionView()
        // Do any additional setup after loading the view.
        // Setup for the dark shadow view that appears for the side view
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        
        // Allows the dark view to receive touch input
        // Sets up amount of touches required and setting the delegate
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Sets the subview at a particular depth
        if self.revealSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }
        
        // Creates a storyboard object
        // These are what can be used and seen in the "Main" view
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Initializing the sideMenu as a SideViewController
        self.sideMenu = storyBoard.instantiateViewController(withIdentifier: "SideMenuID") as? SideViewController
        
        // Inserts the menu as a subView to the whole screen
        // Is either the first or last view in the list of subviews depending on if side view is selected
        view.insertSubview(self.sideMenu!.view, at: self.revealSideMenuOnTop ? 2 : 0)
        addChild(self.sideMenu!)
        self.sideMenu!.didMove(toParent: self)
        
        self.sideMenu.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Sets the appropriate constraints for when the side menu is selected
        if self.revealSideMenuOnTop {
            self.sideMenuTConstraint = self.sideMenu.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuWidth - self.paddingForRotation)
            self.sideMenuTConstraint.isActive = true
        }
        // Setting other constraints that aren't the trailing anchor as that is the one that moves
        NSLayoutConstraint.activate([
            self.sideMenu.view.widthAnchor.constraint(equalToConstant: self.sideMenuWidth),
            self.sideMenu.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenu.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        // Setup Navigation Items
        
        
        // Setup the other UI element constraints/Present other views to make them visible
        setupConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //var queue = DispatchQueue(label: "updateMap", qos: .background)
        
        self.beginNavigation()
        
        
    }
    /*
     Animates the bottom view with the direction and arrow, along with the sidemenu when the settings button is clicked
     */
    func sideMenuState(expanded: Bool) {
            if expanded {
                self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuWidth) { _ in
                    self.isExpanded = true
                }
                // Animate Shadow (Fade In)
                UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6
                    self.animateDismissView()
                }
            }
            else {
                self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuWidth - self.paddingForRotation) : 0) { _ in
                    self.isExpanded = false
                }
                // Animate Shadow (Fade Out)
                UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0
                    self.animatePresentContainer()
                }
            }
        }
    // Adds some physics like attributes to the animation as to give it a nice smooth look
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
                if self.revealSideMenuOnTop {
                    self.sideMenuTConstraint.constant = targetPosition
                    self.view.layoutIfNeeded()
                }
                else {
                    self.view.subviews[1].frame.origin.x = targetPosition
                }
            }, completion: completion)
        }
    // The function called by the settings button
    @IBAction func settingsButtonPressed(_ sender: Any) {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    func generateMapCollectionView() {
        // Setup the mapCollectionView which will contain the map characters
        // TODO: Switch these to contained images as opposed to characters
        collectionViewMaps.delegate = self
        collectionViewMaps.dataSource = self
        collectionViewMaps.register(UINib(nibName: "MapScrollCell", bundle: nil), forCellWithReuseIdentifier: Constants.mapScrollCell)
    }
    
    // MARK: - DirectionViewController
    /*
     The view that contains the timer, direction to go, and the ETA of the user in the navigation screen
     */
    lazy var containerViewDV: UIView = {
            let view = UIView()
        // View colors and bounds
        view.backgroundColor = UIColor(red: 0xF3 / 0xFF, green: 0xF3 / 0xFF, blue: 0xF5 / 0xFF, alpha: 1)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // View shadow attributes
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.0
        
        
        return view
    }()
    
    // The label indicating the direction
    lazy var directionLabel: UILabel = {
        let label = UILabel()
//        Dummy text for now, will obtain information from algorithm
        label.text = "Go Straight"
        let font = UIFont(name: "OpenSans-Regular", size: 30.0)
        label.font = font
        label.textAlignment = .center
        return label
    }() 
    
    // Image that shows the directionalArrow
    lazy var arrowImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "up")
        return image
    }()
    
    // This is the image that shows the walking person
    lazy var travelPicture: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "walk")
        return image
    }()
    
    // Timestamp under the walking person
    // Will eventaully grab the time from the navigation algorithm
    lazy var timestamp: UILabel = {
        let label = UILabel()
        label.text = "12 min"
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Regular", size: 16.0)
        return label
    }()
    
    // A container that contains the arrowImage, directionLabel, and the timeStampStack Stack View
    // Allows for easier alignment, equal spacing, and organization
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [arrowImage, directionLabel, timeStampStack])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // A sub stackView to the contentStackView that contains just the walking person image and the timestamp
    lazy var timeStampStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [travelPicture, timestamp])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // Constants and variables related to how far the bottom view will rise from the bottom
    var containerViewHeightConstraintDV: NSLayoutConstraint?
    var containerViewBottomConstraintDV: NSLayoutConstraint?
    let defaultHeightDV: CGFloat = 124
    
    /*
     Function that sets all of the constraints for the UI elements in this screen
     Same as all of the other screens
     */
    func setupConstraints() {
            
            // Adding subviews
            view.addSubview(containerViewDV)
            // Could put a guard let here to prevent app from moving forward if map can't be found
            // Will do later perhaps
        view.insertSubview(collectionViewMap ?? UICollectionView(), belowSubview: sideMenuShadowView)
            containerViewDV.addSubview(contentStackView)
        
            containerViewDV.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStampStack.translatesAutoresizingMaskIntoConstraints = false
            
            /*
             Setting the constraints for the elements within the containerViewDV
             */
            NSLayoutConstraint.activate([
                // Map from Navigation constraints
                // Matches previous screen
                collectionViewMap!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 75),
                collectionViewMap!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -75),
                collectionViewMap!.topAnchor.constraint(equalTo: view.topAnchor, constant: 84),
                collectionViewMap!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -399),
                // containerViewDV leading and trailing
                containerViewDV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerViewDV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                // arrowImage height and width
                arrowImage.heightAnchor.constraint(equalToConstant: 68),
                arrowImage.widthAnchor.constraint(equalToConstant: 68),
                
                // directionLabel height and width
                directionLabel.heightAnchor.constraint(equalToConstant: 37),
                directionLabel.widthAnchor.constraint(equalToConstant: 199),
                
                // timeStampStack height and width
                timeStampStack.heightAnchor.constraint(equalToConstant: 81),
                timeStampStack.widthAnchor.constraint(equalToConstant: 61),
                
                // contentStackView all anchors
                contentStackView.topAnchor.constraint(equalTo: containerViewDV.topAnchor, constant: 0),
                contentStackView.leadingAnchor.constraint(equalTo: containerViewDV.leadingAnchor, constant: 25),
                contentStackView.trailingAnchor.constraint(equalTo: containerViewDV.trailingAnchor, constant: -34),
                contentStackView.bottomAnchor.constraint(equalTo: containerViewDV.bottomAnchor, constant: 0),
                ])
            
            // Set container to default height
            containerViewHeightConstraintDV = containerViewDV.heightAnchor.constraint(equalToConstant: defaultHeightDV)
        
            // Set bottom constant to 0
            containerViewBottomConstraintDV = containerViewDV.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeightDV)
        
            // Activate constraints
            containerViewHeightConstraintDV?.isActive = true
            containerViewBottomConstraintDV?.isActive = true
    }
    // Animates the bottom constraint to simulate the view rising
    func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraintDV?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    // Animates the bottom constraint to simulate the view dropping
    func animateDismissView() {
        // hide main container view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraintDV?.constant = self.defaultHeightDV
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    // Simulate a user walking through the garage
    func beginNavigation() {
        // Rewrite the collectionView to simulate movement
        self.delegate?.reloadAllMapCollectionViewCells(on: Int(self.userLocation!.z), with: self.collectionViewMap!)
        
        // Add the ability to change where the user goes by changing the collectionView using the navigated coordinates (simulation)
        // Assumes 'S' starts on a period
        // Rewrites itself when user presses back and comes back to this screen
        //Have some sort of database to remember where the user is, but for now, this demonstrates the idea
        updateLabel()
        updateArrow()
        animatePresentContainer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        
    }
    func setUpFloors() {
        floorTraverse = []
        var zfloor: [Coord] = []
            if let outputList = navOutput as? [Coord] {
                var temp = outputList[0].z
                for dest in outputList {
                    if temp != dest.z {
                        floorTraverse!.append(zfloor)
                        zfloor = []
                        temp = dest.z
                    } else {
                        zfloor.append(dest)
                    }
                    
                }
            }
            floorTraverse!.append(zfloor)
        tempIndex = floorTraverse![startingFloor].count - 2
    }
   @objc func timerFire() {
       
        // Switch with the S and previous character S sat on
       updateMapWhileTraversing()
       
       
        self.userLocation!.x = floorTraverse![startingFloor][tempIndex].x
        self.userLocation!.y = floorTraverse![startingFloor][tempIndex].y
       
        
        tempIndex -= 1
       if (tempIndex >= 0) {
           updateLabel()
           updateArrow()
       } else {
            startingFloor += 1
            if (startingFloor >= floorTraverse!.count) {
                timer!.invalidate()
            } else {
                tempIndex = floorTraverse![startingFloor].count - 1
                self.userLocation!.z = floorTraverse![startingFloor][tempIndex].z
                
                self.delegate?.reloadAllMapCollectionViewCells(on: Int(self.userLocation!.z), with: self.collectionViewMap!)
                updateLabel()
                updateArrow()
                updateMapWhileTraversing()
            }
        }
        
    }
    
    func updateLabel() {
        // Determine direction of movement and make the bottom view update accordingly
        // Had forgotten that navigation Tile had contained this information upon making this simulation, should be replaced with that information at some point
        if let label = contentStackView.arrangedSubviews[1] as? UILabel {
            if (userLocation!.x < floorTraverse![startingFloor][tempIndex].x) {
                label.text = "Go Right"
            } else if (userLocation!.x > floorTraverse![startingFloor][tempIndex].x) {
                label.text = "Go Left"
            }
            
            if (userLocation!.y < floorTraverse![startingFloor][tempIndex].y) {
                label.text = "Go Back"
            } else if (userLocation!.y > floorTraverse![startingFloor][tempIndex].y) {
                label.text = "Go Straight"
            }
        }
    }
    func updateArrow() {
        if let arrow = contentStackView.arrangedSubviews[0] as? UIImageView {
            if (userLocation!.x < floorTraverse![startingFloor][tempIndex].x) {
                arrow.image = UIImage(named: "right")
            } else if (userLocation!.x > floorTraverse![startingFloor][tempIndex].x) {
                arrow.image = UIImage(named: "left")
            }
            
            if (userLocation!.y < floorTraverse![startingFloor][tempIndex].y) {
                arrow.image = UIImage(named: "down")
            } else if (userLocation!.y > floorTraverse![startingFloor][tempIndex].y) {
                arrow.image = UIImage(named: "up")
            }
        }
    }
    
    func updateMapWhileTraversing() {
        if let cellMap = self.collectionViewMap?.cellForItem(at: [0, Int((self.widthOfMap! * (floorTraverse![startingFloor][tempIndex].y)) + floorTraverse![startingFloor][tempIndex].x)]) as? MapCell,
            let userCell = self.collectionViewMap?.cellForItem(at: [0, Int((self.widthOfMap! * (self.userLocation!.y)) + self.userLocation!.x)]) as? MapCell {
            
            userCell.floorLabelPiece.image = futureChar
            futureChar = cellMap.floorLabelPiece.image
            
            delegate?.imageTranslation(on: cellMap, String(UnicodeScalar(UInt8(Constants.cCharS))))
         }
    }
}

/*
 Delegate methods for the gesture recognizer
 These are called when the sidemenu gets built and allows it to respond to the settings button press
 */
extension View2Controller: UIGestureRecognizerDelegate {
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }

    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenu.view))! {
            return false
        }
        return true
    }
}



