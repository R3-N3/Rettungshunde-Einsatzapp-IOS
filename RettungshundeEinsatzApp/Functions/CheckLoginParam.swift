//
//  Login.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import Foundation

func checkLoginParam(username: String, password: String, org: String) -> (Bool, String) {
    
    print("Starte checkLoginParam mit Benutzername: \(username) Passwort: \(password) Organisation \(org)")
    
    if username.trimmingCharacters(in: .whitespaces).isEmpty {
        return (false, String(localized: "username_required"))
    } else if password.isEmpty {
        return (false, String(localized: "password_required"))
    } else {
        return (false, String(localized: "login_failed"))
    }
    
    
    
    

}
