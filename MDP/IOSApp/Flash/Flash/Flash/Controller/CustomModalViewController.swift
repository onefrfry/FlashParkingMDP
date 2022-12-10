//
//  CustomModalViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 3/29/22.
//

import UIKit

/*
 The class that the view containing the "Try Again" and "Confirm" buttons is built from
 */
class CustomModalViewController: UIViewController {
    // This delegate allows this view to run functions in View1Controller
    var delegate: SetupDelegate?
    
    // Runs when the view completely loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the view and the constraints
        setupView()
        setupConstraints()
        
        // Register the source of data and the types of cells that the table view can contain
        // TODO: Get rid of this tableView, just change it to statically placed buttons and labels that can't be scrolled
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.nibName, bundle: nil), forCellReuseIdentifier: Constants.newCell)
        tableView.backgroundColor = UIColor(red: 0xF3 / 0xFF, green: 0xF3 / 0xFF, blue: 0xF5 / 0xFF, alpha: 1)
        tableView.rowHeight = 83
        
        // Adds "observers" or trigger events that wait for a keyboard to show up or vanish
        // Runs the #selector functions when these events happen
        NotificationCenter.default.addObserver(self, selector: #selector(CustomModalViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomModalViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                  
        //Looks for single or multiple taps.
         let tap = UITapGestureRecognizer(target: self, action: #selector(CustomModalViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Function that runs as soon as the view can be seen by the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    // Function that runs when the keyboard is coming
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    // Function that hides the keyboard
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    // Hardcoded messages that match the design
    let messages : [Message] = [
        Message(title: "Current Parking Area"),
        Message(title: "Current Parking Lot Number")
    ]
    
    // containerView that contains the buttons and the tableView
    lazy var containerView: UIView = {
            let view = UIView()
        view.backgroundColor = UIColor(red: 0xF3 / 0xFF, green: 0xF3 / 0xFF, blue: 0xF5 / 0xFF, alpha: 1)
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.0
        return view
    }()
    
    // tableView that allows for scrolling and multiple elements in a list
    // TODO: Replace this with just labels and buttons
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .lightGray
        return table;
    }()
    
    // This is the confirm button
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 0xDA/0xFF, green: 0xDA/0xFF, blue: 0xDA/0xFF, alpha: 1)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        return button
    }()
    
    // This is the try again button
    lazy var tryAgainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 0xDA/0xFF, green: 0xDA/0xFF, blue: 0xDA/0xFF, alpha: 1)
        button.setTitle("Try Again", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tryAgainButtonAction), for: .touchUpInside)
        
        return button
    }()

    // Stack view that contains the two buttons, giving them the ability to be nicely spaced
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tryAgainButton, confirmButton])
        stackView.axis = .horizontal
        stackView.spacing = 20.0
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // The stack view that contains the contentStackView and the tableView to make them spaced nicely
    lazy var fullStack: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [tableView, contentStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0
        return stackView
    }()
    
    // Constants that will dictate how high this screen rises
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    let defaultHeight: CGFloat = 300

    
    func setupView() {
        view.backgroundColor = .clear
    }
    func setupConstraints() {
            // Add subviews
        
            view.addSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(fullStack)
            fullStack.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            
            
            // Set static constraints
            NSLayoutConstraint.activate([
                // containerView leading and trailing
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                // fullStack all anchors
                fullStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                fullStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
                fullStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
                fullStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
                
                // contentStackView all anchors
                contentStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
                contentStackView.bottomAnchor.constraint(equalTo: fullStack.bottomAnchor, constant: -10),
                contentStackView.leadingAnchor.constraint(equalTo: fullStack.leadingAnchor, constant: 0),
                contentStackView.trailingAnchor.constraint(equalTo: fullStack.trailingAnchor, constant: 0),
                
                // confirm and try again buttons bottom anchors
                confirmButton.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: -30),
                tryAgainButton.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: -30),

    ])
            
            // Set container to default height
            containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
            // Set bottom constant to 0
            containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
            // Activate constraints
            containerViewHeightConstraint?.isActive = true
            containerViewBottomConstraint?.isActive = true
    }
    // Make the view animate from the bottom to display to the screen
    func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    // Make the view animate downward to make it disappear
    func animateDismissView() {
        // hide main container view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    // The try again button functionality
    // Will eventually make a call back to localization, but just makes the spinner view show itself and disappear
    @objc func tryAgainButtonAction(sender: UIButton!) {
        // TODO: Call Localization Here!
        // Instead of running the testMain function and blur for a set amount of seconds, actually recall the localization algorithms and update map accordingly
        // This would call the localization function again and take time to do so
        // For now, we will just have the blur and load take 2 seconds
        let seconds = 2.0
        self.delegate?.toggleBlur(true)
        self.delegate?.runTestMain()
        tryAgainButton.isUserInteractionEnabled = false
        confirmButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.delegate?.toggleBlur(false)
            self.tryAgainButton.isUserInteractionEnabled = true
            self.confirmButton.isUserInteractionEnabled = true
        }
    }
    
    // Function for the confirm button to run upon being clicked
    // Sets the text on the screen behind it and removes the main view
    @objc func confirmButtonAction(sender: UIButton!) {
        var inputStrings: [String] = []
        for cell in tableView.visibleCells {
            let actualCell = cell as! ParkingCell
            inputStrings.append(actualCell.textFieldResult.text ?? "0")
        }
        delegate?.changeLabels(for: inputStrings)
        delegate?.removeView()
        animateDismissView()
    }
}

/*
 Table view delegate methods that run upon its creation
 TODO: Will get rid of these since I believe the tableView as a whole isn't needed and can be replaced
 */
extension CustomModalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newCell, for: indexPath) as! ParkingCell
        cell.titleLabel.text = messages[indexPath.row].title
        // cell.returnLabel().text = "Parking Info"
        NSLayoutConstraint.activate([
            cell.leadingAnchor.constraint(equalTo: cell.returnView().leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: cell.returnView().trailingAnchor),
        ])
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
}
