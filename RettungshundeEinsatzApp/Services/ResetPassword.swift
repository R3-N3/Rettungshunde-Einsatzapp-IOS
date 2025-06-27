//
//  ResetPassword.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

import Foundation

func resetPassword(org: String, email: String, completion: @escaping (Bool, String) -> Void) {
    
    print("Starte ResetPassword mit E-Mail: \(email) und Organisation \(org)")
    
    var serverApiURL: String = ""
    
    // Prüfe Benutzereingabe
    if email.trimmingCharacters(in: .whitespaces).isEmpty || !isValidEmail(email){
        completion(false, String(localized: "email_required_or_wrong_format"))
        return
    } else {
        if org == "BRH RHS Bonn/Rhein-Sieg"{
            serverApiURL = "https://api.rettungshunde-einsatzapp.de/brh28/"
        } else if org == "Demo"{
            serverApiURL = "https://api.rettungshunde-einsatzapp.de/demo/"
        } else if org == "Debug"{
            serverApiURL = "https://api.rettungshunde-einsatzapp.de/debug/"
        } else{
            completion(false, String(localized: "unknown_org"))
            return
        }
    }
    
    // URL zusammensetzen
    guard let url = URL(string: serverApiURL + "resetpassword") else {
        completion(false, String(localized: "invalid_url"))
        return
    }
    
    
    // Formulardaten
    let params = "email=\(email)"
    guard let postData = params.data(using: .utf8) else {
        completion(false, "Encoding failed")
        return
    }
    
    // Anfrage konfigurieren
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = postData
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // URLSession Call
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
        // Fehlerbehandlung
        if let error = error {
            print("❌ resetPassword Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            // JSON parsen
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let status = json["status"] as? String,
               let message = json["message"] as? String {
                
                if status == "success" {
                    completion(true, message)
                    print("✅ resetPassword: Data submitted. If E-Mail is correct, password will be reset.")
                } else {
                    completion(false, message)
                    print("⚠️ resetPassword Error: \(message)")
                }
                
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            completion(false, error.localizedDescription)
            print("❌ resetPassword JSON Error: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}
