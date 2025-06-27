//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//


//Hilfsfunktion zum speichern, alden und löschen des token

import Foundation
import Security

struct KeychainHelper {
    
    static func saveToken(_ token: String) {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "token",
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary) // Vorher löschen
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    static func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "token"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
