//
//  CustomMapView.swift
//  RettungshundeEinsatzApp
//



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
    @Binding var selectedArea: Areas?
    var areas: FetchedResults<Areas>
    @Binding var refreshAreas: Bool

    
    private func addAreaOverlaysAndAnnotations(to mapView: MKMapView) {
        // Entferne alte Area Overlays + Annotations
        let areaOverlays = mapView.overlays.filter { $0 is ColoredPolygon }
        mapView.removeOverlays(areaOverlays)
        let areaAnnotations = mapView.annotations.filter { $0 is AreaAnnotation }
        mapView.removeAnnotations(areaAnnotations)

        // Füge neue Areas hinzu
        for area in areas {
            if let polygon = createPolygonOverlay(area: area) {
                mapView.addOverlay(polygon)
                let annotation = AreaAnnotation()
                annotation.coordinate = polygon.centerCoordinate
                annotation.title = area.name
                annotation.color = UIColor(hex: area.color ?? "#FF0000")
                annotation.area = area
                mapView.addAnnotation(annotation)
            }
        }
    }


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
        
        addAreaOverlaysAndAnnotations(to: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("🟢 Starte UpdateUI in CustomMapView")
        uiView.mapType = mapType

        // ➡️ Entferne vorhandene eigene Polyline
        if let existing = context.coordinator.myPolyline {
            uiView.removeOverlay(existing)
        }
        
        addAreaOverlaysAndAnnotations(to: uiView)
        DispatchQueue.main.async {
            self.refreshAreas = false
        }
        
        if refreshAreas {
            // Entferne alte Area Overlays + Annotations
            let areaOverlays = uiView.overlays.filter { $0 is ColoredPolygon }
            uiView.removeOverlays(areaOverlays)
            let areaAnnotations = uiView.annotations.filter { $0 is AreaAnnotation }
            uiView.removeAnnotations(areaAnnotations)

            // Füge neue Areas hinzu
            for area in areas {
                if let polygon = createPolygonOverlay(area: area) {
                    uiView.addOverlay(polygon)
                    let annotation = AreaAnnotation()
                    annotation.coordinate = polygon.centerCoordinate
                    annotation.title = area.name
                    annotation.color = UIColor(hex: area.color ?? "#FF0000")
                    annotation.area = area
                    uiView.addAnnotation(annotation)
                }
            }

            DispatchQueue.main.async {
                self.refreshAreas = false
            }
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
        
        func showAreaInfoSheet(area: Areas) {
            DispatchQueue.main.async {
                self.parent.selectedArea = area
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let areaAnnotation = view.annotation as? AreaAnnotation {
                print("Area tapped: \(areaAnnotation.title ?? "Unknown")")
                
                // ➡️ Zeige hier dein Sheet oder Banner
                if let area = areaAnnotation.area {
                    showAreaInfoSheet(area: area)
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = overlayColors[polyline] ?? UIColor.systemYellow
                renderer.lineWidth = 3
                return renderer

            } else if let polygon = overlay as? ColoredPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = polygon.color?.withAlphaComponent(0.1) ?? UIColor.red.withAlphaComponent(0.1)
                renderer.strokeColor = polygon.color?.withAlphaComponent(0.5) ?? UIColor.red.withAlphaComponent(0.5)
                renderer.lineWidth = 2
                return renderer
            }

            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "UserAnnotationView"

            // ➡️ UserAnnotation wie bisher
            if let userAnnotation = annotation as? UserAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                    view?.displayPriority = .defaultHigh
                    let btn = UIButton(type: .detailDisclosure)
                    view?.rightCalloutAccessoryView = btn
                } else {
                    view?.annotation = annotation
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                    view?.displayPriority = .defaultHigh
                }
                return view
            }

            // ➡️ AreaAnnotation mit Fläche-Farbe
            if let areaAnnotation = annotation as? AreaAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: "AreaAnnotationView") as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AreaAnnotationView")
                    view?.canShowCallout = true
                    view?.glyphImage = UIImage(systemName: "info.circle.fill")
                    view?.markerTintColor = areaAnnotation.color ?? .green
                    view?.displayPriority = .defaultLow
                    view?.alpha = 0.5
                } else {
                    view?.annotation = annotation
                    view?.glyphImage = UIImage(systemName: "info.circle.fill")
                    view?.markerTintColor = areaAnnotation.color ?? .green
                    view?.displayPriority = .defaultLow
                }
                return view
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let userAnnotation = view.annotation as? UserAnnotation, let user = userAnnotation.user {
                print("👉 User tapped: \(user.username ?? "nil")")
                parent.selectedUser = user
            }
        }
    }
}


func createPolygonOverlay(area: Areas) -> ColoredPolygon? {
    guard let pointsString = area.points else { return nil }

    let pointPairs = pointsString.split(separator: ";")
    let coordinates = pointPairs.compactMap { pair -> CLLocationCoordinate2D? in
        let latLon = pair.split(separator: ",")
        if latLon.count == 2,
           let lat = Double(latLon[0]),
           let lon = Double(latLon[1]) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    let polygon = ColoredPolygon(coordinates: coordinates, count: coordinates.count)
    polygon.color = UIColor(hex: area.color ?? "#FF0000")
    polygon.name = area.name
    return polygon
}


extension MKPolygon {
    var centerCoordinate: CLLocationCoordinate2D {
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: pointCount)
        getCoordinates(coordsPointer, range: NSRange(location: 0, length: pointCount))
        let coords = Array(UnsafeBufferPointer(start: coordsPointer, count: pointCount))
        coordsPointer.deallocate()
        
        let avgLat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
        let avgLon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    }
}


