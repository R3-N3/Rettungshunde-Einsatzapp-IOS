//
//  CustomMapView.swift
//  RettungshundeEinsatzApp
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct UserTrack {
    var user: AllUserData?
    var coordinates: [CLLocationCoordinate2D]
    var color: UIColor
    var iconColor: UIColor?
}

class UserAnnotation: MKPointAnnotation {
    var user: AllUserData?
    var color: UIColor?
}

struct CustomMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let userTracks: [UserTrack]
    @Binding var mapType: MKMapType
    @Binding var refreshUserTracks: Bool
    @Binding var selectedUser: AllUserData?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = true
        mapView.mapType = mapType

        if let first = coordinates.first ?? userTracks.first?.coordinates.first {
            let region = MKCoordinateRegion(
                center: first,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }

        addOverlaysAndAnnotations(to: mapView, context: context)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("🟢 Starte UpdateUI in CustomMapView")
        uiView.mapType = mapType

        // ➡️ Entferne vorhandene eigene Polyline
        if let existing = context.coordinator.myPolyline {
            uiView.removeOverlay(existing)
        }

        // ➡️ Füge neue eigene Polyline hinzu
        if !coordinates.isEmpty {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let hexString = UserDefaults.standard.string(forKey: "trackColor")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "#FF0000"
            let myColor = UIColor(hex: hexString) ?? UIColor.systemRed

            context.coordinator.overlayColors[polyline] = myColor
            uiView.addOverlay(polyline)

            // ➡️ Speichere Referenz
            context.coordinator.myPolyline = polyline
        }

        // ➡️ Aktualisiere fremde UserTracks nur wenn refreshUserTracks == true
        if refreshUserTracks {
            print("refreshUserTracks == true")
            // Entferne alle fremden Overlays (außer eigene Polyline)
            for overlay in uiView.overlays {
                if let polyline = overlay as? MKPolyline {
                    if polyline != context.coordinator.myPolyline {
                        uiView.removeOverlay(polyline)
                    }
                }
            }

            // Entferne alle UserAnnotations
            let userAnnotations = uiView.annotations.filter { $0 is UserAnnotation }
            uiView.removeAnnotations(userAnnotations)

            // ➡️ Füge fremde Tracks neu hinzu
            for track in userTracks {
                let polyline = MKPolyline(coordinates: track.coordinates, count: track.coordinates.count)
                context.coordinator.overlayColors[polyline] = track.color
                uiView.addOverlay(polyline)

                if let user = track.user, let lastCoord = track.coordinates.last {
                    let annotation = UserAnnotation()
                    annotation.coordinate = lastCoord
                    annotation.title = user.username ?? "User"
                    annotation.user = user
                    annotation.color = track.iconColor
                    uiView.addAnnotation(annotation)
                }
            }
            DispatchQueue.main.async {
                self.refreshUserTracks = false
            }
        }
    }

    private func addOverlaysAndAnnotations(to mapView: MKMapView, context: Context) {
        if !coordinates.isEmpty {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let hexString = UserDefaults.standard.string(forKey: "trackColor")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "#FF0000"
            let myColor = UIColor(hex: hexString) ?? UIColor.systemRed

            context.coordinator.overlayColors[polyline] = myColor
            mapView.addOverlay(polyline)
            context.coordinator.myPolyline = polyline
        }

        for track in userTracks {
            let polyline = MKPolyline(coordinates: track.coordinates, count: track.coordinates.count)
            context.coordinator.overlayColors[polyline] = track.color
            mapView.addOverlay(polyline)

            if let user = track.user, let lastCoord = track.coordinates.last {
                let annotation = UserAnnotation()
                annotation.coordinate = lastCoord
                annotation.title = user.username ?? "User"
                annotation.user = user
                annotation.color = track.iconColor
                mapView.addAnnotation(annotation)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var overlayColors: [MKPolyline: UIColor] = [:]

        // ➡️ NEU: Eigene Polyline Referenz
        var myPolyline: MKPolyline?

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = overlayColors[polyline] ?? UIColor.systemYellow
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "UserAnnotationView"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = true

                if let userAnnotation = annotation as? UserAnnotation {
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                }

                let btn = UIButton(type: .detailDisclosure)
                view?.rightCalloutAccessoryView = btn
            } else {
                view?.annotation = annotation

                if let userAnnotation = annotation as? UserAnnotation {
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                }
            }

            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let userAnnotation = view.annotation as? UserAnnotation, let user = userAnnotation.user {
                print("👉 User tapped: \(user.username ?? "nil")")
                parent.selectedUser = user
            }
        }
    }
}
