//
//  SingleMapViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/03/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import GoogleMaps


class SingleMapViewController: UIViewController, CLLocationManagerDelegate {

    var singlePlace: Place?
    let zoomLevel: Float = 15.0
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    
    override func loadView() {
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        
        if let place = singlePlace  {
            
            if let location = place.location {
                
                let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: zoomLevel)
                mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
                /* Map settings */
                
                mapView.settings.compassButton = true
                mapView.settings.myLocationButton = true
                mapView.isMyLocationEnabled = true
                mapView.settings.zoomGestures = true
                
                if let mylocation = mapView.myLocation {
                    print("User's location: \(mylocation)")
                } else {
                    print("User's location is unknown")
                }
                view = mapView
                
                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                marker.title = place.name
                marker.snippet = location.address
                marker.map = mapView
                
            }
            
        }
        
        setCurrentLocation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setCurrentLocation() {
    
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
    }
    
    // MARK - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
