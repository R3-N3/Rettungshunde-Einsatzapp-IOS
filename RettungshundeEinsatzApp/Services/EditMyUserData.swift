//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation

func editMyUserData(
    email: String,
    phoneNumber: String,
    completion: @escaping (Bool, String) -> Void
) {
    
    print("Starte EditMyUserData")
    
    print("Starte CheckTokenAndGetMyUserData")
    
    let defaults = UserDefaults.standard
    
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    // URL bauen
    guard let url = URL(string: serverApiURL + "editmyuserdata") else {
        completion(false, "Invalid URL")
        return
    }
    
    // 2. Request vorbereiten
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // 3. Body Parameter
    let bodyParams = "token=\(token)&email=\(email)&phoneNumber=\(phoneNumber)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // 4. URLSession Task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ editMyUserData Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            // 5. JSON parsen
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let status = json["status"] as? String ?? "error"
                let message = json["message"] as? String ?? "Unknown error"
                
                if status == "success" {
                    print("✅ editMyUserData Success: \(message)")
                    completion(true, message)
                } else {
                    print("⚠️ editMyUserData Failure: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ editMyUserData JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
    
    task.resume()
}
