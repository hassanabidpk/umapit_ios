//
//  NewMapViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 22/03/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import RealmSwift

let BUSAN_LAT = 35.1926417
let BUSAN_LNG = 129.0400314

#if DEBUG
    let currentLoc = false
    let LOCATION_API_URL = "http://localhost:8000/place/api/v1/location/new/"
#else
    let currentLoc = true
    let LOCATION_API_URL = "https://umapit.azurewebsites.net/place/api/v1/location/new/"
#endif


class NewMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    let zoomLevel: Float = 13.0
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    let geocoder = GMSGeocoder()
    var marker: GMSMarker!
    var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    

    func setUI() {
        
        self.tabBarController?.tabBar.isHidden = true
    
        let camera = GMSCameraPosition.camera(withLatitude: BUSAN_LAT, longitude: BUSAN_LNG, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.delegate = self
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
        
        if(currentLoc) {
            setCurrentLocation()
        }
        
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        nextButton.setTitle("NEXT!", for: .normal)
        nextButton.addTarget(self,
                             action: #selector(NewMapViewController.didPressNextButton(_:)),
                             for: .touchUpInside)
        
        
        nextButton.isHidden = true
        self.view.addSubview(nextButton)
        
    }
    
    override func viewWillLayoutSubviews() {
        
        print("width \(self.view.frame.width) : height \(self.view.frame.height)")
        nextButton.frame = CGRect(x: (self.view.frame.width/2 - 60), y: (self.view.frame.height - 80), width: 120, height: 50)
    }
    
    
    // MARK: - GMSMapViewDelegate methods
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
        nextButton.isHidden = false

        mapView.clear()
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.marker.map = mapView
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                print("didTAP : result : \(result)")
                self.marker.title = result.lines?[0]
                self.marker.snippet = result.lines?[1]
            }
            
        }
            
    }

    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        
        /* geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
            guard error == nil else {
                return
            }
 
        */
            
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
        
        
         let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
         longitude: location.coordinate.longitude,
         zoom: zoomLevel)
         
         if mapView.isHidden {
         mapView.isHidden = false
         mapView.camera = camera
         } else {
         mapView.animate(to: camera)
         }
        
        
        
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
    

    // MARK - Actions 
    
     func didPressNextButton(_ button: UIButton) {
        
        print("didPressNextButton")
        
        let userDefaults = UserDefaults.standard
        
        let strToken = userDefaults.value(forKey: "userToken")
        let authToken = "Token \(strToken!)"
        
        let headers = [
            "Authorization": authToken
        ]
        
        print("marker.lat : \(marker.position.latitude) marker.lng : \(marker.position.longitude)")
        let parameters: Parameters = ["title": marker.title!,
                                      "address": "\(marker.title!) \(marker.snippet!)",
                                      "latitude" : Double(round(1000000*marker.position.latitude)/1000000),
                                      "longitude" : Double(round(1000000*marker.position.longitude)/1000000)]
        
        Alamofire.request(LOCATION_API_URL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON { response in
                
                debugPrint(response)
                
                if let locationStatus = response.result.value {
                    
                    let json = JSON(locationStatus)
                    print("new location JSON: \(json)")
                    
                    
                    print("writing new location to REALM db")
                    let realm = try! Realm()
                    realm.beginWrite()
                    
                    let new_location = realm.create(Location.self, value: ["address": json["address"].stringValue,
                                                                     "latitude": json["latitude"].doubleValue,
                                                                     "longitude": json["longitude"].doubleValue,
                                                                     "id": json["id"].intValue])
                    
                    
                    
                    try! realm.commitWrite()
                    
                    self.startNewPlaceVC(location: new_location)
                    
                } else {
                    
                    print("error posting new location")
                    
                }
        }
        
        
        
    }
    
    // MARK - Helpers
    
    func startNewPlaceVC(location: Location) {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let placeViewController = storyboard.instantiateViewController(withIdentifier: "newplacevc") as! NewPlaceViewController
        
        placeViewController.location = location
        
        placeViewController.navigationItem.leftItemsSupplementBackButton = true
        placeViewController.title = "uMAPit"
        
        self.navigationController?.navigationBar.tintColor = Constants.tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Constants.tintColor]
        
        self.navigationController?.pushViewController(placeViewController, animated: true)
        
    
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
