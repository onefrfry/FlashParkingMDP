//
//  DirectionViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 5/14/22.
//

import UIKit

/*
 Added to View2Controller as to avoid more needless delegation and it was just easier to work with
 TODO: Delete this at some point, not that urgent right now
 */
class DirectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        animatePresentContainer()
        
    }
    
    lazy var containerViewDV: UIView = {
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
    
    lazy var directionLabel: UILabel = {
        let label = UILabel()
//        Dummy text for now, will obtain information from algorithm
        label.text = "Go Straight"
        let font = UIFont(name: "OpenSans-Regular", size: 30.0)
        label.font = font
        label.textAlignment = .center
        return label
    }()
    
    lazy var arrowImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "straightArrow")
        return image
    }()
    
    lazy var travelPicture: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "walk")
        return image
    }()
//    Will fix later, might not be a label, the time is also off
    lazy var timestamp: UILabel = {
        let label = UILabel()
        label.text = "12 min"
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans-Regular", size: 16.0)
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [arrowImage, directionLabel, timeStampStack])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var timeStampStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [travelPicture, timestamp])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    var containerViewHeightConstraintDV: NSLayoutConstraint?
    var containerViewBottomConstraintDV: NSLayoutConstraint?
    let defaultHeightDV: CGFloat = 124
    
    func setupView() {
        view.backgroundColor = .clear
        
    }
    func setupConstraints() {
            // 4. Add subviews
        
            view.addSubview(containerViewDV)
            containerViewDV.translatesAutoresizingMaskIntoConstraints = false
            containerViewDV.addSubview(contentStackView)
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStampStack.translatesAutoresizingMaskIntoConstraints = false
            
            
            // 5. Set static constraints
            NSLayoutConstraint.activate([
                // set dimmedView edges to superview
                // set container static constraint (trailing & leading)
                
                containerViewDV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerViewDV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                arrowImage.heightAnchor.constraint(equalToConstant: 68),
                arrowImage.widthAnchor.constraint(equalToConstant: 68),
                directionLabel.heightAnchor.constraint(equalToConstant: 37),
                directionLabel.widthAnchor.constraint(equalToConstant: 199),
//                timestamp.heightAnchor.constraint(equalToConstant: 21),
//                timestamp.widthAnchor.constraint(equalToConstant: 61),
                timeStampStack.heightAnchor.constraint(equalToConstant: 81),
                timeStampStack.widthAnchor.constraint(equalToConstant: 61),
                contentStackView.topAnchor.constraint(equalTo: containerViewDV.topAnchor, constant: 0),
                contentStackView.leadingAnchor.constraint(equalTo: containerViewDV.leadingAnchor, constant: 25),
                contentStackView.trailingAnchor.constraint(equalTo: containerViewDV.trailingAnchor, constant: -34),
                contentStackView.bottomAnchor.constraint(equalTo: containerViewDV.bottomAnchor, constant: 0),
                ])
            
            // 6. Set container to default height
            containerViewHeightConstraintDV = containerViewDV.heightAnchor.constraint(equalToConstant: defaultHeightDV)
            // 7. Set bottom constant to 0
            containerViewBottomConstraintDV = containerViewDV.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeightDV)
            // Activate constraints
            containerViewHeightConstraintDV?.isActive = true
            containerViewBottomConstraintDV?.isActive = true
    }
    func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraintDV?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
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
}
