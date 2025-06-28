//
//  RettungshundeEinsatzAppApp.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import SwiftUI

@main
struct RettungshundeEinsatzAppApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var bannerManager = BannerManager()
    let persistenceController = PersistenceController.shared

    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(bannerManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    /*var body: some Scene {
        WindowGroup {
            StartView()
        }
    }*/
}
