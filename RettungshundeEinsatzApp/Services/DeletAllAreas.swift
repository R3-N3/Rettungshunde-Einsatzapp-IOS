//
//  DeletAllAreas.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation

func deleteAllAreas(completion: @escaping (Bool, String) -> Void) {
    print("🟢 Starte deleteAllAreasFromServer")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "deleteareas") else {
        completion(false, "Invalid URL")
        return
    }
    
    guard !token.isEmpty else {
        completion(false, "Missing token")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let payload: [String: Any] = ["token": token]
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
    
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               let message = json["message"] as? String {
                
                if status == "success" {
                    print("✅ Alle Flächen auf Server gelöscht")
                    completion(true, message)
                } else {
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}
