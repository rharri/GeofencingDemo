//
//  AddLocationViewController.swift
//  Geofencing_Test
//
//  Created by Ryan Harri on 2017-07-18.
//  Copyright © 2017 Ryan Harri. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK: Instance Properties
    
    var annotation: GFPointAnnotation?
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(
                latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(
                center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
        
        radiusTextField.delegate = self
        messageTextField.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        guard let radius = radiusTextField.text else {
            return
        }
        
        guard let message = messageTextField.text else {
            return
        }
        
        if let notification = Notification(radius: radius, message: message) {
            if annotation != nil {
                annotation!.title = notification.message
                annotation!.subtitle = "Radius: \(notification.radius)m"
                
                let circle = MKCircle(
                    center: annotation!.coordinate,
                    radius: CLLocationDistance(notification.radius))
                
                annotation!.circle = circle
                annotation!.identifier = notification.id.uuidString
            }
                        
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: MKMapViewDelegate

extension AddLocationViewController: MKMapViewDelegate {
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
            
            return annotationView
        }
    }
}

// MARK: UITextfieldDelegate

extension AddLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == radiusTextField {
            messageTextField.becomeFirstResponder() // Next
        } else {
            textField.resignFirstResponder() // Done
        }
        
        return true
    }
}
