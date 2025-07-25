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

class AreaAnnotation: MKPointAnnotation {
    var area: Area?
    var color: UIColor?
}


struct CustomMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let userTracks: [UserTrack]
    @Binding var mapType: MKMapType
    @Binding var refreshUserTracks: Bool
    @Binding var selectedUser: AllUserData?
    @Binding var selectedArea: Area?
    var newAreas: [Area] 
    @Binding var refreshAreas: Bool
    @Binding var isDrawingArea: Bool
    @Binding var drawingAreaCoordinates: [CLLocationCoordinate2D]
    @Binding var refreshMapView: Bool
    
    
    private func addNewAreasOverlaysAndAnnotations(to mapView: MKMapView, areas: [Area]) {
        
        print("➡️ Add new Areas in UI")
        // Entferne alte Overlays der neuen Areas
        let areaOverlays = mapView.overlays.filter {
            ($0 is ColoredPolygon) || ($0 is MKPolygon)
        }
        mapView.removeOverlays(areaOverlays)
        
        let areaAnnotations = mapView.annotations.filter { $0 is AreaAnnotation }
        mapView.removeAnnotations(areaAnnotations)

        // Füge neue Areas als Overlay und Annotation hinzu
        for area in areas {
            if let overlay = createPolygonOverlayNew(area: area) {
                mapView.addOverlay(overlay)
                
                let annotation = AreaAnnotation()
                
                if let polygon = overlay as? MKPolygon {
                    annotation.coordinate = polygon.centerCoordinate
                } else if let polyline = overlay as? MKPolyline {
                    // Linie → setze Mitte der Linie
                    let coords = polyline.coordinates
                    if let first = coords.first, let last = coords.last {
                        annotation.coordinate = CLLocationCoordinate2D(
                            latitude: (first.latitude + last.latitude) / 2,
                            longitude: (first.longitude + last.longitude) / 2
                        )
                    } else {
                        annotation.coordinate = coords.first ?? CLLocationCoordinate2D()
                    }
                } else if let circle = overlay as? MKCircle {
                    annotation.coordinate = circle.coordinate
                }
                
                annotation.title = area.title
                annotation.area = area
                annotation.color = UIColor.red
                mapView.addAnnotation(annotation)
            }
        }
        print("⬅️ Add new Areas in UI - abgeschlossen")
    }


    
    private func addAllUserLocationAndAnnotations(to mapView: MKMapView, context: Context) {
        
        print("➡️ Starte Alle User Location zur UI hinzufügen")
        
        // Entferne alle fremden Overlays (außer eigene Polyline)
        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                if polyline != context.coordinator.myPolyline {
                    mapView.removeOverlay(polyline)
                }
            }
        }
        
        // Entferne alle UserAnnotations (Da der eigene Standort keine Annotation hat, muss dieser nicht vom löschen ausgeschlossen werden)
        let userAnnotations = mapView.annotations.filter { $0 is UserAnnotation }
        mapView.removeAnnotations(userAnnotations)
        
        // Füge Tracks und User hinzu
        for track in userTracks {
            
            let segments = track.coordinates.splitSegments(maxDistance: 100)// trennt tracks wenn Punkte mehr als 50 meter auseinander sind
            
            for segment in segments {
                let polyline = MKPolyline(coordinates: segment, count: segment.count)
                context.coordinator.overlayColors[polyline] = track.color
                mapView.addOverlay(polyline)
            }

            if let user = track.user, let lastCoord = track.coordinates.last {
                let annotation = UserAnnotation()
                annotation.coordinate = lastCoord
                annotation.title = user.username ?? "User"
                annotation.user = user
                annotation.color = track.iconColor
                mapView.addAnnotation(annotation)
            }
        }
        
        print("⬅️ Starte Alle User Location zur UI hinzufügen - abgeschlossen")
    }
    
    private func DeleteAllUserData(to mapView: MKMapView, context: Context) {
        
        // Entferne alle fremden Overlays (außer eigene Polyline)
        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                if polyline != context.coordinator.myPolyline {
                    mapView.removeOverlay(polyline)
                }
            }
        }
        
        // Entferne alle UserAnnotations (Da der eigene Standort keine Annotation hat, muss dieser nicht vom löschen ausgeschlossen werden)
        let userAnnotations = mapView.annotations.filter { $0 is UserAnnotation }
        mapView.removeAnnotations(userAnnotations)
        
    }
    
    
    
    private func addMyTrack(to mapView: MKMapView, context: Context) {
        
        if let lastCoords = context.coordinator.lastMyCoordinates, lastCoords.isEqualTo(coordinates) {
            return // keine Änderung ➔ Return
        }
        
        print("➡️ Load/Reload MyTrack in UI")
        
        context.coordinator.lastMyCoordinates = coordinates
        
        // Entferne vorhandene eigene Polyline(s)
        if let existing = context.coordinator.myPolyline {
            mapView.removeOverlay(existing)
        }
        
        // ➡️ Splitte eigene Koordinaten in Segmente (z.B. max 30m)
        let segments = coordinates.splitSegments(maxDistance: 100.0)
        
        // Füge alle Segmente hinzu
        var lastPolyline: MKPolyline?
        
        for segment in segments {
            guard segment.count >= 2 else { continue } // Polyline benötigt mind. 2 Punkte
            
            let polyline = MKPolyline(coordinates: segment, count: segment.count)
            let hexString = UserDefaults.standard.string(forKey: "trackColor")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "#FF0000"
            let myColor = UIColor(hex: hexString) ?? UIColor.systemRed
            
            context.coordinator.overlayColors[polyline] = myColor
            mapView.addOverlay(polyline)
            
            lastPolyline = polyline // letzte Polyline speichern
        }
        
        // Speichere Referenz zur letzten Polyline, falls du sie später wieder löschen möchtest
        context.coordinator.myPolyline = lastPolyline
        
        print("⬅️ Load/Reload MyTrack in UI - abgeschlossen")
    }


    func makeUIView(context: Context) -> MKMapView {
        print("🟢🟢 Starte makeUIView")
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
        addAllUserLocationAndAnnotations(to: mapView, context: context)
        addMyTrack(to: mapView, context: context)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("🟢 Starte UpdateUI in CustomMapView")
        
        uiView.mapType = mapType
        
        if refreshAreas {
            
            addNewAreasOverlaysAndAnnotations(to: uiView, areas: newAreas)
            refreshAreas = false
        }

        // ➡️ Aktualisiere fremde UserTracks nur wenn refreshUserTracks == true
        if refreshUserTracks {
            print("➡️ Reload AllUserTracks in UI")
            addAllUserLocationAndAnnotations(to: uiView, context: context)
            refreshUserTracks = false
        }
        
        
        // Aktualisier eigene Polyline (Funktion prüft, ob sich diese geädnert hat)
        addMyTrack(to: uiView, context: context)
        
        
        if refreshMapView {
            let existingDrawingOverlays = uiView.overlays.filter { $0.title == "DrawingPolygon" }
            existingDrawingOverlays.forEach { uiView.removeOverlay($0) }
        }

        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var overlayColors: [MKPolyline: UIColor] = [:]

        var myPolyline: MKPolyline?
        var lastMyCoordinates: [CLLocationCoordinate2D]?

        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func showAreaInfoSheet(area: Area) {
            DispatchQueue.main.async {
                self.parent.selectedArea = area
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let areaAnnotation = view.annotation as? AreaAnnotation {
                if let area = areaAnnotation.area {
                    DispatchQueue.main.async {
                        self.parent.selectedArea = area
                    }
                }
            }
            
            if let userAnnotation = view.annotation as? UserAnnotation, let user = userAnnotation.user {
                print("👉 User tapped directly: \(user.username ?? "nil")")
                DispatchQueue.main.async {
                    self.parent.selectedUser = user
                }
            }
        }
        

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            // ➡️ DrawingPolygon prüfen
            if overlay.title == "DrawingPolygon" {
                if let polygon = overlay as? MKPolygon {
                    let renderer = MKPolygonRenderer(polygon: polygon)
                    renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
                    renderer.strokeColor = UIColor.blue
                    renderer.lineWidth = 2
                    return renderer

                } else if let polyline = overlay as? MKPolyline {
                    let renderer = MKPolylineRenderer(polyline: polyline)
                    renderer.strokeColor = UIColor.blue
                    renderer.lineWidth = 2
                    return renderer

                } else if let circle = overlay as? MKCircle {
                    let renderer = MKCircleRenderer(circle: circle)
                    renderer.fillColor = UIColor.blue
                    return renderer
                }
            }

            // ➡️ ColoredPolyline Renderer
            if let polyline = overlay as? ColoredPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = (polyline.color ?? UIColor.green).withAlphaComponent(0.2)
                renderer.lineWidth = 3
                return renderer
            }

            // ➡️ Standard Polyline Renderer (für UserTracks)
            else if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = overlayColors[polyline] ?? UIColor.systemYellow
                renderer.lineWidth = 3
                return renderer
            }

            // ➡️ ColoredPolygon Renderer
            if let polygon = overlay as? ColoredPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = polygon.color?.withAlphaComponent(0.1) ?? UIColor.red.withAlphaComponent(0.1)
                renderer.strokeColor = polygon.color?.withAlphaComponent(0.5) ?? UIColor.red.withAlphaComponent(0.5)
                renderer.lineWidth = 1
                return renderer
            }

            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "UserAnnotationView"

            // ➡️ UserAnnotation
            if let userAnnotation = annotation as? UserAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    view?.glyphImage = UIImage(systemName: "person.fill")
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                    view?.displayPriority = .defaultHigh
                    view?.zPriority = .max
                } else {
                    view?.annotation = annotation
                    view?.glyphImage = UIImage(systemName: "person.fill")
                    view?.markerTintColor = userAnnotation.color ?? .systemOrange
                    view?.displayPriority = .defaultHigh
                    view?.zPriority = .max
                }
                return view
            }

            // ➡️ AreaAnnotation mit Fläche-Farbe
            if let areaAnnotation = annotation as? AreaAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: "AreaAnnotationView") as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AreaAnnotationView")
                    view?.canShowCallout = true
                    view?.glyphImage = UIImage(systemName: "mappin.and.ellipse")
                    view?.markerTintColor = areaAnnotation.color ?? .green
                    view?.displayPriority = .defaultLow
                    view?.alpha = 0.5
                } else {
                    view?.annotation = annotation
                    view?.glyphImage = UIImage(systemName: "mappin.and.ellipse")
                    view?.markerTintColor = areaAnnotation.color ?? .green
                    view?.displayPriority = .defaultLow
                }
                return view
            }

            return nil
        }
        
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard parent.isDrawingArea else { return }

            let mapView = gestureRecognizer.view as! MKMapView
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.drawingAreaCoordinates.append(coordinate)

            // Optional: sofort Fläche aktualisieren
            updateDrawingPolygon(on: mapView)
        }

        func updateDrawingPolygon(on mapView: MKMapView) {
            // Entferne bestehendes DrawingOverlay
            let existingOverlays = mapView.overlays.filter { $0.title == "DrawingPolygon" }
            existingOverlays.forEach { mapView.removeOverlay($0) }

            let coords = parent.drawingAreaCoordinates
            let count = coords.count

            guard count > 0 else { return }

            if count == 1 {
                // ➡️ Erster Punkt: füge kleinen Kreis als MKCircle hinzu
                let circle = MKCircle(center: coords[0], radius: 10) // Beispiel: 10 Meter Radius
                circle.title = "DrawingPolygon"
                mapView.addOverlay(circle)

            } else if count == 2 {
                // ➡️ Zwei Punkte: zeige Linie
                let polyline = MKPolyline(coordinates: coords, count: count)
                polyline.title = "DrawingPolygon"
                mapView.addOverlay(polyline)

            } else {
                // ➡️ Ab drei Punkten: zeige Polygon
                let polygon = MKPolygon(coordinates: coords, count: count)
                polygon.title = "DrawingPolygon"
                mapView.addOverlay(polygon)
            }
        }
        
    }
}



func createPolygonOverlayNew(area: Area) -> MKOverlay? {
    guard let coordinatesSet = area.coordinates as? Set<AreaCoordinate> else { return nil }
    let sortedCoords = coordinatesSet.sorted { $0.orderIndex < $1.orderIndex }
    let coords = sortedCoords.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

    if coords.count == 1 {
        // ➡️ Einzelpunkt → MKCircle
        let circle = MKCircle(center: coords[0], radius: 5)
        return circle

    } else if coords.count == 2 {
        // ➡️ Linie → ColoredPolyline
        let polyline = ColoredPolyline(coordinates: coords, count: coords.count)
        if let colorHex = area.color, let uiColor = UIColor(hex: colorHex) {
            polyline.color = uiColor.withAlphaComponent(0.8)
        } else {
            polyline.color = UIColor.red.withAlphaComponent(0.8)
        }
        return polyline

    } else {
        // ➡️ Polygon → ColoredPolygon
        let polygon = ColoredPolygon(coordinates: coords, count: coords.count)

        if let colorHex = area.color, let uiColor = UIColor(hex: colorHex) {
            polygon.color = uiColor.withAlphaComponent(0.5)
        } else {
            polygon.color = UIColor.red.withAlphaComponent(0.5)
        }

        polygon.name = area.title
        return polygon
    }
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


extension Array where Element == CLLocationCoordinate2D {
    func isEqualTo(_ other: [CLLocationCoordinate2D]) -> Bool {
        if self.count != other.count { return false }
        for (a, b) in zip(self, other) {
            if a.latitude != b.latitude || a.longitude != b.longitude {
                return false
            }
        }
        return true
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        return coords
    }
}

class ColoredPolyline: MKPolyline {
    var color: UIColor?
}

