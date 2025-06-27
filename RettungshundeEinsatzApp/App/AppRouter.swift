//
//  AppRouter.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//


// Diese Datei ist notwendig, um zwischen bezüglich der RootView zwischen MapView und dem LoginView hin und her zu wechsel 
import SwiftUI

class AppRouter: ObservableObject {
    
    @Published var isLoggedIn: Bool
        
        init() {
            
            //print("Testmodus, lösche token in AppRouter.swift")
            //KeychainHelper.deleteToken()
            
            
            // Beim Init Token prüfen, wenn keiner da (=nil) false, wenn da true, sodass RootView die MapView startet
            if KeychainHelper.loadToken() != nil {
                print("🔑 Token gespeichert, starte MapView ")
                isLoggedIn = true
            } else {
                print("❌ Kein Token gespeichert, starte StartView")
                isLoggedIn = false
            }
        }
}
