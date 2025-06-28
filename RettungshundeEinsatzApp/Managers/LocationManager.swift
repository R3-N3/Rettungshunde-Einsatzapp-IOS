//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation
import CoreLocation
import CoreData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var accuracy: Double = 0.0
    @Published var time: Date = Date()
    

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true // ➔ hier hinzugefügt
        locationManager.requestAlwaysAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
        print("Standort-Tracking gestartet")
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        print("Standort-Tracking gestoppt")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            print("Standort: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
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
                        print("Upload erfolgreich: \(message)")
                        self.saveLocationToDatabase(
                                        lat: loc.coordinate.latitude,
                                        lon: loc.coordinate.longitude,
                                        acc: loc.horizontalAccuracy,
                                        time: loc.timestamp,
                                        uploadedToServer: true
                                    )
                        uploadAllUnsentLocations()
                    } else {
                        print("Upload fehlgeschlagen: \(message)")
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
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("Standortberechtigung: Immer erlaubt")
        case .authorizedWhenInUse:
            print("Standortberechtigung: Nur bei Nutzung erlaubt")
        default:
            print("Standortberechtigung: Keine Standortberechtigung")
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
            print("Standort in Datenbank gespeichert")
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    
    func fetchAllLocations() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            for entry in results {
                print("Lat: \(entry.latitude), Lon: \(entry.longitude), Acc: \(entry.accuracy), Time: \(entry.time), Uploaded: \(entry.uploadedToServer)")
            }
        } catch {
            print("Fehler beim Abrufen: \(error.localizedDescription)")
        }
    }
}
