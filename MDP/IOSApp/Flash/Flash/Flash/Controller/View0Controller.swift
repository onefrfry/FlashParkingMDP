//
//  ViewController.swift
//  Flash
//
//  Created by Sam Bohnett on 3/28/22.
//

import UIKit
import CoreLocation

/*
 Opening screen of the app with the "Mark My Car" button, image, and the prompt of requesting users to enable location services
 */
class View0Controller: UIViewController {

    @IBOutlet weak var markMyCarButton: UIButton!
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var locationOn: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // markMyCarButton attributes
        markMyCarButton.layer.cornerRadius = markMyCarButton.frame.height / 2
        
        markMyCarButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        markMyCarButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        markMyCarButton.layer.shadowOpacity = 1.0
        markMyCarButton.layer.shadowRadius = 0.0
        
        // LocationManager setting and delegate setting
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }
    /*
     Checks to see if the user actually has location on or not
        If yes: it will perform the screen transition to the next screen over where localization will begin
        If no: A pop up asking about location services being enabled will appear and will direct users to the settings where the user can enable it
     */
    @IBAction func markingCar(_ sender: Any) {
        if (locationOn) {
            // TODO: Call localization here!
            // This is the first button in the app that lets a user mark their car
            performSegue(withIdentifier: Constants.localized, sender: self)
        } else {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Enable Location Services on this device: Settings > Privacy > Location Services", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {_ in
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.open(url as URL)
                    }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     Screen transition while assigning the variables of beaconRegion and locationManager
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! View1Controller
        vc.beaconRegion = beaconRegion
        vc.locationManager = locationManager
        locationManager.delegate = vc
        // Use the rest of this function for any preparations for the next view controller to be loaded in
        // For example: setting the users position correctly within the map
        
    }
}

extension View0Controller: CLLocationManagerDelegate {
    /*
     This function checks for the state of the location services of the user
     Will determine if the action item needs to be re-shown
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            locationOn = true
            switch locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    locationManager.requestWhenInUseAuthorization()
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    break
                default:
                    break
            }
        } else {
            locationOn = false
        }
    }
}

