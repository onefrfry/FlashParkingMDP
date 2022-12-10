//
//  CustomActivityIndicator.swift
//  Flash
//
//  Created by Sam Bohnett on 4/27/22.
//

import UIKit

/*
 This is the view that contains the loading spinner icon when try again is pressed
 
 At this point, the localization algorithm would run again to try and find the user if it fails. While it runs, this spinner shows up
 */
class CustomActivityIndicator: UIView {
    
    private convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    private var spinnerBehavior: UIDynamicItemBehavior?
    private var animator: UIDynamicAnimator?
    private var imageView: UIImageView?
    private var loaderImageName = ""
        
    /*
     I kept the weird name for the image after downloading it off of figma, was too lazy to change it
     */
    func show(with image: String = "Property 1=Default") {
        loaderImageName = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            if self?.imageView == nil {
                self?.setupView()
                DispatchQueue.main.async {[weak self] in
                    self?.showLoadingActivity()
                }
            }
        }
    }
    
    func hide() {
        DispatchQueue.main.async {[weak self] in
            self?.stopAnimation()
        }
    }
    
    private func setupView() {
        center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        
        let theImage = UIImage(named: loaderImageName)
        imageView = UIImageView(image: theImage)
        imageView?.frame = CGRect(x: self.center.x - 100, y: self.center.y - 200, width: 200, height: 200)
        
        if let imageView = imageView {
            self.spinnerBehavior = UIDynamicItemBehavior(items: [imageView])
        }
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    private func showLoadingActivity() {
        if let imageView = imageView {
            addSubview(imageView)
            startAnimation()
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.addSubview(self)
            self.isUserInteractionEnabled = false
        }
    }
    
    private func startAnimation() {
        guard let imageView = imageView,
              let spinnerBehavior = spinnerBehavior,
              let animator = animator else { return }
        if !animator.behaviors.contains(spinnerBehavior) {
            spinnerBehavior.addAngularVelocity(5.0, for: imageView)
            animator.addBehavior(spinnerBehavior)
        }
    }
    
    private func stopAnimation() {
        animator?.removeAllBehaviors()
        imageView?.removeFromSuperview()
        imageView = nil
        self.removeFromSuperview()
        self.isUserInteractionEnabled = true
    }
}
