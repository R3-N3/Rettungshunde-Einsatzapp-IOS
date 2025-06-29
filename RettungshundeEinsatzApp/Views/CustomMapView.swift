//
//  CustomMapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    @Binding var mapType: MKMapType

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = true

        // ➔ Setze initialen mapType
        mapView.mapType = mapType

        // Anfangsregion
        if let first = coordinates.first {
            let region = MKCoordinateRegion(
                center: first,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }

        // Polyline hinzufügen
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ➔ Aktualisiere mapType bei jedem Update
        uiView.mapType = mapType

        // Overlays aktualisieren
        uiView.removeOverlays(uiView.overlays)
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        uiView.addOverlay(polyline)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // ➔ Farbe aus UserDefaults laden
                let hexString = UserDefaults.standard.string(forKey: "trackColor") ?? "#FF0000"
                renderer.strokeColor = UIColor(hex: hexString) ?? UIColor.systemRed
                renderer.lineWidth = 3

                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
