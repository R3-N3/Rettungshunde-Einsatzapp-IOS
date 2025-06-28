//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "MyGPSDataModel") // Muss dem DataModel Namen entsprechen
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data loading error: \(error.localizedDescription)")
            }
        }
    }
}
