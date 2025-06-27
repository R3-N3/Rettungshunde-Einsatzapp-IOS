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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
        }
    }
    
    /*var body: some Scene {
        WindowGroup {
            StartView()
        }
    }*/
}
