//
//  FirstViewController.swift
//  The Spot
//
//  Created by Giorgia Marenda on 9/18/17.
//  Copyright © 2017 Giorgia Marenda. All rights reserved.
//
// https://icons8.com/icon/5682/Marker

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacesPicker

class SpotsMapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    lazy var placesClient = { GMSPlacesClient.shared() } ()
    var mapView: GMSMapView?
    var places: [GMSPlaceLikelihood]? {
        didSet {
            reloadMarkers()
        }
    }
    var selectedMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        if places == nil {
            loadSpots()
        }
        loadMap()
    }

    func loadMap() {
        guard let location = locationManager.location else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 18.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        view = mapView
    }
    
    func loadSpots() {
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                self.places = placeLikelihoodList.likelihoods
            }
        })
    }
    
    func loadSpot(with spotId: String) {
        placesClient.lookUpPlaceID(spotId) { (place, error) in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let place = place, self.places?.filter({ $0.place == place }).count == 0 {
                self.mapView?.selectedMarker = self.createMarker(place: place)
            }
            self.showDetailScreen(for: place)
        }
    }
    
    func reloadMarkers() {
        guard let places = places else { return }
        for likelihood in places {
            let place = likelihood.place
            // Creates a marker in the center of the map.
            createMarker(place: place)
        }
    }
    
    @discardableResult
    func createMarker(place: GMSPlace) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = place.coordinate
        marker.title = place.name
        marker.icon = #imageLiteral(resourceName: "marker")
        marker.snippet = "Tap to see details"
        marker.map = self.mapView
        return marker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDetailScreen(for spot: GMSPlace?) {
        let detail = DetailViewController()
        detail.spot = spot
        present(detail, animated: true, completion: nil)
    }
}

extension SpotsMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let placeLikelihood = places?.filter({
            $0.place.coordinate.latitude == marker.position.latitude &&
                $0.place.coordinate.longitude == marker.position.longitude &&
                $0.place.name == marker.title}).first
        showDetailScreen(for: placeLikelihood?.place)
    }
}

extension SpotsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            loadMap()
        default:
            manager.requestWhenInUseAuthorization()
        }
    }
}

