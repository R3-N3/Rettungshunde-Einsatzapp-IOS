//
//  AddArea.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 02.07.25.
//

import CoreData
import CoreLocation


func addAreaToLocalDataModel(context: NSManagedObjectContext, title: String, description: String, colorHex: String, coordinates: [CLLocationCoordinate2D]) {
    let newArea = Area(context: context)
    newArea.title = title
    newArea.desc = description
    newArea.color = colorHex

    // ➡️ Speichere jeden Punkt als AreaCoordinate
    for (index, coord) in coordinates.enumerated() {
        let newCoord = AreaCoordinate(context: context)
        newCoord.latitude = coord.latitude
        newCoord.longitude = coord.longitude
        newCoord.orderIndex = Int32(index)
        newCoord.area = newArea
    }

    do {
        try context.save()
        print("✅ Fläche erfolgreich gespeichert: \(title)")
    } catch {
        print("❌ Fehler beim Speichern der Fläche: \(error)")
    }
}
