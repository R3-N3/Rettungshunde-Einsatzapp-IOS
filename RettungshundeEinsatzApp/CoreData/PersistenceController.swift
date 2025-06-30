//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // ⚠️ Preview Support für SwiftUI Previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Beispiel: Dummy-Daten für Previews
        let viewContext = controller.container.viewContext
        let exampleUser = AllUserData(context: viewContext)
        exampleUser.id = 1
        exampleUser.username = "Preview User"
        exampleUser.email = "preview@example.com"
        exampleUser.phonenumber = "123456789"
        exampleUser.securitylevel = 1
        exampleUser.radiocallname = "Preview"
        exampleUser.trackcolor = "#FF0000"

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    // 🔧 Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel") // ⚠️ Exakter Name deiner .xcdatamodeld Datei

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("❌ Core Data loading error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
