//
//  Login.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import Foundation

func checkLoginParam(username: String, password: String, org: String, completion: @escaping (Bool, String) -> Void
) {
    
    print("Starte checkLoginParam mit Benutzername: \(username) Passwort: \(password) Organisation \(org)")
    
    let defaults = UserDefaults.standard
    
    if username.trimmingCharacters(in: .whitespaces).isEmpty {
        completion(false, String(localized: "username_required"))
        return
    } else if password.isEmpty {
        completion(false, String(localized: "password_required"))
        return
    } else {
        
         var serverApiURL: String = ""
        
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
        
        // URL zusammensetzen
            guard let url = URL(string: serverApiURL + "login") else {
                completion(false, String(localized: "invalid_url"))
                return
            }
        
        // Formulardaten
            let params = "username=\(username)&password=\(password)"
            guard let postData = params.data(using: .utf8) else {
                completion(false, String(localized: "encoding_failed"))
                return
            }
        
        // Anfrage konfigurieren
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    // Fehler behandeln
                    if let error = error {
                        print("❌ Request Error: \(error.localizedDescription)")
                        completion(false, String(localized: "error") + error.localizedDescription)
                        return
                    }

                    guard let data = data else {
                        completion(false, String(localized: "no_data_received"))
                        return
                    }

                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let status = json?["status"] as? String ?? "unknown"
                        let token = json?["token"] as? String ?? ""
                        let message: String

                        switch status {
                        case "success":
                            message = String(localized: "login_successful")
                            KeychainHelper.saveToken(token)
                            defaults.set(serverApiURL, forKey: "serverApiURL")
                            completion(true, message)
                        case "false":
                            message = String(localized: "incorect_user_param")
                            completion(false, message)
                        case "error":
                            message = json?["message"] as? String ?? String(localized: "unknown_error")
                            completion(false, message)
                        default:
                            message = "❓ Unerwarteter Rückgabewert"
                            completion(false, message)
                        }

                    } catch {
                        print("❌ JSON-Fehler: \(error.localizedDescription)")
                        completion(false, "JSON-Verarbeitung fehlgeschlagen")
                    }
                }
                task.resume()
    }
}
