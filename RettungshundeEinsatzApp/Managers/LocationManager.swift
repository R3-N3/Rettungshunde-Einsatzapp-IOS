//
//  LocationManager.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation
import CoreLocation
import CoreData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var lastLocation: CLLocation?
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var accuracy: Double = 0.0
    @Published var time: Date = Date()
    @Published var coordinates: [CLLocationCoordinate2D] = []
    @Published var isUpdating = false


    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.requestAlwaysAuthorization()
        
        // Entferne hier den Timer Start!
        // timer wird nur in startUpdating() gestartet
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
        isUpdating = true
        print("🟢 Standort-Tracking gestartet")

        // Starte Timer nur hier
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.processCurrentLocation()
        }
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isUpdating = false
        print("🔴 Standort-Tracking gestoppt")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            lastLocation = loc
        }
    }
    
    func processCurrentLocation() {
        guard let loc = lastLocation else { return }
        
        print("🟡 Verarbeite Standort alle 5 Sekunden: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        
        DispatchQueue.main.async {
            self.latitude = loc.coordinate.latitude
            self.longitude = loc.coordinate.longitude
            self.accuracy = loc.horizontalAccuracy
            self.time = loc.timestamp
        }
        
        uploadLocation(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            accuracy: loc.horizontalAccuracy,
            time: loc.timestamp
        ) { success, message in
            DispatchQueue.main.async {
                if success {
                    self.saveLocationToDatabase(
                        lat: loc.coordinate.latitude,
                        lon: loc.coordinate.longitude,
                        acc: loc.horizontalAccuracy,
                        time: loc.timestamp,
                        uploadedToServer: true
                    )
                    uploadAllUnsentLocations()
                } else {
                    self.saveLocationToDatabase(
                        lat: loc.coordinate.latitude,
                        lon: loc.coordinate.longitude,
                        acc: loc.horizontalAccuracy,
                        time: loc.timestamp,
                        uploadedToServer: false
                    )
                }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("🟡 Standortberechtigung: Immer erlaubt")
        case .authorizedWhenInUse:
            print("🟡 Standortberechtigung: Nur bei Nutzung erlaubt")
        default:
            print("🟡 Standortberechtigung: Keine Standortberechtigung")
        }
    }
    
    func saveLocationToDatabase(lat: Double, lon: Double, acc: Double, time: Date, uploadedToServer: Bool) {
        let context = PersistenceController.shared.container.viewContext
        let newEntry = MyGPSData(context: context)
        newEntry.latitude = lat
        newEntry.longitude = lon
        newEntry.accuracy = acc
        newEntry.time = time
        newEntry.uploadedToServer = uploadedToServer

        do {
            try context.save()
            print("✅ Standort lokal in Datenbank gespeichert")
            
            // ➔ Nach jedem Speichern die Koordinaten aktualisieren
            DispatchQueue.main.async {
                self.fetchAllCoordinates()
            }

        } catch {
            print("❌ Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    
    // Für Debug Zwecke zur Ausgabe aller Daten in der Datenbank
    func fetchAllMyLocations() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            for entry in results {
                print("Lat: \(entry.latitude), Lon: \(entry.longitude), Acc: \(entry.accuracy), Time: \(entry.time ?? Date()), Uploaded: \(entry.uploadedToServer)")
            }
        } catch {
            print("❌ Fehler beim Abrufen: \(error.localizedDescription)")
        }
    }
    

    func fetchAllCoordinates() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            self.coordinates = results.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        } catch {
            print("❌ Fehler beim Abrufen: \(error.localizedDescription)")
        }
    }
}
