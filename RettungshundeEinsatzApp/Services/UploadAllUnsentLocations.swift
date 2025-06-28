//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//
import Foundation
import CoreData

func uploadAllUnsentLocations() {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "uploadedToServer == false")

    do {
        let results = try context.fetch(fetchRequest)

        for location in results {
            uploadLocation(
                latitude: location.latitude,
                longitude: location.longitude,
                accuracy: location.accuracy,
                time: location.time ?? Date()
            ) { success, message in
                DispatchQueue.main.async {
                    if success {
                        print("Upload erfolgreich: \(message)")
                        location.uploadedToServer = true
                        do {
                            try context.save()
                        } catch {
                            print("Fehler beim Speichern: \(error.localizedDescription)")
                        }
                    } else {
                        print("Upload fehlgeschlagen: \(message)")
                    }
                }
            }
        }
    } catch {
        print("Fehler beim Abrufen: \(error.localizedDescription)")
    }
}
