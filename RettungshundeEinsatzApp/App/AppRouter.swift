//
//  AppRouter.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//


// Diese Datei ist notwendig, um zwischen bezüglich der RootView zwischen MapView und dem LoginView hin und her zu wechsel 
import SwiftUI
import CoreData


class AppRouter: ObservableObject {
    @Published var isLoggedIn: Bool


    init() {
        let hasToken = KeychainHelper.loadToken() != nil
        let username = UserDefaults.standard.string(forKey: "username")
        
        if hasToken, username != nil {
            print("🔑 Token und Benutzername vorhanden, starte MapView ")
            isLoggedIn = true
        } else {
            print("❌ Kein Token oder Benutzername, starte StartView")
            isLoggedIn = false
        }
    }
    
    func logout() {
        print("Starte Logout")
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "phoneNumber")
        defaults.removeObject(forKey: "securityLevel")
        defaults.removeObject(forKey: "radioCallName")
        defaults.removeObject(forKey: "serverApiURL")
        
        KeychainHelper.deleteToken()
        
        // ➔ CoreData Datenbanken leeren
        let persistentContainer = PersistenceController.shared.container

        persistentContainer.performBackgroundTask { context in
            let entityNames = persistentContainer.managedObjectModel.entities.compactMap({ $0.name })
            for entityName in entityNames {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                do {
                    try context.execute(deleteRequest)
                    print("✅ Alle Daten in \(entityName) gelöscht.")
                } catch {
                    print("❌ Fehler beim Löschen von \(entityName): \(error.localizedDescription)")
                }
            }
            do {
                try context.save()
            } catch {
                print("❌ Fehler beim Speichern nach Delete: \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async {
            self.isLoggedIn = false
            print("✅ Logout erfolgreich durchgeführt")
        }
    }
}
