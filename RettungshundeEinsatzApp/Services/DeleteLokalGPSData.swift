//
//  DeleteLokalGPSData.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import CoreData

func deleteLokalGPSData() -> Bool {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MyGPSData.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
        try context.save()
        print("✅ Alle GPS-Daten gelöscht")
        return true
    } catch {
        print("❌ Fehler beim Löschen: \(error.localizedDescription)")
        return false
    }
}
