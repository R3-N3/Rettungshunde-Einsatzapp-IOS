//
//  CheckTokenAndDownloadMyUserData.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation

func checkTokenAndDownloadMyUserData(router: AppRouter, completion: @escaping (Bool, String) -> Void) {

    
    print("🟢 Starte CheckTokenAndGetMyUserData")
    
    let defaults = UserDefaults.standard
    
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    // URL bauen
    guard let url = URL(string: serverApiURL + "downloadmyuserdata") else {
        completion(false, "Invalid URL")
        return
    }
    
    // Request Body
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let bodyParams = "token=\(token)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // URLSession task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(false, "Error 003: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            completion(false, "No data")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let status = json["status"] as? String ?? "error"
                let message = json["message"] as? String ?? ""
                
                if status == "success" {
                    let username = json["username"] as? String ?? ""
                    let email = json["email"] as? String ?? ""
                    let phoneNumber = json["phoneNumber"] as? String ?? ""
                    let securityLevel = json["securityLevel"] as? String ?? ""
                    let radioCallName = json["radioCallName"] as? String ?? ""
                    
                    // Speichern der Benutzerdaten
                    defaults.set(username, forKey: "username")
                    defaults.set(email, forKey: "email")
                    defaults.set(phoneNumber, forKey: "phoneNumber")
                    defaults.set(securityLevel, forKey: "securityLevel")
                    defaults.set(radioCallName, forKey: "radioCallName")
                    defaults.set("#0c8ef7", forKey: "trackColor")
                    
                    // Erfolg
                    print("✅ Token gültig, Nachricht: \(message)")
                    let result = [status, message, username, email, phoneNumber, securityLevel, radioCallName].joined(separator: ",")
                    completion(true, result)
                } else {
                    if message == "No token found."{
                        print("❌ Kein Token gefunden, Nachricht: \(message)")
                        router.logout() // Startet Logout Funktion in AppRouter.swift
                    }
                    else if message == "Token expired." {
                            print("❌ Token abgelaufen, Nachricht: \(message)")
                        router.logout() // Startet Logout Funktion in AppRouter.swift
                        
                    }
                    else{
                        print("❌ Fehler in CheckTokenAndGetMyUserData, Nachricht: \(message)")
                        let errorMsg = [status, message].joined(separator: ",")
                        completion(false, errorMsg)
                    }
                    
                    
                    
                    let errorMsg = [status, message].joined(separator: ",")
                    completion(false, errorMsg)
                }
            } else {
                completion(false, "Invalid JSON")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            completion(false, "Error 003: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}
