//
//  CustomMapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = true
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.7339, longitude: 7.0997),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
    }
}
