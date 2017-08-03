//
//  MapViewController.swift
//  Geofencing_Test
//
//  Created by Ryan Harri on 2017-07-18.
//  Copyright © 2017 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Instance Properties
    
    var annotation: GFPointAnnotation?
    let locationManager = CLLocationManager()
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let annotation = annotation, let circle = annotation.circle {
            mapView.add(circle)
            startMonitoring(annotation: annotation)
        } else {
            if let annotation = annotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            annotation = GFPointAnnotation()
            annotation!.coordinate = coordinate
            mapView.addAnnotation(annotation!)
            
            let dispatchTime = DispatchTime.now() + 1
            
            // Delay the display of the add location view
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                if let addLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "Add") as? AddLocationViewController {
                    addLocationVC.annotation = self.annotation
                    self.present(addLocationVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: Instance Methods
    
    func region(withAnnotation annotation: GFPointAnnotation) -> CLCircularRegion {
        let region = CLCircularRegion(
            center: annotation.coordinate,
            radius: annotation.circle!.radius,
            identifier: annotation.identifier!) // "GeofencingTest"
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    func startMonitoring(annotation: GFPointAnnotation) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let alert = UIAlertController(title: "Sorry", message: "Geofencing is not supported on this device", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        // TODO: Ensure we have user permission!
        
        let region = self.region(withAnnotation: annotation)
        
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(annotation: GFPointAnnotation) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == annotation.identifier! else {
                    continue
            }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView =
            mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView =
                MKPinAnnotationView(
                    annotation: annotation, reuseIdentifier: "Pin")
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purple
            circle.fillColor =
                UIColor(hue: 290/360.0, saturation: 28/360.0, brightness: 89/360.0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? GFPointAnnotation,
            let circle = annotation.circle {
            mapView.removeAnnotation(view.annotation!)
            mapView.remove(circle)
            stopMonitoring(annotation: annotation)
        }
    }
}

// MARK: CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            if UIApplication.shared.applicationState == .active {
                let alert = UIAlertController(
                    title: "Hello", message: "You crossed a geofence!", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(ok)
                
                present(alert, animated: true, completion: nil)
            } else {
                
                // TODO: Replace with UserNotifications framework
                
                let notification = UILocalNotification()
                notification.alertBody = "You crossed a geofence!"
                notification.soundName = "Default"
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }
}

